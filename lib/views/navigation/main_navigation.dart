import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whispurr_hackathon/theme.dart';

class MainNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const MainNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.black,
      shape: null,
      // Lowering height slightly to look more standard,
      // but keeping enough room for text labels
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Group
            Row(
              children: [
                _buildNavItem(context, "assets/icons/home.svg", "Home", 0),
                const SizedBox(width: 30),
                _buildNavItem(context, "assets/icons/calendar.svg", "Calendar", 1),
              ],
            ),
            // Right Group
            Row(
              children: [
                _buildNavItem(context, "assets/icons/notepad.svg", "Notes", 2),
                const SizedBox(width: 30),
                _buildNavItem(context, "assets/icons/user.svg", "Account", 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, dynamic iconSource, String label, int index) {
    bool isSelected = currentIndex == index;
    Color activeColor = const Color(0xffB0FF96);
    Color iconColor = isSelected ? activeColor : Colors.grey;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque, // Makes the whole area clickable
      child: Column(
        mainAxisSize: MainAxisSize.min, // Constrains the column to its content
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconSource is String
              ? SvgPicture.asset(
            iconSource,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: 28, // Scaled down slightly to fit better with text
            height: 28,
          )
              : Icon(iconSource, color: iconColor, size: 28),
          const SizedBox(height: 4), // Small gap between icon and text
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: iconColor,
              fontSize: 10, // Small, clean labels
            ),
          ),
        ],
      ),
    );
  }
}