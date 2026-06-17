import 'package:flutter/material.dart';
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/screens/facility_detail_screen.dart';
import 'package:kotabi/services/facility_repository.dart';
import 'package:kotabi/services/plan_store.dart';
import 'package:kotabi/services/search_criteria_store.dart';
import 'package:kotabi/theme/kotabi_colors.dart';
import 'package:kotabi/widgets/primary_button.dart';

class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({
    super.key,
    required this.facilityRepository,
    required this.searchCriteriaStore,
    required this.planStore,
    required this.onGoToPlan,
  });

  final FacilityRepository facilityRepository;
  final SearchCriteriaStore searchCriteriaStore;
  final PlanStore planStore;
  final VoidCallback onGoToPlan;

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  List<Facility> _facilities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.searchCriteriaStore.addListener(_loadFacilities);
    _loadFacilities();
  }

  @override
  void dispose() {
    widget.searchCriteriaStore.removeListener(_loadFacilities);
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final facilities = await widget.facilityRepository.searchFacilities(
        criteria: widget.searchCriteriaStore.criteria,
      );
      if (mounted) {
        setState(() {
          _facilities = facilities;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openDetail(Facility facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilityDetailScreen(
          facility: facility,
          planStore: widget.planStore,
          onGoToPlan: widget.onGoToPlan,
        ),
      ),
    );
  }

  void _addToPlan(Facility facility) {
    final added = widget.planStore.add(facility);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? '${facility.name}をプランに追加しました' : '${facility.name}はすでにプランに追加済みです',
        ),
        action: added
            ? SnackBarAction(
                label: 'プランを見る',
                onPressed: widget.onGoToPlan,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = widget.searchCriteriaStore.criteria.activeFilterLabels;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                const Expanded(
                  child: Text(
                    '施設を探す',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: KotabiColors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('絞り込み'),
                  style: TextButton.styleFrom(
                    foregroundColor: KotabiColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (!GoogleMapsConfig.isConfigured)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KotabiColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Places API 未設定: モック＋自前DBデータを表示中',
                  style: TextStyle(fontSize: 12, color: KotabiColors.textSecondary),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: activeFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: KotabiColors.chipBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    activeFilters[index],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KotabiColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: KotabiColors.primary),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: KotabiColors.textSecondary),
                  ),
                ),
              ),
            )
          else if (_facilities.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: KotabiColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '条件に合う施設が見つかりませんでした',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: KotabiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'エリアや条件を変更して、\nもう一度お試しください',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: KotabiColors.textSecondary.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                '該当件数：${_facilities.length}件',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: KotabiColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _facilities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final facility = _facilities[index];
                  return ListenableBuilder(
                    listenable: widget.planStore,
                    builder: (context, _) {
                      return _FacilityCard(
                        facility: facility,
                        isInPlan: widget.planStore.contains(facility),
                        onTap: () => _openDetail(facility),
                        onAddToPlan: () => _addToPlan(facility),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.isInPlan,
    required this.onTap,
    required this.onAddToPlan,
  });

  final Facility facility;
  final bool isInPlan;
  final VoidCallback onTap;
  final VoidCallback onAddToPlan;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KotabiColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KotabiColors.border),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: facility.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(facility.icon, color: facility.color, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: KotabiColors.textPrimary,
                            ),
                          ),
                        ),
                        if (facility.placeId != null)
                          Tooltip(
                            message: 'place_id: ${facility.placeId}',
                            child: const Icon(
                              Icons.link,
                              size: 16,
                              color: KotabiColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: KotabiColors.star, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${facility.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${facility.reviewCount}件)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: KotabiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: facility.conditions.map((tag) {
                        final isGreen = tag.contains('ベビーカー') || tag.contains('キッズ');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isGreen ? KotabiColors.chipGreenBg : KotabiColors.chipYellowBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: isGreen ? KotabiColors.chipGreenText : KotabiColors.chipYellowText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (facility.conditions.isEmpty)
                      const Text(
                        '自前DB: 子連れ情報未登録',
                        style: TextStyle(
                          fontSize: 11,
                          color: KotabiColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: KotabiColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          facility.stayDurationLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: KotabiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: isInPlan
                          ? Text(
                              'プランに追加済み',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: KotabiColors.primary.withValues(alpha: 0.7),
                              ),
                            )
                          : AddToPlanButton(onPressed: onAddToPlan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
