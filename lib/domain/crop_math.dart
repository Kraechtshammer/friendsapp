/// The arithmetic of the square crop screen (ui/people/photo_crop_screen.dart).
///
/// The photo sits under a fixed square frame of side `frame` (logical
/// pixels). The picture is described by `zoom` and `offset`:
///
/// - zoom 1 is the smallest size that still covers the frame: the shorter
///   side of the photo is as long as the frame. [maxCropZoom] is the largest.
/// - offset is where the centre of the photo sits, measured from the centre
///   of the frame, in logical pixels.
///
/// The photo size is the size as it is shown, EXIF orientation applied.
/// Everything here is pure, so it is tested without a screen.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

/// How far the user may zoom in: five times the covering size.
const maxCropZoom = 5.0;

/// Where the photo is: [zoom] (1 to [maxCropZoom]) and the [offset] of its
/// centre from the frame's centre.
class CropView {
  const CropView(this.zoom, this.offset);

  /// The start: the photo centred, just covering the frame.
  static const start = CropView(1, Offset.zero);

  final double zoom;
  final Offset offset;

  @override
  bool operator ==(Object other) =>
      other is CropView && other.zoom == zoom && other.offset == offset;

  @override
  int get hashCode => Object.hash(zoom, offset);

  @override
  String toString() => 'CropView($zoom, $offset)';
}

/// Logical pixels per photo pixel at zoom 1: the shorter side of [image]
/// as long as [frame].
double coverScale(double frame, Size image) =>
    frame / math.min(image.width, image.height);

/// [view] moved so the photo still covers the whole frame: the zoom within
/// 1 and [maxCropZoom], the offset within what the photo's overhang allows.
CropView clampView(CropView view, double frame, Size image) {
  final zoom = view.zoom.clamp(1.0, maxCropZoom).toDouble();
  final scale = coverScale(frame, image) * zoom;
  // How far the photo's centre may move on each axis (never negative).
  final dx = math.max(0.0, (image.width * scale - frame) / 2);
  final dy = math.max(0.0, (image.height * scale - frame) / 2);
  return CropView(
    zoom,
    Offset(
      view.offset.dx.clamp(-dx, dx).toDouble(),
      view.offset.dy.clamp(-dy, dy).toDouble(),
    ),
  );
}

/// The view during a pinch or drag. [start] is the view when the fingers
/// went down, [focalStart] and [focalNow] the point between the fingers then
/// and now, both measured from the frame's centre, and [scale] the pinch
/// factor since the start (1 for a plain drag). The photo point under the
/// fingers stays under them; the result is clamped.
CropView viewAfterGesture({
  required CropView start,
  required Offset focalStart,
  required Offset focalNow,
  required double scale,
  required double frame,
  required Size image,
}) {
  final zoom = (start.zoom * scale).clamp(1.0, maxCropZoom).toDouble();
  final ratio = zoom / start.zoom;
  final offset = focalNow - (focalStart - start.offset) * ratio;
  return clampView(CropView(zoom, offset), frame, image);
}

/// The view after a double tap at [focal] (from the frame's centre): back to
/// the start when already zoomed in, else [target] times the covering size
/// around the tapped point.
CropView viewAfterDoubleTap({
  required CropView current,
  required Offset focal,
  required double frame,
  required Size image,
  double target = 2.5,
}) {
  if (current.zoom > 1.01) return CropView.start;
  return viewAfterGesture(
    start: current,
    focalStart: focal,
    focalNow: focal,
    scale: target,
    frame: frame,
    image: image,
  );
}

/// The square of the photo, in photo pixels, that lies under the frame. Fed
/// to `PhotoStore.saveSquare`. Kept inside the photo even after rounding
/// errors.
Rect cropRect(CropView view, double frame, Size image) {
  final v = clampView(view, frame, image);
  final scale = coverScale(frame, image) * v.zoom;
  final side = math.min(frame / scale, math.min(image.width, image.height));
  final left = image.width / 2 - v.offset.dx / scale - side / 2;
  final top = image.height / 2 - v.offset.dy / scale - side / 2;
  return Rect.fromLTWH(
    left.clamp(0.0, image.width - side).toDouble(),
    top.clamp(0.0, image.height - side).toDouble(),
    side,
    side,
  );
}
