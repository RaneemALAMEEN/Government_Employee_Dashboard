import 'dart:async';

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
  bool _showSidebarLabels = true;
  Timer? _sidebarSequenceTimer;

  static const double sidebarWidth = 270;

  @override
  void dispose() {
    _sidebarSequenceTimer?.cancel();
    super.dispose();
  }

  void _toggleSidebar(bool isCollapsed) {
    _sidebarSequenceTimer?.cancel();
    if (!isCollapsed) {
      // Remove every wide child before the width starts shrinking.
      setState(() => _showSidebarLabels = false);
      _sidebarSequenceTimer = Timer(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        setState(() => _userCollapsedOverride = true);
      });
      return;
    }

    // Expand the container first, then restore labels near the end.
    setState(() {
      _userCollapsedOverride = false;
      _showSidebarLabels = false;
    });
    _sidebarSequenceTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _showSidebarLabels = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 900;

          if (_wasSmallScreen != isSmallScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _wasSmallScreen = isSmallScreen;
                _userCollapsedOverride = null;
                _showSidebarLabels = !isSmallScreen;
              });
            });
          }

          final isCollapsed = _userCollapsedOverride ?? isSmallScreen;

          final double currentSidebarWidth = isCollapsed ? 72 : sidebarWidth;
          final double availableWidth =
              constraints.maxWidth - currentSidebarWidth;
          const double minContentWidth = 600.0;
          final double contentWidth = availableWidth < minContentWidth
              ? minContentWidth
              : availableWidth;

          final content = SizedBox(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TopBar(),
                Expanded(child: widget.child),
              ],
            ),
          );

          return Row(
            textDirection: TextDirection.rtl,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: currentSidebarWidth,
                child: AppSidebar(
                  isCollapsed: isCollapsed,
                  showLabels: !isCollapsed && _showSidebarLabels,
                  onToggleCollapse: () => _toggleSidebar(isCollapsed),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: content,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
