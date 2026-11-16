import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/crop_math.dart';

/// The arithmetic of the square crop: frame 300, so a 4000 x 3000 photo
/// covers it at 0.1 logical pixels per photo pixel.
void main() {
  const frame = 300.0;
  const landscape = Size(4000, 3000);
  const portrait = Size(3000, 4000);
  const square = Size(1000, 1000);

  Matcher near(double v) => closeTo(v, 1e-6);

  group('coverScale', () {
    test('the shorter side is as long as the frame', () {
      expect(coverScale(frame, landscape), near(0.1));
      expect(coverScale(frame, portrait), near(0.1));
      expect(coverScale(frame, square), near(0.3));
    });
  });

  group('cropRect', () {
    test('the start view is the centre square of the whole short side', () {
      final r = cropRect(CropView.start, frame, landscape);
      expect(r.width, near(3000));
      expect(r.height, near(3000));
      expect(r.left, near(500));
      expect(r.top, near(0));
    });

    test('portrait: the centre square sits in the middle of the height', () {
      final r = cropRect(CropView.start, frame, portrait);
      expect((r.left, r.top, r.width), (0, 500, 3000));
    });

    test('a square photo at the start is the whole photo', () {
      final r = cropRect(CropView.start, frame, square);
      expect((r.left, r.top, r.width, r.height), (0, 0, 1000, 1000));
    });

    test('zoom 2 halves the side and keeps the centre', () {
      final r = cropRect(const CropView(2, Offset.zero), frame, landscape);
      expect(r.width, near(1500));
      expect(r.center.dx, near(2000));
      expect(r.center.dy, near(1500));
    });

    test('dragging the photo right shows its left part', () {
      // 100 logical px right = 1000 photo px at scale 0.1 (zoom 1).
      final r = cropRect(const CropView(1, Offset(100, 0)), frame, landscape);
      expect(r.left, near(0));
      // More than the overhang is clamped, never past the photo's edge.
      final far = cropRect(const CropView(1, Offset(900, 0)), frame, landscape);
      expect(far.left, near(0));
    });

    test('dragging up shows the lower part', () {
      final r = cropRect(const CropView(2, Offset(0, -150)), frame, landscape);
      // Scale 0.2: the frame shows 1500 photo px; 150 px up moves it 750 px
      // down from the centre (top 1500 - 750 + 750).
      expect(r.top, near(1500));
      expect(r.bottom, near(3000));
    });

    test('the rect always lies inside the photo', () {
      for (final size in [landscape, portrait, square, const Size(9000, 500)]) {
        for (final zoom in [1.0, 1.7, 3.0, maxCropZoom, 12.0]) {
          for (final dx in [-5000.0, -37.0, 0.0, 41.0, 5000.0]) {
            for (final dy in [-5000.0, -13.0, 0.0, 77.0, 5000.0]) {
              final r = cropRect(CropView(zoom, Offset(dx, dy)), frame, size);
              expect(r.left, greaterThanOrEqualTo(0));
              expect(r.top, greaterThanOrEqualTo(0));
              expect(r.right, lessThanOrEqualTo(size.width + 1e-9));
              expect(r.bottom, lessThanOrEqualTo(size.height + 1e-9));
              expect(r.width, near(r.height));
            }
          }
        }
      }
    });
  });

  group('clampView', () {
    test('zoom stays within 1 and the maximum', () {
      expect(
        clampView(const CropView(0.2, Offset.zero), frame, landscape).zoom,
        1,
      );
      expect(
        clampView(const CropView(99, Offset.zero), frame, landscape).zoom,
        maxCropZoom,
      );
    });

    test('the photo cannot leave the frame uncovered', () {
      // At zoom 1 a landscape photo is 400 x 300 on screen: it overhangs
      // 50 px on each side and none above or below.
      final v = clampView(
        const CropView(1, Offset(500, 500)),
        frame,
        landscape,
      );
      expect(v.offset.dx, near(50));
      expect(v.offset.dy, near(0));
      final w = clampView(
        const CropView(1, Offset(-500, -500)),
        frame,
        landscape,
      );
      expect((w.offset.dx, w.offset.dy), (-50, 0));
    });

    test('overhang grows with zoom', () {
      final v = clampView(
        const CropView(5, Offset(9999, 9999)),
        frame,
        landscape,
      );
      // 4000 * 0.5 = 2000 wide, 1500 high: overhang 850 and 600.
      expect(v.offset.dx, near(850));
      expect(v.offset.dy, near(600));
    });

    test('a view inside the limits is not changed', () {
      const v = CropView(3, Offset(20, -30));
      expect(clampView(v, frame, landscape), v);
    });
  });

  group('viewAfterGesture', () {
    test('a plain drag moves the photo with the finger', () {
      final v = viewAfterGesture(
        start: const CropView(2, Offset.zero),
        focalStart: const Offset(10, 10),
        focalNow: const Offset(40, 25),
        scale: 1,
        frame: frame,
        image: landscape,
      );
      expect(v.zoom, 2);
      expect((v.offset.dx, v.offset.dy), (30, 15));
    });

    test('a drag is clamped at the edge', () {
      final v = viewAfterGesture(
        start: const CropView(1, Offset.zero),
        focalStart: Offset.zero,
        focalNow: const Offset(400, 400),
        scale: 1,
        frame: frame,
        image: landscape,
      );
      expect((v.offset.dx, v.offset.dy), (50, 0));
    });

    test('a pinch keeps the photo point under the fingers', () {
      const start = CropView(2, Offset(10, -20));
      const focal = Offset(60, 40);
      final v = viewAfterGesture(
        start: start,
        focalStart: focal,
        focalNow: focal,
        scale: 1.5,
        frame: frame,
        image: landscape,
      );
      expect(v.zoom, near(3));
      // The photo point under the focal point before and after.
      Offset under(CropView c) =>
          (focal - c.offset) / (coverScale(frame, landscape) * c.zoom);
      expect(under(v).dx, near(under(start).dx));
      expect(under(v).dy, near(under(start).dy));
    });

    test('pinching out stops at the covering size', () {
      final v = viewAfterGesture(
        start: const CropView(1.5, Offset(30, 0)),
        focalStart: Offset.zero,
        focalNow: Offset.zero,
        scale: 0.1,
        frame: frame,
        image: landscape,
      );
      expect(v.zoom, 1);
      expect(v.offset.dx.abs(), lessThanOrEqualTo(50));
    });

    test('pinching in stops at the maximum', () {
      final v = viewAfterGesture(
        start: const CropView(4, Offset.zero),
        focalStart: Offset.zero,
        focalNow: Offset.zero,
        scale: 10,
        frame: frame,
        image: landscape,
      );
      expect(v.zoom, maxCropZoom);
    });
  });

  group('viewAfterDoubleTap', () {
    test('from the start it zooms in around the tapped point', () {
      final v = viewAfterDoubleTap(
        current: CropView.start,
        focal: const Offset(100, 0),
        frame: frame,
        image: landscape,
      );
      expect(v.zoom, 2.5);
      // The tapped photo point stays under the finger.
      expect(v.offset.dx, lessThan(0));
    });

    test('zoomed in, it goes back to the start', () {
      final v = viewAfterDoubleTap(
        current: const CropView(3, Offset(40, 40)),
        focal: Offset.zero,
        frame: frame,
        image: landscape,
      );
      expect(v, CropView.start);
    });
  });
}
