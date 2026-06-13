import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_process_entity.dart';

class InternalTransactionsLocalDataSource {
  Future<List<InternalCategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      InternalCategoryEntity(
        id: 1,
        name: 'تحويل طالب',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 2,
        name: 'الموارد البشرية',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 3,
        name: 'شؤون المدرسين',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 4,
        name: 'المراسلات الوزارية',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 5,
        name: 'الإحصائيات والدراسات',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 6,
        name: 'الأبنية والصيانة',
        isActive: true,
      ),
      InternalCategoryEntity(
        id: 7,
        name: 'المعلوماتية والدعم التقني',
        isActive: true,
      ),
    ];
  }

  Future<InternalProcessesPageData> getProcessesByCategory({
    required int categoryId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final allItems = _itemsByCategory(categoryId);

    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, allItems.length);

    final items = start >= allItems.length ? <InternalProcessEntity>[] : allItems.sublist(start, end);

    final totalPages = (allItems.length / limit).ceil();

    return InternalProcessesPageData(
      items: items,
      page: page,
      limit: limit,
      total: allItems.length,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    );
  }

  List<InternalProcessEntity> _itemsByCategory(int categoryId) {
    switch (categoryId) {
      case 1:
        return const [
          InternalProcessEntity(
            processId: 101,
            name: 'تحويل طالب بين المدارس',
            code: 'PROC-STU-101',
            priority: 2,
          ),
          InternalProcessEntity(
            processId: 102,
            name: 'نقل طالب داخلي',
            code: 'PROC-STU-102',
            priority: 1,
          ),
          InternalProcessEntity(
            processId: 103,
            name: 'تعديل بيانات طالب',
            code: 'PROC-STU-103',
            priority: 1,
          ),
          InternalProcessEntity(
            processId: 104,
            name: 'تثبيت قيد طالب',
            code: 'PROC-STU-104',
            priority: 2,
          ),
        ];
      case 2:
        return const [
          InternalProcessEntity(
            processId: 201,
            name: 'نقل موظف',
            code: 'PROC-HR-201',
            priority: 2,
          ),
          InternalProcessEntity(
            processId: 202,
            name: 'طلب إجازة',
            code: 'PROC-HR-202',
            priority: 1,
          ),
          InternalProcessEntity(
            processId: 203,
            name: 'استقالة موظف',
            code: 'PROC-HR-203',
            priority: 3,
          ),
          InternalProcessEntity(
            processId: 204,
            name: 'تعديل نصاب',
            code: 'PROC-HR-204',
            priority: 1,
          ),
        ];
      default:
        return const [
          InternalProcessEntity(
            processId: 301,
            name: 'طلب داخلي جديد',
            code: 'PROC-GEN-301',
            priority: 1,
          ),
          InternalProcessEntity(
            processId: 302,
            name: 'معاملة إدارية',
            code: 'PROC-GEN-302',
            priority: 2,
          ),
          InternalProcessEntity(
            processId: 303,
            name: 'اعتماد معاملة',
            code: 'PROC-GEN-303',
            priority: 1,
          ),
        ];
    }
  }
}

class InternalProcessesPageData {
  final List<InternalProcessEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const InternalProcessesPageData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}