import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';

class SelfCardModeSelector extends StatelessWidget {
  const SelfCardModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelfCardsBloc, SelfCardsState>(
      buildWhen: (prev, curr) => prev.viewMode != curr.viewMode,
      builder: (context, state) {
        final isSearchMode = state.viewMode == SelfCardViewMode.search;

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Tab 1: Standard Search
              Expanded(
                child: _ModeTabButton(
                  title: 'البحث في السجلات الذاتية',
                  subtitle: 'البحث بالاسم والرقم الوطني أو الذاتي',
                  icon: LucideIcons.idCard,
                  isSelected: isSearchMode,
                  onTap: () {
                    if (!isSearchMode) {
                      context.read<SelfCardsBloc>().add(
                            const ChangeSelfCardViewModeEvent(
                              SelfCardViewMode.search,
                            ),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Tab 2: Training Recommendation
              Expanded(
                child: _ModeTabButton(
                  title: 'ترشيح حسب الدورات التدريبية',
                  subtitle: 'ترشيح البطاقات التي لم تحضر دورة معينة',
                  icon: LucideIcons.graduationCap,
                  badge: 'ذكي',
                  isSelected: !isSearchMode,
                  onTap: () {
                    if (isSearchMode) {
                      context.read<SelfCardsBloc>().add(
                            const ChangeSelfCardViewModeEvent(
                              SelfCardViewMode.recommendByTraining,
                            ),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.forest.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.forest.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.forest
                    : AppColors.forest.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.forest,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.forest
                              : AppColors.charcoalDark,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB9A779), Color(0xFFD4AF37)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.charcoal.withValues(alpha: 0.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
