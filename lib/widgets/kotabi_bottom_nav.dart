import 'package:flutter/material.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

class KotabiBottomNav extends StatelessWidget {
  const KotabiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'ホーム'),
    (icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: '検索'),
    (icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'プラン'),
    (icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded, label: 'お気に入り'),
    (icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'マイページ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        boxShadow: [
          BoxShadow(
            color: KotabiColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(top: BorderSide(color: KotabiColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? KotabiColors.primary
                              : KotabiColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? KotabiColors.primary
                                : KotabiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
