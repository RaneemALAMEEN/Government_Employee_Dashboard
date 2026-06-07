import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AlertsCard extends StatelessWidget {
  final List<String> alerts;

  const AlertsCard({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'التنبيهات التشغيلية',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forest,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.notifications_none, size: 18, color: AppColors.umber),
            ],
          ),
          const SizedBox(height: 17),
          ...alerts.take(2).map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AlertItem(text: alert),
                ),
              ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String text;

  const _AlertItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.umber.withOpacity(0.055),
        borderRadius: BorderRadius.circular(7),
        border: Border(
          right: BorderSide(
            color: AppColors.umber.withOpacity(0.8),
            width: 2,
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w400,
                color: AppColors.umber,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.warning_amber, color: AppColors.umber, size: 18),
        ],
      ),
    );
  }
} 