import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';

class SelfCardSearchHeader extends StatefulWidget {
  const SelfCardSearchHeader({super.key});

  @override
  State<SelfCardSearchHeader> createState() => _SelfCardSearchHeaderState();
}

class _SelfCardSearchHeaderState extends State<SelfCardSearchHeader> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, bool activeOnly) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<SelfCardsBloc>().add(
            SearchSelfCardsEvent(
              query: query.trim(),
              activeOnly: activeOnly,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelfCardsBloc, SelfCardsState>(
      buildWhen: (prev, curr) =>
          prev.isSearching != curr.isSearching ||
          prev.activeOnly != curr.activeOnly,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.idCard,
                      color: AppColors.forest,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'البحث في السجلات الذاتية للموظفين',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ابحث بالاسم، الرقم الوطني، أو الرقم الذاتي لعرض البطاقة الذاتية الكاملة وتصديرها كملف PDF',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: AppSearchField(
                      controller: _searchController,
                      isLoading: state.isSearching,
                      hintText: 'ابحث بالاسم الكامل، الرقم الوطني (11 خانة)، أو الرقم الذاتي...',
                      onChanged: (val) => _onSearchChanged(val, state.activeOnly),
                      onSubmitted: (val) {
                        _debounce?.cancel();
                        context.read<SelfCardsBloc>().add(
                              SearchSelfCardsEvent(
                                query: val.trim(),
                                activeOnly: state.activeOnly,
                              ),
                            );
                      },
                      onClear: () {
                        _onSearchChanged('', state.activeOnly);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      _debounce?.cancel();
                      context.read<SelfCardsBloc>().add(
                            SearchSelfCardsEvent(
                              query: _searchController.text.trim(),
                              activeOnly: state.activeOnly,
                            ),
                          );
                    },
                    icon: const Icon(LucideIcons.search, size: 18),
                    label: const Text('بحث'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
