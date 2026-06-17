import 'package:flutter/material.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

/// 詳細画面の「口コミ AI要約」カード（mockup準拠）。
class AiReviewSummaryCard extends StatelessWidget {
  const AiReviewSummaryCard({
    super.key,
    required this.points,
  });

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KotabiColors.border),
        boxShadow: const [
          BoxShadow(
            color: KotabiColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: KotabiColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: KotabiColors.primary),
                SizedBox(width: 5),
                Text(
                  'AI要約',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KotabiColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: KotabiColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14,
                        color: KotabiColors.textPrimary,
                        height: 1.55,
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
}
