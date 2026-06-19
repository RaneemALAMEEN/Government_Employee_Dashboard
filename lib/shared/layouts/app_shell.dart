import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'side_menu.dart';
import 'top_bar.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool? _userCollapsedOverride;
  bool _wasSmallScreen = false;

  static const double sidebarWidth = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 900;

          // Reset user override if we cross the small screen threshold
          if (_wasSmallScreen != isSmallScreen) {
            _wasSmallScreen = isSmallScreen;
            _userCollapsedOverride = null;
          }

          final isCollapsed = _userCollapsedOverride ?? isSmallScreen;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              Expanded(child: widget.child),
            ],
          );

          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isCollapsed ? 72 : sidebarWidth,
                child: SideMenu(
                  isCollapsed: isCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      _userCollapsedOverride = !isCollapsed;
                    });
                  },
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}