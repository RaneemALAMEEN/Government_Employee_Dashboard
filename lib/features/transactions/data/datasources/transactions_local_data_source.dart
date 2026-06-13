import '../../domain/entities/transaction_entity.dart';

class TransactionsLocalDataSource {
  Future<List<TransactionEntity>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      TransactionEntity(
        id: 'TXN-2024-441',
        type: 'طلب وثيقة رسمية',
        applicant: 'خالد أحمد مطر',
        department: 'الشؤون الإدارية',
        date: '2024-01-29',
        priority: 'عالية',
        status: 'بانتظار توقيعي',
        needsSignature: true,
        isUrgent: true,
      ),
      TransactionEntity(
        id: 'TXN-2024-439',
        type: 'طلب إجازة',
        applicant: 'محمود السيد علي',
        department: 'التعليم الأساسي',
        date: '2024-01-30',
        priority: 'عالية',
        status: 'بانتظار توقيعي',
        needsSignature: true,
        isUrgent: true,
      ),
      TransactionEntity(
        id: 'TXN-2024-435',
        type: 'نقل موظف',
        applicant: 'ليلى عمران',
        department: 'الموارد البشرية',
        date: '2024-01-28',
        priority: 'عادية',
        status: 'بانتظار توقيعي',
        needsSignature: true,
        isUrgent: false,
      ),
      TransactionEntity(
        id: 'TXN-2024-432',
        type: 'تثبيت مدرس',
        applicant: 'سامر حسين',
        department: 'التعليم الأساسي',
        date: '2024-01-27',
        priority: 'عادية',
        status: 'بانتظار توقيعي',
        needsSignature: true,
        isUrgent: false,
      ),
      TransactionEntity(
        id: 'TXN-2024-428',
        type: 'طلب صيانة مدرسة',
        applicant: 'مديرية الأبنية',
        department: 'الأبنية والصيانة',
        date: '2024-01-25',
        priority: 'عالية',
        status: 'بانتظار توقيعي',
        needsSignature: true,
        isUrgent: true,
      ),
      TransactionEntity(
        id: 'TXN-2024-420',
        type: 'مراسلة رسمية',
        applicant: 'وحدة التخطيط',
        department: 'التخطيط',
        date: '2024-01-22',
        priority: 'عادية',
        status: 'منجزة',
        needsSignature: false,
        isUrgent: false,
      ),
      TransactionEntity(
        id: 'TXN-2024-415',
        type: 'طلب وثيقة رسمية',
        applicant: 'ناجي سليم',
        department: 'الشؤون الإدارية',
        date: '2024-01-20',
        priority: 'منخفضة',
        status: 'تم الرفض',
        needsSignature: false,
        isUrgent: false,
      ),
    ];
  }
}