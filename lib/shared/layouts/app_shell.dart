import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'side_menu.dart';
import 'top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  static const double sidebarWidth = 255;
  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSideBelow = constraints.maxWidth < 900;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              Expanded(child: child),
            ],
          );

          return showSideBelow
              ? Column(
                  children: [
                    Expanded(child: content),
                    const SizedBox(height: gap),
                    const SizedBox(
                      width: double.infinity,
                      child: SideMenu(),
                    ),
                  ],
                )
              : Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(child: content),
                    const SizedBox(
                      width: sidebarWidth,
                      child: SideMenu(),
                    ),
                  ],
                );
        },
      ),
    );
  }
}