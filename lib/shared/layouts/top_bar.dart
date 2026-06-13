import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 1050;
    final isVeryNarrow = width < 700;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: isVeryNarrow ? 16 : 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.charcoal.withOpacity(0.10),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          if (!isVeryNarrow) ...[
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.forest,
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            if (!isCompact)
              const _UserInfo()
            else
              const SizedBox(
                width: 90,
                child: _UserInfo(compact: true),
              ),
            const Spacer(flex: 2),
          ] else
            const Spacer(),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isVeryNarrow ? 220 : 300,
                minWidth: 120,
              ),
              child: const _SearchBox(),
            ),
          ),
          const SizedBox(width: 14),
          const _NotificationButton(),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final bool compact;

  const _UserInfo({
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 90 : 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'محمد العمر',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.charcoalDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'رئيس الدائرة',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.forest,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.charcoalDark,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.goldLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.45)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.45)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.forest),
          ),
          hintText: 'بحث في المعاملات...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.goldDark,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
            color: AppColors.goldDark,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 11,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.forestLight.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.forest,
            size: 22,
          ),
        ),
        Positioned(
          top: 8,
          right: 9,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.umber,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
