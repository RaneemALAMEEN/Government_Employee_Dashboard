import 'dart:async';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../../features/department_transactions/data/datasources/department_transactions_remote_data_source.dart';
import '../../features/department_transactions/data/models/department_transaction_model.dart';
import '../../features/department_transactions/domain/entities/department_transaction_entity.dart';
import '../../features/internal_transactions/data/datasources/internal_transactions_remote_data_source.dart';
import '../../features/internal_transactions/domain/entities/internal_transaction_entity.dart';
import '../../features/internal_transactions/domain/entities/internal_transactions_page_entity.dart';
import '../../features/my_transactions/data/datasources/my_transactions_remote_data_source.dart';
import '../../features/my_transactions/data/models/my_transaction_model.dart';
import '../../features/my_transactions/domain/entities/my_transaction_entity.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_empty_search_state.dart';

class GlobalSearchBox extends StatefulWidget {
  const GlobalSearchBox({super.key});

  @override
  State<GlobalSearchBox> createState() => _GlobalSearchBoxState();
}

class _GlobalSearchBoxState extends State<GlobalSearchBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;

  bool _isSearching = false;
  bool _hasSearched = false;

  List<MyTransactionEntity> _myTxResults = [];
  List<DepartmentTransactionEntity> _deptTxResults = [];
  List<InternalTransactionEntity> _internalTxResults = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _closeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_controller.text.trim().length >= 2) {
        _showOverlay();
      }
    }
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    final query = text.trim();

    if (query.isEmpty) {
      setState(() {
        _myTxResults = [];
        _deptTxResults = [];
        _internalTxResults = [];
        _isSearching = false;
        _hasSearched = false;
      });
      _closeOverlay();
      return;
    }

    if (query.length < 2) {
      _closeOverlay();
      return;
    }

    _showOverlay();
    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    final activeRole = getIt<SessionService>().activeRoleNotifier.value;
    final deptId = activeRole?.departmentId.toString() ?? '1';

    try {
      // 1. My Transactions Search API
      final myTxFuture = getIt<MyTransactionsRemoteDataSource>().searchTasks(
        status: '',
        query: query,
        limit: 8,
      );

      // 2. Department Transactions Search APIs (Completed & Rejected)
      final deptCompletedFuture =
          getIt<DepartmentTransactionsRemoteDataSource>()
              .searchCompletedTransactions(
        departmentIds: deptId,
        query: query,
        limit: 8,
      );

      final deptRejectedFuture =
          getIt<DepartmentTransactionsRemoteDataSource>()
              .searchRejectedTransactions(
        departmentIds: deptId,
        query: query,
        limit: 8,
      );

      // 3. Internal Transactions Search API
      final internalTxFuture = getIt<InternalTransactionsRemoteDataSource>()
          .getMyTransactions(
        page: 1,
        limit: 12,
        search: query,
      );

      final results = await Future.wait([
        myTxFuture,
        deptCompletedFuture,
        deptRejectedFuture,
        internalTxFuture.catchError(
          (_) => const InternalTransactionsPageEntity(
            items: [],
            page: 1,
            limit: 10,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
        ),
      ]);

      if (!mounted) return;

      final List<MyTransactionEntity> parsedMyTx = [];
      final List<DepartmentTransactionEntity> parsedDeptTx = [];
      final List<InternalTransactionEntity> parsedInternalTx = [];

      // Parse My Transactions
      final myTxRes = results[0];
      if (myTxRes is dartz.Either) {
        myTxRes.fold(
          (failure) {},
          (data) {
            if (data is Map && data['data'] != null) {
              final dataMap = data['data'];
              final items = dataMap['items'] as List? ??
                  dataMap['tasks'] as List? ??
                  [];
              for (final item in items) {
                if (item is Map) {
                  parsedMyTx.add(
                    MyTransactionModel.fromJson(Map<String, dynamic>.from(item)),
                  );
                }
              }
            }
          },
        );
      }

      // Parse Dept Transactions (Completed)
      final deptCompRes = results[1];
      if (deptCompRes is dartz.Either) {
        deptCompRes.fold(
          (failure) {},
          (data) {
            if (data is Map && data['data'] != null) {
              final dataMap = data['data'];
              final items = dataMap['items'] as List? ??
                  dataMap['transactions'] as List? ??
                  [];
              for (final item in items) {
                if (item is Map) {
                  parsedDeptTx.add(
                    DepartmentTransactionModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  );
                }
              }
            }
          },
        );
      }

      // Parse Dept Transactions (Rejected)
      final deptRejRes = results[2];
      if (deptRejRes is dartz.Either) {
        deptRejRes.fold(
          (failure) {},
          (data) {
            if (data is Map && data['data'] != null) {
              final dataMap = data['data'];
              final items = dataMap['items'] as List? ??
                  dataMap['transactions'] as List? ??
                  [];
              for (final item in items) {
                if (item is Map) {
                  final model = DepartmentTransactionModel.fromJson(
                    Map<String, dynamic>.from(item),
                  );
                  if (!parsedDeptTx
                      .any((t) => t.transactionId == model.transactionId)) {
                    parsedDeptTx.add(model);
                  }
                }
              }
            }
          },
        );
      }

      // Parse Internal Transactions
      final internalRes = results[3];
      if (internalRes is InternalTransactionsPageEntity) {
        final q = query.trim().toLowerCase();
        for (final item in internalRes.items) {
          if (item.status.toLowerCase() == 'draft') continue;
          final match = q.isEmpty ||
              item.idProcess.toLowerCase().contains(q) ||
              item.processDefinitionName.toLowerCase().contains(q) ||
              item.stageName.toLowerCase().contains(q) ||
              item.status.toLowerCase().contains(q) ||
              item.transactionId.toString().contains(q);
          if (match) {
            parsedInternalTx.add(item);
          }
        }
      }

      setState(() {
        _myTxResults = parsedMyTx;
        _deptTxResults = parsedDeptTx;
        _internalTxResults = parsedInternalTx;
        _isSearching = false;
        _hasSearched = true;
      });

      _overlayEntry?.markNeedsBuild();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _focusNode.unfocus();
                _closeOverlay();
              },
            ),
          ),
          // Positioned dropdown
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _SearchResultsDropdown(
                  query: _controller.text.trim(),
                  isSearching: _isSearching,
                  hasSearched: _hasSearched,
                  myTxResults: _myTxResults,
                  deptTxResults: _deptTxResults,
                  internalTxResults: _internalTxResults,
                  onSelectMyTransaction: (item) {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.go('/my-transactions/${item.idTask}', extra: {
                      'status': item.status,
                      'transaction_id':
                          item.transactionId?.toString() ?? item.idTask,
                      'is_locked_by_me': item.isLockedByMe,
                    });
                  },
                  onSelectDeptTransaction: (item) {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.push(
                      '/department-transaction-details/${item.transactionId}',
                    );
                  },
                  onSelectInternalTransaction: (item) {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.push(
                      '/internal-transactions/${item.transactionId}/first-stage',
                      extra: item,
                    );
                  },
                  onNavigateToMyTransactions: () {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.go('/my-transactions');
                  },
                  onNavigateToDepartmentTransactions: () {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.go('/department-transactions');
                  },
                  onNavigateToInternalTransactions: () {
                    _closeOverlay();
                    _focusNode.unfocus();
                    context.go('/internal-transactions');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _myTxResults = [];
      _deptTxResults = [];
      _internalTxResults = [];
      _isSearching = false;
      _hasSearched = false;
    });
    _closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: 320,
        height: 42,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.charcoalDark,
            ),
            decoration: InputDecoration(
              hintText: 'بحث برقم المعاملة أو الاسم أو النوع...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.65),
                fontSize: 12.5,
              ),
              prefixIcon: const Icon(
                LucideIcons.search,
                size: 18,
                color: AppColors.charcoal,
              ),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.forest,
                        ),
                      ),
                    )
                  : (_controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 16,
                            color: AppColors.charcoal,
                          ),
                          onPressed: _clearSearch,
                          tooltip: 'مسح البحث',
                        )
                      : null),
              filled: true,
              fillColor: AppColors.goldLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.forest,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultsDropdown extends StatefulWidget {
  final String query;
  final bool isSearching;
  final bool hasSearched;
  final List<MyTransactionEntity> myTxResults;
  final List<DepartmentTransactionEntity> deptTxResults;
  final List<InternalTransactionEntity> internalTxResults;
  final ValueChanged<MyTransactionEntity> onSelectMyTransaction;
  final ValueChanged<DepartmentTransactionEntity> onSelectDeptTransaction;
  final ValueChanged<InternalTransactionEntity> onSelectInternalTransaction;
  final VoidCallback onNavigateToMyTransactions;
  final VoidCallback onNavigateToDepartmentTransactions;
  final VoidCallback onNavigateToInternalTransactions;

  const _SearchResultsDropdown({
    required this.query,
    required this.isSearching,
    required this.hasSearched,
    required this.myTxResults,
    required this.deptTxResults,
    required this.internalTxResults,
    required this.onSelectMyTransaction,
    required this.onSelectDeptTransaction,
    required this.onSelectInternalTransaction,
    required this.onNavigateToMyTransactions,
    required this.onNavigateToDepartmentTransactions,
    required this.onNavigateToInternalTransactions,
  });

  @override
  State<_SearchResultsDropdown> createState() => _SearchResultsDropdownState();
}

