import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whispurr_hackathon/theme.dart';

class FabNav extends StatelessWidget {
  final VoidCallback onPressed;
  const FabNav({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: RawMaterialButton(
        fillColor: context.mood.happy,
        shape: CircleBorder(
          side: BorderSide(
            width: 0.5
          )
        ),
        elevation: 4.0,
        onPressed: onPressed,
        child: SvgPicture.asset(
          "assets/icons/ghost_kitty.svg",
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: 45,
          height: 45,
        ),
      ),
    );
  }
}