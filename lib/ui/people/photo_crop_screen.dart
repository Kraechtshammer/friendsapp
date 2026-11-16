import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/crop_math.dart';
import '../../domain/person.dart';
import '../../platform/photo_store.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/main_button.dart';

/// A full-screen square crop of [bytes] (a photo in any format the system
/// decodes): the photo is dragged and pinched under a fixed frame in the
/// outline of the avatar's [shape]. Returns the stored picture's file name
/// (`PhotoStore.saveSquare` with the crop), or null if the user cancelled or
/// the photo cannot be read. The caller owns the name: it has to put it on
/// the person and delete the old file.
Future<String?> cropAndSavePhoto(
  BuildContext context,
  WidgetRef ref,
  Uint8List bytes, {
  AvatarShape shape = AvatarShape.squircle,
}) => Navigator.of(context).push<String>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => PhotoCropScreen(
      bytes: bytes,
      shape: shape,
      store: ref.read(photoStoreProvider),
    ),
  ),
);

/// The longest side the display copy of a photo may have, in pixels.
const _maxDisplaySide = 4096;

/// The screen behind [cropAndSavePhoto].
///
/// The photo is decoded once for display, at about 1.5 times the screen
/// width on its shorter side (a 50 MP photo does not fill memory), and drawn
/// by one painter that listens to the view, so a drag or pinch rebuilds no
/// widget. The crop is worked out in photo pixels ([cropRect]) and the full
/// photo goes to the store.
class PhotoCropScreen extends StatefulWidget {
  const PhotoCropScreen({
    super.key,
    required this.bytes,
    required this.shape,
    required this.store,
  });

  final Uint8List bytes;
  final AvatarShape shape;
  final PhotoStore store;

  @override
  State<PhotoCropScreen> createState() => _PhotoCropScreenState();
}

class _PhotoCropScreenState extends State<PhotoCropScreen>
    with SingleTickerProviderStateMixin {
  final _view = ValueNotifier(CropView.start);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  ui.Image? _image;

  /// The photo's size as shown (EXIF orientation applied), in photo pixels.
  Size? _size;
  var _failed = false;
  var _saving = false;
  var _frame = 0.0;

  // The gesture in progress.
  var _gestureStart = CropView.start;
  var _focalStart = Offset.zero;
  Offset _doubleTapAt = Offset.zero;
  Offset _center = Offset.zero;

  // The double-tap move, from one view to another.
  var _from = CropView.start;
  var _to = CropView.start;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      final t = Curves.easeOutCubic.transform(_anim.value);
      _view.value = CropView(
        ui.lerpDouble(_from.zoom, _to.zoom, t)!,
        Offset.lerp(_from.offset, _to.offset, t)!,
      );
    });
  }

  bool _decoding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decoding) return;
    _decoding = true;
    final view = View.of(context);
    final shortSide = view.physicalSize.width * 1.5;
    unawaited(_decode(shortSide));
  }

  Future<void> _decode(double shortTarget) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(widget.bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final w = descriptor.width;
      final h = descriptor.height;
      final scale = math.min(
        1.0,
        math.min(
          shortTarget / math.min(w, h),
          _maxDisplaySide / math.max(w, h),
        ),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (w * scale).round()),
        targetHeight: math.max(1, (h * scale).round()),
      );
      final image = (await codec.getNextFrame()).image;
      // Size as shown: the decoded copy tells whether the descriptor's width
      // and height are already turned by the EXIF orientation.
      final swapped =
          (image.width > image.height) != (w > h) && (w - h).abs() > 1;
      final size = swapped
          ? Size(h.toDouble(), w.toDouble())
          : Size(w.toDouble(), h.toDouble());
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _image = image;
        _size = size;
      });
    } catch (e) {
      debugPrint('Photo not decoded: ${e.runtimeType}');
      if (mounted) setState(() => _failed = true);
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _view.dispose();
    _image?.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails d) {
    _anim.stop();
    _gestureStart = _view.value;
    _focalStart = d.localFocalPoint - _center;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final size = _size;
    if (size == null || _saving) return;
    _view.value = viewAfterGesture(
      start: _gestureStart,
      focalStart: _focalStart,
      focalNow: d.localFocalPoint - _center,
      scale: d.scale,
      frame: _frame,
      image: size,
    );
  }

  void _onDoubleTap() {
    final size = _size;
    if (size == null || _saving) return;
    _from = _view.value;
    _to = viewAfterDoubleTap(
      current: _from,
      focal: _doubleTapAt - _center,
      frame: _frame,
      image: size,
    );
    unawaited(_anim.forward(from: 0));
  }

  Future<void> _use() async {
    final size = _size;
    if (size == null || _saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.cropFailed;
    try {
      final name = await widget.store.saveSquare(
        widget.bytes,
        crop: cropRect(_view.value, _frame, size),
      );
      navigator.pop(name);
    } catch (e) {
      debugPrint('Picture not saved: ${e.runtimeType}');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final image = _image;
    final size = _size;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: kept.ground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(l10n.cropTitle, style: context.text.headlineLarge),
                    Text(
                      l10n.cropHint,
                      style: context.text.bodyMedium?.copyWith(
                        color: kept.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    _center = box.biggest.center(Offset.zero);
                    _frame = math.max(
                      1.0,
                      math.min(box.maxWidth - 32, box.maxHeight - 24),
                    );
                    if (_failed) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.cropFailed,
                            textAlign: TextAlign.center,
                            style: context.text.bodyLarge,
                          ),
                        ),
                      );
                    }
                    if (image == null || size == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Semantics(
                      label: l10n.cropTitle,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
                        onDoubleTap: _onDoubleTap,
                        child: ClipRect(
                          child: CustomPaint(
                            size: box.biggest,
                            painter: _CropPainter(
                              image: image,
                              size: size,
                              frame: _frame,
                              view: _view,
                              path: avatarPath(widget.shape, _frame),
                              dim: kept.ground.withValues(alpha: .72),
                              outline: kept.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    MainButton(
                      label: _saving ? l10n.cropSaving : l10n.cropUse,
                      onPressed: image == null || _saving
                          ? null
                          : () => unawaited(_use()),
                    ),
                    GreyButton(
                      label: l10n.cancel,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the photo at the view's zoom and offset, dims everything outside
/// the frame's shape and outlines the shape. Repaints on the view alone.
class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.image,
    required this.size,
    required this.frame,
    required this.view,
    required this.path,
    required this.dim,
    required this.outline,
  }) : super(repaint: view);

  final ui.Image image;

  /// The photo's size as shown, in photo pixels.
  final Size size;
  final double frame;
  final ValueNotifier<CropView> view;

  /// The frame's shape, at the origin.
  final Path path;
  final Color dim;
  final Color outline;

  @override
  void paint(Canvas canvas, Size area) {
    final v = view.value;
    final scale = coverScale(frame, size) * v.zoom;
    final center = area.center(Offset.zero);
    final dst = Rect.fromCenter(
      center: center + v.offset,
      width: size.width * scale,
      height: size.height * scale,
    );
    canvas.drawImageRect(
      image,
      Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
    final shape = path.shift(center - Offset(frame / 2, frame / 2));
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & area)
        ..addPath(shape, Offset.zero),
      Paint()..color = dim,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = outline.withValues(alpha: .9),
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image ||
      old.frame != frame ||
      old.size != size ||
      old.path != path ||
      old.dim != dim;
}
