import 'package:flutter/material.dart';

class SidebarItem {
  final IconData icon;
  final String title;
  final bool isSelected;

  const SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
  });
}