import 'dart:ui';
import 'package:flutter/material.dart';

class TwoColorBackground extends StatefulWidget {
  const TwoColorBackground({super.key});

  @override
  State<TwoColorBackground> createState() => _TwoColorBackgroundState();
}

class _TwoColorBackgroundState extends State<TwoColorBackground>
    with TickerProviderStateMixin {
  // The two selected colors
  final Color colorYellow = const Color(0xFFFFF2C6);
  final Color colorBlue = const Color(0xFFAAC4F5);

  // Only needed two controllers now
  late AnimationController _c1, _c2;
  late Animation<Alignment> _a1, _a2;

  @override
  void initState() {
    super.initState();

    // Using slightly longer, different durations for a calm, non-repeating feel
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 20));

    // Yellow Path: Diagonal from top-left towards bottom-right
    // Starting further out (-1.5) ensures it covers corners well
    _a1 = AlignmentTween(
      begin: const Alignment(-1.5, -1.5),
      end: const Alignment(1.2, 1.2),
    ).animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));

    // Blue Path: Diagonal from bottom-left towards top-right
    // Crossing the path of the yellow blob creates nice blending in the middle
    _a2 = AlignmentTween(
      begin: const Alignment(-1.5, 1.5),
      end: const Alignment(1.2, -1.2),
    ).animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));

    _c1.repeat(reverse: true);
    _c2.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  // Helper to build the gradient blob (same technique as before)
  Widget _buildBlob(Color color, Animation<Alignment> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final blobSize = size.width * 1.8; // Very large blobs for smooth coverage

        return Align(
          alignment: animation.value,
          child: Container(
            width: blobSize,
            height: blobSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                // Stronger opacity at center for better visibility against white
                colors: [color.withOpacity(0.9), color.withOpacity(0.0)],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Layer the two blobs
          _buildBlob(colorYellow, _a1),
          _buildBlob(colorBlue, _a2),

          // Apply the blur filter to blend them
          Positioned.fill(
            child: BackdropFilter(
              // High sigma for a very soft, ethereal blend
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}