import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/org_node_entity.dart';

class OrgNodeWidget extends StatefulWidget {
  final OrgNodeEntity node;
  final int level;
  final ValueChanged<OrgNodeEntity> onNodeTap;
  final ValueChanged<OrgNodeEntity> onLoadChildren;

  const OrgNodeWidget({
    super.key,
    required this.node,
    this.level = 0,
    required this.onNodeTap,
    required this.onLoadChildren,
  });

  @override
  State<OrgNodeWidget> createState() => _OrgNodeWidgetState();
}

class _OrgNodeWidgetState extends State<OrgNodeWidget> {
  bool _expanded = false;

  bool get _expandable =>
      widget.node.children.isNotEmpty || widget.node.canLoadChildren;

  void _handleTap() {
    if (!_expandable) {
      widget.onNodeTap(widget.node);
      return;
    }

    setState(() => _expanded = !_expanded);
    if (_expanded &&
        widget.node.canLoadChildren &&
        !widget.node.childrenLoaded &&
        !widget.node.loadingChildren) {
      widget.onLoadChildren(widget.node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(right: widget.level == 0 ? 0 : 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.level > 0) ...[
                Positioned(
                  right: -12,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: AppColors.charcoal.withValues(alpha: 0.1),
                  ),
                ),
                Positioned(
                  right: -12,
                  top: 36,
                  child: Container(
                    width: 12,
                    height: 2,
                    color: AppColors.charcoal.withValues(alpha: 0.1),
                  ),
                ),
              ],
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, width: 1.2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _handleTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          _NodeIcon(icon: _icon, color: _iconColor),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.node.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.charcoalDark,
                                    fontWeight: widget.node.type ==
                                            OrgNodeType.department
                                        ? AppTextStyles.bold
                                        : AppTextStyles.semiBold,
                                  ),
                                ),
                                if (widget.node.subtitle?.isNotEmpty ==
                                    true) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.node.subtitle!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.charcoal
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.node.type == OrgNodeType.role) ...[
                            const SizedBox(width: 12),
                            const _TypeBadge(text: 'دور'),
                          ],
                          const SizedBox(width: 12),
                          if (_expandable)
                            AnimatedRotation(
                              turns: _expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: const Icon(
                                LucideIcons.chevronDown,
                                color: AppColors.charcoal,
                                size: 20,
                              ),
                            )
                          else
                            IconButton(
                              tooltip: 'عرض التفاصيل',
                              onPressed: () => widget.onNodeTap(widget.node),
                              icon: const Icon(
                                LucideIcons.info,
                                color: AppColors.goldDark,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _expanded ? _childrenContent() : const SizedBox(height: 0),
        ),
      ],
    );
  }

  Widget _childrenContent() {
    if (widget.node.loadingChildren) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.forest,
            ),
          ),
        ),
      );
    }

    if (widget.node.childrenError != null) {
      return Padding(
        padding: EdgeInsets.only(right: (widget.level + 1) * 24, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.node.childrenError!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.umber),
              ),
            ),
            TextButton.icon(
              onPressed: () => widget.onLoadChildren(widget.node),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (widget.node.childrenLoaded && widget.node.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: (widget.level + 1) * 24, bottom: 12),
        child: Text(
          widget.node.type == OrgNodeType.role
              ? 'لا يوجد موظفون مرتبطون بهذا الدور.'
              : 'لا توجد أدوار مرتبطة بهذا القسم.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return Column(
      children: widget.node.children
          .map((child) => OrgNodeWidget(
                key: ValueKey(child.id),
                node: child,
                level: widget.level + 1,
                onNodeTap: widget.onNodeTap,
                onLoadChildren: widget.onLoadChildren,
              ))
          .toList(),
    );
  }

  Color get _backgroundColor {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forestLight.withValues(alpha: 0.08);
      case OrgNodeType.section:
        return AppColors.gold.withValues(alpha: 0.08);
      case OrgNodeType.role:
        return AppColors.goldLight.withValues(alpha: 0.22);
      case OrgNodeType.employee:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forest.withValues(alpha: 0.3);
      case OrgNodeType.section:
      case OrgNodeType.role:
        return AppColors.goldDark.withValues(alpha: 0.3);
      case OrgNodeType.employee:
        return AppColors.charcoal.withValues(alpha: 0.1);
    }
  }

  IconData get _icon {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return LucideIcons.building2;
      case OrgNodeType.section:
        return LucideIcons.network;
      case OrgNodeType.role:
        return LucideIcons.badgeCheck;
      case OrgNodeType.employee:
        return LucideIcons.userCheck;
    }
  }

  Color get _iconColor {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forest;
      case OrgNodeType.section:
      case OrgNodeType.role:
        return AppColors.goldDark;
      case OrgNodeType.employee:
        return AppColors.charcoalDark;
    }
  }
}

class _NodeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NodeIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String text;

  const _TypeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.charcoalDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }
}
