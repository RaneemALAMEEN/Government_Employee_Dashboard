import '../../domain/entities/dashboard_entity.dart';

class DashboardLocalDataSource {
  Future<DashboardEntity> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return DashboardEntity(
      stats: [
        StatEntity(
          title: 'إجمالي الوارد اليوم',
          value: '41',
          subtitle: 'معدل طبيعي',
          type: 'inbox',
        ),
        StatEntity(
          title: 'تم إنجازها اليوم',
          value: '28',
          subtitle: '↑ 14% عن أمس',
          type: 'done',
        ),
        StatEntity(
          title: 'معاملات مستعجلة',
          value: '5',
          subtitle: '2+ هذا الصباح',
          type: 'urgent',
        ),
        StatEntity(
          title: 'بانتظار توقيعك',
          value: '12',
          subtitle: '3+ منذ أمس',
          type: 'sign',
        ),
      ],
      bottlenecks: [
        BottleneckEntity(
          title: 'مراجعة الشؤون القانونية',
          count: '8 معاملات',
          delay: 'متوسط تأخير: 4.2 يوم',
        ),
        BottleneckEntity(
          title: 'توقيع رئيس الدائرة',
          count: '12 معاملة',
          delay: 'متوسط تأخير: 2.1 يوم',
        ),
        BottleneckEntity(
          title: 'المصادقة النهائية',
          count: '5 معاملات',
          delay: 'متوسط تأخير: 1.8 يوم',
        ),
      ],
      completionTime: CompletionTimeEntity(
        averageDays: '2.4',
        comparison: 'أفضل بـ 0.6 يوم عن الشهر الماضي',
        stages: [
          StageTimeEntity(title: 'استلام وتسجيل', days: 0.3, progress: 0.9),
          StageTimeEntity(title: 'مراجعة أولية', days: 0.7, progress: 0.7),
          StageTimeEntity(title: 'اعتماد رئيس الدائرة', days: 1.1, progress: 0.55),
          StageTimeEntity(title: 'إصدار القرار', days: 0.3, progress: 0.9),
        ],
      ),
      weeklyIndicators: [
        WeeklyIndicatorEntity(
          title: 'المعاملات الواردة',
          value: '+18%',
          subtitle: 'مقارنة بالأسبوع الماضي',
          isPositive: true,
        ),
        WeeklyIndicatorEntity(
          title: 'معدل الإنجاز',
          value: '+7%',
          subtitle: 'تحسن ملحوظ',
          isPositive: true,
        ),
        WeeklyIndicatorEntity(
          title: 'المعاملات المرفوضة',
          value: '-3%',
          subtitle: 'انخفاض إيجابي',
          isPositive: false,
        ),
        WeeklyIndicatorEntity(
          title: 'متوسط وقت الاستجابة',
          value: '+12%',
          subtitle: 'يحتاج مراجعة',
          isPositive: false,
        ),
      ],
      latestTransactions: [
        TransactionEntity(
          number: 'TXN-2024-441',
          type: 'طلب وثيقة رسمية',
          applicant: 'خالد أحمد مطر',
          date: '2024-01-31',
          status: 'مستعجل',
          canSign: true,
        ),
        TransactionEntity(
          number: 'TXN-2024-440',
          type: 'نقل موظف',
          applicant: 'سامي يوسف',
          date: '2024-01-31',
          status: 'قيد التنفيذ',
          canSign: false,
        ),
        TransactionEntity(
          number: 'TXN-2024-439',
          type: 'طلب إجازة',
          applicant: 'محمود السيد',
          date: '2024-01-30',
          status: 'مستعجل',
          canSign: true,
        ),
        TransactionEntity(
          number: 'TXN-2024-438',
          type: 'مراسلة رسمية',
          applicant: 'نور الدين حسن',
          date: '2024-01-30',
          status: 'منجز',
          canSign: false,
        ),
      ],
      alerts: [
        'تأخير في معالجة 8 معاملات أكثر من 3 أيام',
        'ازدحام في دائرة الشؤون الإدارية 17 معاملة',
      ],
    );
  }
}