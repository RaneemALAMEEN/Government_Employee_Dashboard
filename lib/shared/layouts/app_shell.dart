import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'responsive_layout.dart';
import 'side_menu.dart';
import 'top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.goldLight,
        body: ResponsiveLayout(
          desktop: Row(
            textDirection: TextDirection.rtl,
            children: [
              const SideMenu(width: 235),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
          tablet: Row(
            textDirection: TextDirection.rtl,
            children: [
              const SideMenu(width: 230),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
          mobile: Column(
            children: [
              const TopBar(),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
