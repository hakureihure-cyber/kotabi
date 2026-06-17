import 'package:flutter/material.dart';
import 'package:kotabi/screens/facility_list_screen.dart';
import 'package:kotabi/screens/plan_screen.dart';
import 'package:kotabi/screens/top_screen.dart';
import 'package:kotabi/services/facility_repository.dart';
import 'package:kotabi/services/firebase_bootstrap.dart';
import 'package:kotabi/services/plan_store.dart';
import 'package:kotabi/services/search_criteria_store.dart';
import 'package:kotabi/theme/kotabi_colors.dart';
import 'package:kotabi/widgets/kotabi_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PlanStore _planStore = PlanStore();
  final SearchCriteriaStore _searchCriteriaStore = SearchCriteriaStore();
  late final FacilityRepository _facilityRepository;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await FirebaseBootstrap.tryInitialize();
    _facilityRepository = FacilityRepository();
    await _planStore.load();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _planStore.dispose();
    _searchCriteriaStore.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _goToSearch() {
    setState(() => _currentIndex = 1);
  }

  void _goToPlan() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: KotabiColors.primary),
        ),
      );
    }

    final screens = [
      TopScreen(
        searchCriteriaStore: _searchCriteriaStore,
        onStartPlan: _goToSearch,
      ),
      ListenableBuilder(
        listenable: _searchCriteriaStore,
        builder: (context, _) => FacilityListScreen(
          facilityRepository: _facilityRepository,
          searchCriteriaStore: _searchCriteriaStore,
          planStore: _planStore,
          onGoToPlan: _goToPlan,
        ),
      ),
      ListenableBuilder(
        listenable: _planStore,
        builder: (context, _) => PlanScreen(planStore: _planStore),
      ),
      const _PlaceholderScreen(title: 'お気に入り', icon: Icons.favorite_outline),
      const _PlaceholderScreen(title: 'マイページ', icon: Icons.person_outline),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: KotabiBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: KotabiColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KotabiColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '準備中',
              style: TextStyle(color: KotabiColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
