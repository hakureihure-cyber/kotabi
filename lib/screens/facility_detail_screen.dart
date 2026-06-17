import 'package:flutter/material.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/services/plan_store.dart';
import 'package:kotabi/theme/kotabi_colors.dart';
import 'package:kotabi/widgets/ai_review_summary_card.dart';
import 'package:kotabi/widgets/primary_button.dart';

class FacilityDetailScreen extends StatelessWidget {
  const FacilityDetailScreen({
    super.key,
    required this.facility,
    required this.planStore,
    required this.onGoToPlan,
  });

  final Facility facility;
  final PlanStore planStore;
  final VoidCallback onGoToPlan;

  static const _childFriendlyFacilities = [
    (icon: Icons.stroller, label: 'ベビーカー貸出'),
    (icon: Icons.child_care, label: 'キッズスペース'),
    (icon: Icons.baby_changing_station, label: '授乳室'),
    (icon: Icons.wc, label: 'おむつ替え'),
    (icon: Icons.local_parking, label: '駐車場'),
    (icon: Icons.restaurant, label: 'キッズメニュー'),
  ];

  void _handleAddToPlan(BuildContext context) {
    final added = planStore.add(facility);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? '${facility.name}をプランに追加しました' : '${facility.name}はすでにプランに追加済みです',
        ),
        action: added
            ? SnackBarAction(
                label: 'プランを見る',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGoToPlan();
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewSummary = facility.reviewSummary.isNotEmpty
        ? facility.reviewSummary
        : const ['口コミは準備中です'];

    return Scaffold(
      backgroundColor: KotabiColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            title: const Text('施設詳細'),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KotabiColors.primary.withValues(alpha: 0.25),
                      KotabiColors.primaryLight,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    facility.icon,
                    size: 88,
                    color: KotabiColors.primary.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: KotabiColors.star, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${facility.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${facility.reviewCount}件の口コミ)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facility.conditions.map(_FeatureChip.new).toList(),
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(title: '滞在・移動の目安'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DurationCard(
                          icon: Icons.schedule,
                          label: '滞在時間目安',
                          value: '${facility.stayMinutes}分',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DurationCard(
                          icon: Icons.directions_car_outlined,
                          label: '移動時間目安',
                          value: '${facility.travelMinutes}分',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(title: '基本情報'),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.location_on_outlined, text: facility.address),
                  _InfoRow(icon: Icons.access_time, text: facility.hours),
                  _InfoRow(icon: Icons.event_busy_outlined, text: facility.closedDays),
                  _InfoRow(icon: Icons.phone_outlined, text: facility.phone),
                  const SizedBox(height: 28),
                  const _SectionHeader(title: '子連れ向け設備'),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: _childFriendlyFacilities.map((item) {
                      return Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: KotabiColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.icon, color: KotabiColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(title: '口コミ AI要約'),
                  const SizedBox(height: 12),
                  AiReviewSummaryCard(points: reviewSummary),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: KotabiColors.surface,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: planStore,
            builder: (context, _) {
              final isInPlan = planStore.contains(facility);
              return PrimaryButton(
                label: isInPlan ? 'プランに追加済み' : 'プランに追加する',
                onPressed: isInPlan ? () {} : () => _handleAddToPlan(context),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final isGreen = label.contains('ベビーカー') || label.contains('キッズ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isGreen ? KotabiColors.chipGreenBg : KotabiColors.chipYellowBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isGreen ? KotabiColors.chipGreenText : KotabiColors.chipYellowText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KotabiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: KotabiColors.primary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: KotabiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: KotabiColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
