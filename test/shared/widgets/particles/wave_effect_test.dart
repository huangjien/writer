import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/particles/wave_effect.dart';

void main() {
  testWidgets('WaveTap shows no wave before interaction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: WaveTap(child: Text('Tap me'))),
      ),
    );

    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('WaveTap starts wave on tap down and fires onTap', (
    tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 120,
              child: WaveTap(
                borderRadius: BorderRadius.circular(12),
                onTap: () => taps++,
                child: const ColoredBox(
                  color: Colors.blue,
                  child: Center(child: Text('Tap area')),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(WaveTap)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(CustomPaint), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(12));

    await gesture.up();
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('WaveTap fires onLongPress', (tester) async {
    int longPresses = 0;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 120,
              child: WaveTap(
                onLongPress: () => longPresses++,
                child: const Center(child: Text('Hold')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Hold'));
    await tester.pump();

    expect(longPresses, 1);
  });

  testWidgets('WaveTap uses default border radius when not provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 120,
            child: WaveTap(
              onTap: null,
              child: ColoredBox(
                color: Colors.blue,
                child: Center(child: Text('Tap area')),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(WaveTap)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.zero);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('WaveTap painter can paint without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 120,
            child: WaveTap(
              color: Colors.red,
              maxRadius: 42,
              child: ColoredBox(
                color: Colors.blue,
                child: Center(child: Text('Tap area')),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(WaveTap)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = customPaint.painter!;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    painter.paint(canvas, const Size(200, 120));
    recorder.endRecording();

    expect(painter.shouldRepaint(painter), isFalse);

    await gesture.up();
    await tester.pump();
  });
}
