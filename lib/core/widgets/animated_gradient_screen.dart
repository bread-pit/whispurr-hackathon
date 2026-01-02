import 'dart:ui';
import 'package:flutter/material.dart';

class VividAnimatedBackground extends StatefulWidget {
  const VividAnimatedBackground({super.key});

  @override
  State<VividAnimatedBackground> createState() => _VividAnimatedBackgroundState();
}

class _VividAnimatedBackgroundState extends State<VividAnimatedBackground>
    with TickerProviderStateMixin {
  // Your specific hex colors
  final Color colorYellow = const Color(0xFFFFF2C6);
  final Color colorPink = const Color(0xFFFD7979);
  final Color colorBlue = const Color(0xFFAAC4F5);
  final Color colorGreen = const Color(0xFFA1BC98);

  late AnimationController _c1, _c2, _c3, _c4;
  late Animation<Alignment> _a1, _a2, _a3, _a4;

  @override
  void initState() {
    super.initState();

    // Faster durations make movement more obvious
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 14));
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 16));
    _c4 = AnimationController(vsync: this, duration: const Duration(seconds: 18));

    // Yellow: Moving from Top-Left to Bottom-Right
    _a1 = AlignmentTween(begin: const Alignment(-1.2, -1.2), end: const Alignment(0.5, 0.5))
        .animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));

    // Pink: Moving from Top-Right to Bottom-Left
    _a2 = AlignmentTween(begin: const Alignment(1.2, -1.2), end: const Alignment(-0.5, 0.5))
        .animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));

    // Blue: Moving from Left-Center to Right-Center
    _a3 = AlignmentTween(begin: const Alignment(-1.2, 0.0), end: const Alignment(1.2, 0.0))
        .animate(CurvedAnimation(parent: _c3, curve: Curves.easeInOut));

    // Green: Moving from Bottom-Center to Top-Center
    _a4 = AlignmentTween(begin: const Alignment(0.0, 1.2), end: const Alignment(0.0, -1.2))
        .animate(CurvedAnimation(parent: _c4, curve: Curves.easeInOut));

    for (var controller in [_c1, _c2, _c3, _c4]) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var c in [_c1, _c2, _c3, _c4]) { c.dispose(); }
    super.dispose();
  }

  Widget _buildBlob(Color color, Animation<Alignment> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: animation.value,
          child: Container(
            width: MediaQuery.of(context).size.width * 1.5,
            height: MediaQuery.of(context).size.width * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.0)],
                stops: const [0.3, 1.0], // Sharper center for visible color
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
          _buildBlob(colorYellow, _a1),
          _buildBlob(colorPink, _a2),
          _buildBlob(colorBlue, _a3),
          _buildBlob(colorGreen, _a4),
          Positioned.fill(
            child: BackdropFilter(
              // Sigma 70 is the "sweet spot" for noticing movement
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}