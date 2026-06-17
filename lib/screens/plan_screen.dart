import 'package:flutter/material.dart';
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/models/schedule_entry.dart';
import 'package:kotabi/models/travel_mode.dart';
import 'package:kotabi/services/plan_store.dart';
import 'package:kotabi/services/schedule_builder.dart';
import 'package:kotabi/theme/kotabi_colors.dart';
import 'package:kotabi/widgets/plan_route_map.dart';
import 'package:kotabi/widgets/primary_button.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key, required this.planStore});

  final PlanStore planStore;

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes分';
    }
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) {
      return '$hours時間';
    }
    return '$hours時間$remainder分';
  }

  Future<void> _handleSave(BuildContext context) async {
    final saved = await planStore.save();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'プランを端末に保存しました' : '保存に失敗しました'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = planStore.items;
    final schedule = planStore.schedule;
    final preferences = planStore.preferences;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '今日のプラン',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KotabiColors.textPrimary,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: const Text('編集'),
                  ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note_outlined, size: 64, color: KotabiColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'プランに施設が追加されていません',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: KotabiColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '施設一覧の「プランに追加」から\n施設を追加してみましょう',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: KotabiColors.textSecondary,
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _ChildFriendlyOptions(
                considerNapTime: preferences.considerNapTime,
                extraBreaks: preferences.extraBreaks,
                onNapChanged: planStore.setConsiderNapTime,
                onBreaksChanged: planStore.setExtraBreaks,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _TravelModeSelector(
                travelMode: preferences.travelMode,
                isLoadingRoutes: planStore.isLoadingRoutes,
                usesRoutesApi: planStore.usesRoutesApi,
                onModeChanged: planStore.setTravelMode,
                onRefresh: planStore.refreshTravelTimes,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SummaryCard(
                totalMinutes: ScheduleBuilder.totalMinutes(schedule),
                stayMinutes: ScheduleBuilder.stayMinutes(schedule),
                travelMinutes: ScheduleBuilder.travelMinutes(schedule),
                breakMinutes: ScheduleBuilder.breakMinutes(schedule),
                facilityCount: items.length,
                formatMinutes: _formatMinutes,
                hasRelaxedPace: preferences.considerNapTime || preferences.extraBreaks,
                travelModeLabel: preferences.travelMode.label,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  final entry = schedule[index];
                  return _ScheduleEntryRow(
                    entry: entry,
                    onRemove: entry.type == ScheduleEntryType.facility && entry.facility != null
                        ? () => planStore.remove(entry.facility!)
                        : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: PlanRouteMap(
                facilities: items,
                segmentPolylines: planStore.segmentPolylines,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'ルートを地図で見る',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlanRouteMapFullScreen(
                              facilities: items,
                              segmentPolylines: planStore.segmentPolylines,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: planStore.isSaving ? '保存中...' : 'プランを保存',
                      onPressed: planStore.isSaving ? () {} : () => _handleSave(context),
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TravelModeSelector extends StatelessWidget {
  const _TravelModeSelector({
    required this.travelMode,
    required this.isLoadingRoutes,
    required this.usesRoutesApi,
    required this.onModeChanged,
    required this.onRefresh,
  });

  final TravelMode travelMode;
  final bool isLoadingRoutes;
  final bool usesRoutesApi;
  final ValueChanged<TravelMode> onModeChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KotabiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '移動手段（Routes API）',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KotabiColors.textPrimary,
                  ),
                ),
              ),
              if (isLoadingRoutes)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: '移動時間を再計算',
                ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<TravelMode>(
            segments: TravelMode.values
                .map(
                  (mode) => ButtonSegment(
                    value: mode,
                    label: Text(mode.label),
                    icon: Icon(
                      mode == TravelMode.drive
                          ? Icons.directions_car_outlined
                          : Icons.directions_walk,
                    ),
                  ),
                )
                .toList(),
            selected: {travelMode},
            onSelectionChanged: (selection) => onModeChanged(selection.first),
          ),
          const SizedBox(height: 8),
          Text(
            GoogleMapsConfig.isConfigured
                ? usesRoutesApi
                    ? 'Routes API から取得した移動時間をプランに反映しています'
                    : 'Routes API 未取得（座標不足またはAPIエラー時は仮データを使用）'
                : 'APIキー未設定のため移動時間は仮データを使用',
            style: const TextStyle(fontSize: 12, color: KotabiColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ChildFriendlyOptions extends StatelessWidget {
  const _ChildFriendlyOptions({
    required this.considerNapTime,
    required this.extraBreaks,
    required this.onNapChanged,
    required this.onBreaksChanged,
  });

  final bool considerNapTime;
  final bool extraBreaks;
  final ValueChanged<bool> onNapChanged;
  final ValueChanged<bool> onBreaksChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KotabiColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KotabiColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.child_care, size: 18, color: KotabiColors.primary),
              SizedBox(width: 6),
              Text(
                '子連れ向けの時間配分',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KotabiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ONにすると、昼寝や休憩を考慮した余裕のあるスケジュールになります',
            style: TextStyle(
              fontSize: 12,
              color: KotabiColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: considerNapTime,
            onChanged: onNapChanged,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: KotabiColors.primary,
            title: const Text(
              '昼寝時間を考慮する',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              '12:00前後に昼寝ブロックを挿入し、移動に余裕を持たせます',
              style: TextStyle(fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: extraBreaks,
            onChanged: onBreaksChanged,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: KotabiColors.primary,
            title: const Text(
              '休憩を多めに入れる',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              '施設間に15分の休憩を追加し、滞在時間もゆとりを持たせます',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalMinutes,
    required this.stayMinutes,
    required this.travelMinutes,
    required this.breakMinutes,
    required this.facilityCount,
    required this.formatMinutes,
    required this.hasRelaxedPace,
    required this.travelModeLabel,
  });

  final int totalMinutes;
  final int stayMinutes;
  final int travelMinutes;
  final int breakMinutes;
  final int facilityCount;
  final String Function(int) formatMinutes;
  final bool hasRelaxedPace;
  final String travelModeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KotabiColors.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRelaxedPace)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: KotabiColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.spa_outlined, size: 14, color: KotabiColors.primary),
                  SizedBox(width: 4),
                  Text(
                    '余裕のあるペースで計算中',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KotabiColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '合計時間',
                      style: TextStyle(fontSize: 12, color: KotabiColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '約 ${formatMinutes(totalMinutes)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '滞在 ${formatMinutes(stayMinutes)} / 移動 ${formatMinutes(travelMinutes)}'
                      '${breakMinutes > 0 ? ' / 休憩 ${formatMinutes(breakMinutes)}' : ''}',
                      style: const TextStyle(fontSize: 12, color: KotabiColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '施設数',
                      style: TextStyle(fontSize: 12, color: KotabiColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$facilityCount件（移動: $travelModeLabel）',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleEntryRow extends StatelessWidget {
  const _ScheduleEntryRow({
    required this.entry,
    this.onRemove,
  });

  final ScheduleEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return switch (entry.type) {
      ScheduleEntryType.facility => _FacilityTimelineRow(entry: entry, onRemove: onRemove),
      ScheduleEntryType.travel => _TravelTimelineRow(entry: entry),
      ScheduleEntryType.breakTime => _BreakTimelineRow(entry: entry, isNap: false),
      ScheduleEntryType.nap => _BreakTimelineRow(entry: entry, isNap: true),
    };
  }
}

class _FacilityTimelineRow extends StatelessWidget {
  const _FacilityTimelineRow({required this.entry, this.onRemove});

  final ScheduleEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final facility = entry.facility!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 64,
            child: Column(
              children: [
                Text(
                  entry.startTimeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KotabiColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: KotabiColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(width: 2, color: KotabiColors.border),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KotabiColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: KotabiColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: facility.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(facility.icon, color: facility.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.startTimeLabel} 〜 ${entry.endTimeLabel}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: KotabiColors.textSecondary,
                            ),
                          ),
                          Text(
                            '滞在 ${entry.durationMinutes}分',
                            style: const TextStyle(
                              fontSize: 12,
                              color: KotabiColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRemove != null)
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 20),
                        color: KotabiColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelTimelineRow extends StatelessWidget {
  const _TravelTimelineRow({required this.entry});

  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: KotabiColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car_outlined, size: 16, color: KotabiColors.primary),
                const SizedBox(width: 6),
                Text(
                  '${entry.startTimeLabel} 〜 ${entry.endTimeLabel}  移動 ${entry.durationMinutes}分',
                  style: const TextStyle(
                    fontSize: 12,
                    color: KotabiColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakTimelineRow extends StatelessWidget {
  const _BreakTimelineRow({required this.entry, required this.isNap});

  final ScheduleEntry entry;
  final bool isNap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isNap
              ? KotabiColors.orange.withValues(alpha: 0.12)
              : KotabiColors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNap
                ? KotabiColors.orange.withValues(alpha: 0.3)
                : KotabiColors.teal.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isNap ? Icons.nightlight_round : Icons.free_breakfast_outlined,
              size: 18,
              color: isNap ? KotabiColors.orange : KotabiColors.teal,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label ?? (isNap ? '昼寝・休憩' : '休憩'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isNap ? KotabiColors.orange : KotabiColors.teal,
                    ),
                  ),
                  Text(
                    '${entry.startTimeLabel} 〜 ${entry.endTimeLabel}（${entry.durationMinutes}分）',
                    style: const TextStyle(
                      fontSize: 12,
                      color: KotabiColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
