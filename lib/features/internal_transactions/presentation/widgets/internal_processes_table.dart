import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_local_data_source.dart';
import '../../domain/entities/internal_process_entity.dart';

class InternalProcessesTable extends StatefulWidget {
  final int categoryId;

  const InternalProcessesTable({
    super.key,
    required this.categoryId,
  });

  @override
  State<InternalProcessesTable> createState() => _InternalProcessesTableState();
}

class _InternalProcessesTableState extends State<InternalProcessesTable> {
  final _dataSource = InternalTransactionsLocalDataSource();

  InternalProcessesPageData? _pageData;
  bool _loading = true;
  int _page = 1;
  static const int _limit = 6;

  @override
  void initState() {
    super.initState();
    _loadProcesses();
  }

  @override
  void didUpdateWidget(covariant InternalProcessesTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryId != widget.categoryId) {
      _page = 1;
      _loadProcesses();
    }
  }

  Future<void> _loadProcesses() async {
    setState(() => _loading = true);

    final data = await _dataSource.getProcessesByCategory(
      categoryId: widget.categoryId == -1 ? 1 : widget.categoryId,
      page: _page,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _pageData = data;
      _loading = false;
    });
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    _loadProcesses();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
      );
    }

    final data = _pageData!;

    return Column(
      children: [
        _Toolbar(),
        const SizedBox(height: 20),
        _Table(items: data.items),
        const SizedBox(height: 16),
        _Pagination(
          page: data.page,
          totalPages: data.totalPages,
          total: data.total,
          limit: data.limit,
          hasNext: data.hasNext,
          hasPrev: data.hasPrev,
          onPageChanged: _goToPage,
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث في المعاملات برقم المعاملة أو النوع...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.goldDark,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('فلتر متقدم'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.charcoalDark,
              backgroundColor: AppColors.white,
              side: BorderSide(color: AppColors.gold.withOpacity(0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final List<InternalProcessEntity> items;

  const _Table({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useHorizontalScroll = constraints.maxWidth < 900;
        final tableWidth = useHorizontalScroll ? 900.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const _TableHeader(),
                  ...items.map((item) => _ProcessRow(item: item)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.goldLight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderCell('رقم المعاملة', flex: 18),
          _HeaderCell('نوع المعاملة', flex: 30),
          _HeaderCell('الأولوية', flex: 14),
          _HeaderCell('الكود', flex: 20),
          _HeaderCell('إجراء', flex: 18),
        ],
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  final InternalProcessEntity item;

  const _ProcessRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.charcoal.withOpacity(0.08)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _BodyCell(
            'TXN-${item.processId}',
            flex: 18,
            color: AppColors.forest,
            fontWeight: FontWeight.w700,
          ),
          Expanded(
            flex: 30,
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TypeIcon(priority: item.priority),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.charcoalDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 14,
            child: Center(
              child: _PriorityBadge(priority: item.priority),
            ),
          ),
          _BodyCell(item.code, flex: 20, color: AppColors.goldDark),
          Expanded(
            flex: 18,
            child: Center(
              child: _DetailsButton(onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(
    this.text, {
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final FontWeight fontWeight;

  const _BodyCell(
    this.text, {
    required this.flex,
    this.color,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color ?? AppColors.charcoal,
          fontSize: 13,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final int priority;

  const _TypeIcon({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority >= 3
        ? AppColors.umber
        : priority == 2
            ? AppColors.goldDark
            : AppColors.forest;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        Icons.account_tree_outlined,
        color: color,
        size: 18,
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final text = priority >= 3
        ? 'عالية'
        : priority == 2
            ? 'متوسطة'
            : 'عادية';

    final color = priority >= 3
        ? AppColors.umber
        : priority == 2
            ? AppColors.goldDark
            : AppColors.forest;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DetailsButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.goldLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'عرض التفاصيل',
              style: TextStyle(
                color: AppColors.forest,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.visibility_outlined,
              size: 16,
              color: AppColors.forest,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int limit;
  final bool hasNext;
  final bool hasPrev;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = total == 0 ? 0 : ((page - 1) * limit) + 1;
    final end = (page * limit).clamp(0, total);

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Text(
          'عرض $start–$end من $total معاملة',
          style: const TextStyle(
            color: AppColors.goldDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _PageButton(
          icon: Icons.chevron_right,
          enabled: hasPrev,
          onTap: () => onPageChanged(page - 1),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          totalPages,
          (index) {
            final pageNumber = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NumberButton(
                number: pageNumber,
                selected: pageNumber == page,
                onTap: () => onPageChanged(pageNumber),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _PageButton(
          icon: Icons.chevron_left,
          enabled: hasNext,
          onTap: () => onPageChanged(page + 1),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.charcoalDark : AppColors.goldDark,
          size: 20,
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final bool selected;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.charcoalDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}