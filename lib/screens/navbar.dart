import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const Navbar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index) {
    return IconButton(
      icon: Icon(
        currentIndex == index ? activeIcon : icon,
        color: currentIndex == index ? Colors.black : Colors.grey,
      ),
      onPressed: () => onTabSelected(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 0),
              _buildNavItem(Icons.search_outlined, Icons.search, 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.favorite_border, Icons.favorite, 2),
              _buildNavItem(Icons.person_outline, Icons.person, 3),
            ],
          ),
        ),
      ),
    );
  }
}
