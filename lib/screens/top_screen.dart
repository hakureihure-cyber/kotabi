import 'package:flutter/material.dart';
import 'package:kotabi/models/search_criteria.dart';
import 'package:kotabi/services/search_criteria_store.dart';
import 'package:kotabi/theme/kotabi_colors.dart';
import 'package:kotabi/widgets/primary_button.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({
    super.key,
    required this.searchCriteriaStore,
    required this.onStartPlan,
  });

  final SearchCriteriaStore searchCriteriaStore;
  final VoidCallback onStartPlan;

  @override
  State<TopScreen> createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  late String _selectedArea;
  late Map<String, bool> _conditions;

  @override
  void initState() {
    super.initState();
    _syncFromStore();
  }

  void _syncFromStore() {
    final criteria = widget.searchCriteriaStore.criteria;
    _selectedArea = criteria.area;
    _conditions = {
      for (final key in SearchCriteria.defaultConditions.keys)
        key: criteria.selectedConditions.contains(key),
    };
  }

  void _startSearch() {
    widget.searchCriteriaStore.apply(
      area: _selectedArea,
      conditions: _conditions,
    );
    widget.onStartPlan();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroSection(),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'エリアを選択'),
                  const SizedBox(height: 10),
                  _AreaDropdown(
                    areas: SearchCriteria.defaultAreas,
                    value: _selectedArea,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedArea = value);
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: '条件を選択（複数選択可）'),
                  const SizedBox(height: 12),
                  _ConditionList(
                    conditions: _conditions,
                    onChanged: (key, value) {
                      setState(() => _conditions[key] = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PrimaryButton(
              label: 'プラン作成を開始する',
              icon: Icons.arrow_forward_rounded,
              onPressed: _startSearch,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                KotabiColors.primaryLight,
                KotabiColors.primary.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 20,
                bottom: 16,
                child: Icon(
                  Icons.landscape_rounded,
                  size: 72,
                  color: KotabiColors.green.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 20,
                child: Row(
                  children: [
                    _FamilyIcon(color: KotabiColors.orange),
                    const SizedBox(width: 8),
                    _FamilyIcon(color: KotabiColors.blue, size: 36),
                    const SizedBox(width: 8),
                    _FamilyIcon(color: KotabiColors.teal, size: 28),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                child: Image.asset(
                  'assets/images/kotabi_logo.png',
                  height: 48,
                  errorBuilder: (_, _, _) => const Text(
                    'KOTABI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: KotabiColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '子連れ旅行プラン作成',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: KotabiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '家族にやさしいお出かけを、もっと簡単に。',
          style: TextStyle(
            fontSize: 14,
            color: KotabiColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FamilyIcon extends StatelessWidget {
  const _FamilyIcon({required this.color, this.size = 44});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: color, size: size * 0.55),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: KotabiColors.textPrimary,
      ),
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.areas,
    required this.value,
    required this.onChanged,
  });

  final List<String> areas;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KotabiColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: areas
              .map(
                (area) => DropdownMenuItem(value: area, child: Text(area)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ConditionList extends StatelessWidget {
  const _ConditionList({
    required this.conditions,
    required this.onChanged,
  });

  final Map<String, bool> conditions;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KotabiColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KotabiColors.border),
      ),
      child: Column(
        children: conditions.entries.map((entry) {
          final isLast = entry.key == conditions.keys.last;
          return Column(
            children: [
              CheckboxListTile(
                value: entry.value,
                onChanged: (value) => onChanged(entry.key, value ?? false),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 15,
                    color: KotabiColors.textPrimary,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                activeColor: KotabiColors.primary,
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
