import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../../recommendation/controller/recommendation_controller.dart';
import '../../recommendation/view/recommendation_view.dart';
import '../controller/symptom_controller.dart';

class SymptomView extends StatefulWidget {
  const SymptomView({super.key});

  @override
  State<SymptomView> createState() => _SymptomViewState();
}

class _SymptomViewState extends State<SymptomView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<_SymptomItem> _symptoms = const [
    _SymptomItem('Demam', 'Umum', Icons.thermostat_rounded),
    _SymptomItem('Sakit Kepala', 'Umum', Icons.psychology_alt_rounded),
    _SymptomItem('Kelelahan', 'Umum', Icons.battery_2_bar_rounded),
    _SymptomItem('Pusing', 'Umum', Icons.blur_circular_rounded),
    _SymptomItem('Menggigil', 'Umum', Icons.ac_unit_rounded),
    _SymptomItem('Batuk', 'Pernapasan', Icons.air_rounded),
    _SymptomItem('Pilek', 'Pernapasan', Icons.sick_rounded),
    _SymptomItem(
      'Sakit Tenggorokan',
      'Pernapasan',
      Icons.record_voice_over_rounded,
    ),
    _SymptomItem('Sesak Napas', 'Pernapasan', Icons.monitor_heart_rounded),
    _SymptomItem('Mual', 'Pencernaan', Icons.no_food_rounded),
    _SymptomItem('Diare', 'Pencernaan', Icons.water_drop_rounded),
    _SymptomItem(
      'Sakit Perut',
      'Pencernaan',
      Icons.medical_information_rounded,
    ),
    _SymptomItem('Alergi Kulit', 'Kulit', Icons.healing_rounded),
    _SymptomItem('Gatal-gatal', 'Kulit', Icons.front_hand_rounded),
    _SymptomItem('Nyeri Otot', 'Fisik', Icons.fitness_center_rounded),
    _SymptomItem('Nyeri Sendi', 'Fisik', Icons.accessibility_new_rounded),
  ];

  List<String> get _categories => [
    'Semua',
    ..._symptoms.map((item) => item.category).toSet(),
  ];

  List<_SymptomItem> get _filteredSymptoms {
    final query = _searchController.text.trim().toLowerCase();
    return _symptoms.where((item) {
      final matchCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      final matchSearch =
          query.isEmpty || item.name.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SymptomController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(searchController: _searchController),
            _CategoryFilters(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (category) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
            ),
            Obx(() {
              if (controller.symptoms.isEmpty) return const SizedBox.shrink();
              return _SelectedTray(
                selectedSymptoms: controller.symptoms.toList(),
                onRemove: controller.toggleSymptom,
              );
            }),
            Expanded(
              child: Obx(() {
                final selected = controller.symptoms.toList();
                final items = _filteredSymptoms;
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
                    child: EmptyStateCard(
                      icon: Icons.search_off_rounded,
                      assetPath: 'assets/illustrations/symptom_empty.png',
                      title: 'Gejala tidak ditemukan',
                      message:
                          'Coba pakai kata kunci lain atau pilih kategori Semua.',
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final symptom = items[index];
                    return _SymptomCard(
                      symptom: symptom,
                      selected: selected.contains(symptom.name),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.toggleSymptom(symptom.name);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final count = controller.symptoms.length;
        if (count == 0) return const SizedBox.shrink();
        return _AnalyzeBar(
          count: count,
          onAnalyze: () {
            final rec = Get.find<RecommendationController>();
            rec.generateRecommendation(controller.symptoms.toList());
            Get.to(
              () => const RecommendationView(),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 260),
            );
          },
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController searchController;

  const _Header({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(color: AppColors.background),
      child: LiquidCard(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(18),
        gradient: AppTheme.heroGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusPill(
              label: 'Symptom checker',
              color: AppColors.primaryGlow,
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 12),
            Text(
              'Cek gejala',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih keluhan paling terasa. Semakin tepat input, semakin relevan arahannya.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari gejala',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: searchController.clear,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategoryFilters({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;
          return ChoiceChip(
            selected: selected,
            label: Text(category),
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            selectedColor: AppColors.ink,
            backgroundColor: AppColors.surface,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: selected ? AppColors.ink : AppColors.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _SelectedTray extends StatelessWidget {
  final List<String> selectedSymptoms;
  final ValueChanged<String> onRemove;

  const _SelectedTray({required this.selectedSymptoms, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      color: AppColors.background,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedSymptoms
            .map(
              (item) => InputChip(
                label: Text(item),
                onDeleted: () => onRemove(item),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                backgroundColor: AppColors.ink,
                side: BorderSide.none,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final _SymptomItem symptom;
  final bool selected;
  final VoidCallback onTap;

  const _SymptomCard({
    required this.symptom,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.surface;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.outline,
              width: 1,
            ),
            boxShadow: AppTheme.liquidShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientIconBox(
                    icon: symptom.icon,
                    color: selected ? AppColors.primaryGlow : _categoryColor,
                    size: 42,
                  ),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 22,
                    color: selected ? Colors.white : AppColors.textTertiary,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                symptom.category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.76)
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                symptom.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _categoryColor {
    return switch (symptom.category) {
      'Pernapasan' => AppColors.accent,
      'Pencernaan' => AppColors.amber,
      'Kulit' => AppColors.secondary,
      'Fisik' => AppColors.cyan,
      _ => AppColors.primary,
    };
  }
}

class _AnalyzeBar extends StatelessWidget {
  final int count;
  final VoidCallback onAnalyze;

  const _AnalyzeBar({required this.count, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppInfoBanner(
              icon: Icons.info_outline_rounded,
              color: AppColors.amber,
              message:
                  'Hasil hanya referensi awal dan bukan pengganti diagnosis dokter.',
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.analytics_rounded),
              label: Text('Analisis $count gejala'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomItem {
  final String name;
  final String category;
  final IconData icon;

  const _SymptomItem(this.name, this.category, this.icon);
}
