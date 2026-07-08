import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/org_node_entity.dart';

class OrgNodeWidget extends StatefulWidget {
  final OrgNodeEntity node;
  final int level;
  final ValueChanged<OrgNodeEntity> onNodeTap;

  const OrgNodeWidget({
    super.key,
    required this.node,
    this.level = 0,
    required this.onNodeTap,
  });

  @override
  State<OrgNodeWidget> createState() => _OrgNodeWidgetState();
}

class _OrgNodeWidgetState extends State<OrgNodeWidget> {
  bool _isExpanded = false;

  void _toggleExpand() {
    if (widget.node.children.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    } else {
      widget.onNodeTap(widget.node);
    }
  }

  Color _getBackgroundColor() {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forestLight.withOpacity(0.08);
      case OrgNodeType.section:
        return AppColors.gold.withOpacity(0.08);
      case OrgNodeType.employee:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forest.withOpacity(0.3);
      case OrgNodeType.section:
        return AppColors.goldDark.withOpacity(0.3);
      case OrgNodeType.employee:
        return AppColors.charcoal.withOpacity(0.1);
    }
  }

  IconData _getIcon() {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return LucideIcons.building2;
      case OrgNodeType.section:
        return LucideIcons.network;
      case OrgNodeType.employee:
        return LucideIcons.userCheck;
    }
  }

  Color _getIconColor() {
    switch (widget.node.type) {
      case OrgNodeType.department:
        return AppColors.forest;
      case OrgNodeType.section:
        return AppColors.goldDark;
      case OrgNodeType.employee:
        return AppColors.charcoalDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;
    final paddingLeft = widget.level == 0 ? 0.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(right: paddingLeft),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.level > 0)
                Positioned(
                  right: -12,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: AppColors.charcoal.withOpacity(0.1),
                  ),
                ),
              if (widget.level > 0)
                Positioned(
                  right: -12,
                  top: 36,
                  child: Container(
                    width: 12,
                    height: 2,
                    color: AppColors.charcoal.withOpacity(0.1),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getBorderColor(), width: 1.2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _toggleExpand,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getIconColor().withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(_getIcon(), color: _getIconColor(), size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  widget.node.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.charcoalDark,
                                    fontWeight: widget.node.type == OrgNodeType.department
                                        ? AppTextStyles.bold
                                        : AppTextStyles.semiBold,
                                  ),
                                ),
                                if (widget.node.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.node.subtitle!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.charcoal.withOpacity(0.7),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          if (widget.node.role != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.charcoalDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.node.role!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: AppTextStyles.medium,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 16),
                          if (hasChildren)
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                LucideIcons.chevronDown,
                                color: AppColors.charcoal,
                                size: 20,
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(LucideIcons.info, color: AppColors.goldDark, size: 20),
                              onPressed: () => widget.onNodeTap(widget.node),
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: _isExpanded ? null : 0,
            child: Opacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Column(
                children: widget.node.children
                    .map((child) => OrgNodeWidget(
                          node: child,
                          level: widget.level + 1,
                          onNodeTap: widget.onNodeTap,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