class _SearchResultsDropdownState extends State<_SearchResultsDropdown> {
  int _activeTabIndex = 0; // 0: الكل, 1: معاملاتي, 2: معاملات الدائرة, 3: المعاملات الداخلية

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.myTxResults.length +
        widget.deptTxResults.length +
        widget.internalTxResults.length;

    return Container(
      width: 520,
      constraints: const BoxConstraints(maxHeight: 540),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.forestLight.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.search,
                          size: 16,
                          color: AppColors.forest,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نتائج البحث عن "${widget.query}"',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: AppTextStyles.semiBold,
                            color: AppColors.charcoalDark,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isSearching)
                      Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.forest,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'جاري البحث...',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.forest,
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalCount نتيجة',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: AppTextStyles.bold,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterTabChip(
                        label: 'الكل',
                        count: totalCount,
                        isSelected: _activeTabIndex == 0,
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 0;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterTabChip(
                        label: 'معاملاتي',
                        count: widget.myTxResults.length,
                        isSelected: _activeTabIndex == 1,
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 1;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterTabChip(
                        label: 'معاملات الدائرة',
                        count: widget.deptTxResults.length,
                        isSelected: _activeTabIndex == 2,
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 2;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterTabChip(
                        label: 'المعاملات الداخلية',
                        count: widget.internalTxResults.length,
                        isSelected: _activeTabIndex == 3,
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 3;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Flexible(
            child: _buildResultsList(),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldLight.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(13),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onNavigateToMyTransactions,
                    icon: const Icon(LucideIcons.user,
                        size: 14, color: AppColors.forest),
                    label: const Text(
                      'معاملاتي',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: widget.onNavigateToDepartmentTransactions,
                    icon: const Icon(LucideIcons.building2,
                        size: 14, color: AppColors.forest),
                    label: const Text(
                      'معاملات الدائرة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: widget.onNavigateToInternalTransactions,
                    icon: const Icon(LucideIcons.fileSpreadsheet,
                        size: 14, color: AppColors.forest),
                    label: const Text(
                      'المعاملات الداخلية',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (widget.isSearching &&
        widget.myTxResults.isEmpty &&
        widget.deptTxResults.isEmpty &&
        widget.internalTxResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.forest),
              SizedBox(height: 16),
              Text(
                'جاري البحث عبر النظام...',
                style: TextStyle(color: AppColors.charcoal, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final showMyTx = _activeTabIndex == 0 || _activeTabIndex == 1;
    final showDeptTx = _activeTabIndex == 0 || _activeTabIndex == 2;
    final showInternalTx = _activeTabIndex == 0 || _activeTabIndex == 3;

    final visibleMyTx = showMyTx ? widget.myTxResults : <MyTransactionEntity>[];
    final visibleDeptTx =
        showDeptTx ? widget.deptTxResults : <DepartmentTransactionEntity>[];
    final visibleInternalTx =
        showInternalTx ? widget.internalTxResults : <InternalTransactionEntity>[];

    if (widget.hasSearched &&
        visibleMyTx.isEmpty &&
        visibleDeptTx.isEmpty &&
        visibleInternalTx.isEmpty) {
      return AppEmptySearchState(
        title: 'لا توجد نتائج تطابق "${widget.query}"',
        description: 'تأكد من كتابة الاسم أو رقم المعاملة بدقة وحاول مجدداً.',
        isCard: false,
        svgWidth: 110,
        svgHeight: 110,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      children: [
        if (showMyTx && widget.myTxResults.isNotEmpty) ...[
          _SectionHeader(
            icon: LucideIcons.userCheck,
            title: 'معاملاتي الخاصة',
            count: widget.myTxResults.length,
          ),
          ...widget.myTxResults.map(
            (item) => _MyTransactionResultCard(
              item: item,
              onTap: () => widget.onSelectMyTransaction(item),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (showDeptTx && widget.deptTxResults.isNotEmpty) ...[
          _SectionHeader(
            icon: LucideIcons.building2,
            title: 'معاملات الدائرة',
            count: widget.deptTxResults.length,
          ),
          ...widget.deptTxResults.map(
            (item) => _DeptTransactionResultCard(
              item: item,
              onTap: () => widget.onSelectDeptTransaction(item),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (showInternalTx && widget.internalTxResults.isNotEmpty) ...[
          _SectionHeader(
            icon: LucideIcons.fileSpreadsheet,
            title: 'المعاملات الداخلية',
            count: widget.internalTxResults.length,
          ),
          ...widget.internalTxResults.map(
            (item) => _InternalTransactionResultCard(
              item: item,
              onTap: () => widget.onSelectInternalTransaction(item),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FilterTabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTabChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.forest : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.forest
                  : AppColors.gold.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.forest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.forest),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: AppTextStyles.bold,
              color: AppColors.charcoalDark,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.forest,
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 1,
            width: 100,
            color: AppColors.gold.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _MyTransactionResultCard extends StatelessWidget {
  final MyTransactionEntity item;
  final VoidCallback onTap;

  const _MyTransactionResultCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.forestLight.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forest.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.number.isNotEmpty
                                ? item.number
                                : 'معاملة #${item.transactionId ?? item.idTask}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                        ),
                        if (item.isLockedByMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF93C5FD),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.userCheck,
                                  size: 11,
                                  color: Color(0xFF1D4ED8),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'مستلمة بواسطتي',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    _StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.type.isNotEmpty ? item.type : item.processName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.applicant.isNotEmpty) ...[
                      const Icon(LucideIcons.user,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.applicant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                    if (item.date.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.calendar,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.charcoal.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronLeft,
                      size: 14,
                      color: AppColors.forest,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeptTransactionResultCard extends StatelessWidget {
  final DepartmentTransactionEntity item;
  final VoidCallback onTap;

  const _DeptTransactionResultCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.forestLight.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item.transactionNumber.isNotEmpty
                            ? item.transactionNumber
                            : 'معاملة دائرة #${item.transactionId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                    ),
                    _StatusBadge(
                      status: item.statusLabel.isNotEmpty
                          ? item.statusLabel
                          : item.status,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.type.isNotEmpty ? item.type : item.processName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.applicantName.isNotEmpty) ...[
                      const Icon(LucideIcons.user,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.applicantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                    if (item.department.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.building,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.department,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                    if (item.date.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.calendar,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.charcoal.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronLeft,
                      size: 14,
                      color: AppColors.forest,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InternalTransactionResultCard extends StatelessWidget {
  final InternalTransactionEntity item;
  final VoidCallback onTap;

  const _InternalTransactionResultCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.forestLight.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forestLight.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.idProcess.isNotEmpty
                                ? item.idProcess
                                : 'معاملة #${item.transactionId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${item.progressPercent}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.processDefinitionName.isNotEmpty
                      ? item.processDefinitionName
                      : 'معاملة داخلية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.stageName.isNotEmpty) ...[
                      const Icon(LucideIcons.gitCommit,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.stageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                    if (item.createdAt.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.calendar,
                          size: 12, color: AppColors.charcoal),
                      const SizedBox(width: 4),
                      Text(
                        item.createdAt.length >= 10
                            ? item.createdAt.substring(0, 10)
                            : item.createdAt,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.charcoal.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronLeft,
                      size: 14,
                      color: AppColors.forest,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status;

    switch (status) {
      case 'منجزة':
      case 'منجز':
      case 'completed':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        label = 'منجزة';
        break;
      case 'مرفوضة':
      case 'تم الرفض':
      case 'rejected':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        label = 'مرفوضة';
        break;
      case 'قيد المعالجة':
      case 'قيد التنفيذ':
      case 'in_progress':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        label = 'قيد المعالجة';
        break;
      case 'مقدمة':
      case 'submitted':
        bg = const Color(0xFFEAF3F0);
        fg = AppColors.forest;
        label = 'مقدمة';
        break;
      case 'ملغاة':
      case 'cancelled':
        bg = const Color(0xFFF8EDEF);
        fg = AppColors.umber;
        label = 'ملغاة';
        break;
      case 'بانتظار الاستلام':
      case 'pending_pickup':
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
        label = 'بانتظار الاستلام';
        break;
      default:
        bg = AppColors.goldLight;
        fg = AppColors.charcoalDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
