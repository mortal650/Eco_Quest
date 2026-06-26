import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WaterCategory {
  final String name;
  final String unit;
  final double min;
  final double max;
  final double defaultValue;
  final double litersPerUnit;
  final IconData icon;

  const WaterCategory({
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.litersPerUnit,
    required this.icon,
  });

  double calculateLiters(double value) => value * litersPerUnit;
}

class DayUsage {
  final Map<int, double> values;

  DayUsage({Map<int, double>? values})
      : values = values ?? {};
}

final List<WaterCategory> waterCategories = [
  const WaterCategory(
    name: 'Shower',
    unit: 'min',
    min: 0,
    max: 30,
    defaultValue: 10,
    litersPerUnit: 9,
    icon: Icons.shower,
  ),
  const WaterCategory(
    name: 'Toilet Flushes',
    unit: 'times',
    min: 0,
    max: 20,
    defaultValue: 6,
    litersPerUnit: 6,
    icon: Icons.wc,
  ),
  const WaterCategory(
    name: 'Laundry',
    unit: 'loads',
    min: 0,
    max: 3,
    defaultValue: 1,
    litersPerUnit: 50,
    icon: Icons.local_laundry_service,
  ),
  const WaterCategory(
    name: 'Dishwashing',
    unit: 'times',
    min: 0,
    max: 5,
    defaultValue: 2,
    litersPerUnit: 15,
    icon: Icons.cleaning_services,
  ),
  const WaterCategory(
    name: 'Garden Watering',
    unit: 'min',
    min: 0,
    max: 60,
    defaultValue: 15,
    litersPerUnit: 12,
    icon: Icons.yard,
  ),
  const WaterCategory(
    name: 'Cooking/Drinking',
    unit: 'liters',
    min: 5,
    max: 20,
    defaultValue: 10,
    litersPerUnit: 1,
    icon: Icons.local_drink,
  ),
];

final waterSimProvider = StateNotifierProvider<WaterSimNotifier, WaterSimState>((ref) {
  return WaterSimNotifier();
});

class WaterSimState {
  final int currentDay;
  final List<DayUsage> weekUsage;
  final bool isCompleted;

  WaterSimState({
    this.currentDay = 0,
    List<DayUsage>? weekUsage,
    this.isCompleted = false,
  }) : weekUsage = weekUsage ?? List.generate(7, (_) => DayUsage());

  WaterSimState copyWith({
    int? currentDay,
    List<DayUsage>? weekUsage,
    bool? isCompleted,
  }) {
    return WaterSimState(
      currentDay: currentDay ?? this.currentDay,
      weekUsage: weekUsage ?? this.weekUsage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get dailyUsage {
    double total = 0;
    final usage = weekUsage[currentDay];
    for (int i = 0; i < waterCategories.length; i++) {
      final value = usage.values[i] ?? waterCategories[i].defaultValue;
      total += waterCategories[i].calculateLiters(value);
    }
    return total;
  }

  Color get usageColor {
    final usage = dailyUsage;
    if (usage < 150) return Colors.green;
    if (usage <= 250) return Colors.orange;
    return Colors.red;
  }

  double get weeklyTotal {
    double total = 0;
    for (var dayUsage in weekUsage) {
      double dayTotal = 0;
      for (int i = 0; i < waterCategories.length; i++) {
        final value = dayUsage.values[i] ?? waterCategories[i].defaultValue;
        dayTotal += waterCategories[i].calculateLiters(value);
      }
      total += dayTotal;
    }
    return total;
  }

  double get weeklyAverage => weeklyTotal / 7;

  int get xpEarned {
    if (isCompleted) {
      bool allUnder150 = true;
      bool allUnder200 = true;
      for (var dayUsage in weekUsage) {
        double dayTotal = 0;
        for (int i = 0; i < waterCategories.length; i++) {
          final value = dayUsage.values[i] ?? waterCategories[i].defaultValue;
          dayTotal += waterCategories[i].calculateLiters(value);
        }
        if (dayTotal >= 150) allUnder150 = false;
        if (dayTotal >= 200) allUnder200 = false;
      }
      if (allUnder150) return 25;
      if (allUnder200) return 15;
      if (weeklyAverage < 250) return 10;
    }
    return 5;
  }

  double get savingsVsAverage {
    const averageHousehold = 300 * 7.0;
    return averageHousehold - weeklyTotal;
  }
}

class WaterSimNotifier extends StateNotifier<WaterSimState> {
  WaterSimNotifier() : super(WaterSimState());

  void updateValue(int categoryIndex, double value) {
    final currentUsage = state.weekUsage[state.currentDay];
    final newValues = Map<int, double>.from(currentUsage.values)
      ..[categoryIndex] = value;
    final updatedWeekUsage = List<DayUsage>.from(state.weekUsage)
      ..[state.currentDay] = DayUsage(values: newValues);
    state = state.copyWith(weekUsage: updatedWeekUsage);
  }

  void nextDay() {
    if (state.currentDay < 6) {
      state = state.copyWith(currentDay: state.currentDay + 1);
    } else {
      state = state.copyWith(isCompleted: true);
    }
  }

  void previousDay() {
    if (state.currentDay > 0) {
      state = state.copyWith(currentDay: state.currentDay - 1);
    }
  }

  void reset() {
    state = WaterSimState();
  }
}

class WaterConservationSim extends ConsumerWidget {
  const WaterConservationSim({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waterSimProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Conservation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(waterSimProvider.notifier).reset(),
          ),
        ],
      ),
      body: state.isCompleted
          ? _buildCompletionScreen(context, ref, state)
          : _buildSimulationScreen(context, ref, state),
    );
  }

  Widget _buildSimulationScreen(
      BuildContext context, WidgetRef ref, WaterSimState state) {
    return Column(
      children: [
        _buildDayHeader(state),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWaterMeter(state),
              const SizedBox(height: 16),
              _buildDailyComparison(state),
              const SizedBox(height: 16),
              ...List.generate(waterCategories.length, (index) {
                return _buildCategorySlider(
                  ref,
                  index,
                  state,
                );
              }),
              if (state.dailyUsage > 250) ...[
                const SizedBox(height: 16),
                _buildTipCard(),
              ],
            ],
          ),
        ),
        _buildBottomBar(ref, state),
      ],
    );
  }

  Widget _buildDayHeader(WaterSimState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Day ${state.currentDay + 1} of 7',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          _buildDayIndicator(state.currentDay),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(int currentDay) {
    return Row(
      children: List.generate(7, (index) {
        final isPast = index < currentDay;
        final isCurrent = index == currentDay;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPast
                ? Colors.green
                : isCurrent
                    ? Colors.blue
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWaterMeter(WaterSimState state) {
    final usage = state.dailyUsage;
    final fillPercentage = min(usage / 400.0, 1.0);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Daily Water Usage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(150, 200),
                    painter: _WaterDropPainter(
                      fillPercentage: fillPercentage,
                      color: state.usageColor,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${usage.toStringAsFixed(1)}L',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: state.usageColor,
                        ),
                      ),
                      Text(
                        _getUsageLabel(usage),
                        style: TextStyle(
                          fontSize: 14,
                          color: state.usageColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Green', 'Green', Colors.green, 'Below 150L'),
                const SizedBox(width: 16),
                _buildLegendItem('Orange', 'Orange', Colors.orange, '150-250L'),
                const SizedBox(width: 16),
                _buildLegendItem('Red', 'Red', Colors.red, 'Above 250L'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String colorName, Color color, String range) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(range, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  String _getUsageLabel(double usage) {
    if (usage < 150) return 'Eco-Friendly';
    if (usage <= 250) return 'Moderate';
    return 'High Usage';
  }

  Widget _buildDailyComparison(WaterSimState state) {
    final usage = state.dailyUsage;
    const target = 150.0;
    const average = 300.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Comparison',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparisonBar('Sustainable Target (150L)', usage, target, Colors.green),
            const SizedBox(height: 8),
            _buildComparisonBar('Average Household (300L)', usage, average, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBar(String label, double usage, double reference, Color color) {
    final percentage = min(usage / reference, 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            Text(
              usage > reference
                  ? '${((usage / reference - 1) * 100).toStringAsFixed(0)}% over'
                  : '${((1 - usage / reference) * 100).toStringAsFixed(0)}% under',
              style: TextStyle(
                fontSize: 11,
                color: usage <= reference ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: min(percentage, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (percentage > 1)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySlider(
      WidgetRef ref, int index, WaterSimState state) {
    final category = waterCategories[index];
    final currentValue =
        state.weekUsage[state.currentDay].values[index] ?? category.defaultValue;
    final liters = category.calculateLiters(currentValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${liters.toStringAsFixed(1)}L',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(liters, category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentValue,
                    min: category.min,
                    max: category.max,
                    divisions: category.unit == 'liters' || category.unit == 'min'
                        ? (category.max - category.min).toInt()
                        : (category.max - category.min).toInt() * 2,
                    label: '${currentValue.toStringAsFixed(category.unit == 'liters' ? 0 : (category.max <= 3 ? 1 : 0))} ${category.unit}',
                    onChanged: (value) {
                      ref.read(waterSimProvider.notifier).updateValue(index, value);
                    },
                    activeColor: _getCategoryColor(liters, category),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${currentValue.toStringAsFixed(currentValue == currentValue.roundToDouble() ? 0 : 1)} ${category.unit}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${category.min.toInt()} ${category.unit}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  '~${category.litersPerUnit}L per ${category.unit}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  '${category.max.toInt()} ${category.unit}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(double liters, WaterCategory category) {
    if (liters <= category.calculateLiters(category.defaultValue) * 0.8) {
      return Colors.green;
    } else if (liters <= category.calculateLiters(category.defaultValue) * 1.2) {
      return Colors.orange;
    }
    return Colors.red;
  }

  Widget _buildTipCard() {
    final tips = [
      'Take shorter showers to save up to 9 liters per minute',
      'Fix dripping taps - they can waste 20 liters per day',
      'Use a dual-flush toilet to save 6 liters per flush',
      'Only run laundry with full loads to save up to 50 liters',
      'Use a bucket to wash your car instead of a hose',
      'Water your garden early morning to reduce evaporation',
    ];

    final tip = tips[Random().nextInt(tips.length)];

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(WidgetRef ref, WaterSimState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.currentDay > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    ref.read(waterSimProvider.notifier).previousDay(),
                child: const Text('Previous Day'),
              ),
            ),
          if (state.currentDay > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(waterSimProvider.notifier).nextDay(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                state.currentDay < 6 ? 'Next Day' : 'Complete Week',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(
      BuildContext context, WidgetRef ref, WaterSimState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompletionHeader(state),
          const SizedBox(height: 16),
          _buildWeekSummary(state),
          const SizedBox(height: 16),
          _buildXpReward(state),
          const SizedBox(height: 16),
          _buildConservationTips(),
          const SizedBox(height: 16),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildCompletionHeader(WaterSimState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              state.savingsVsAverage > 0
                  ? Icons.celebration
                  : Icons.water_drop,
              size: 64,
              color: state.savingsVsAverage > 0 ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              state.savingsVsAverage > 0
                  ? 'Great Conservation!'
                  : 'Keep Trying!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You completed a week of water tracking',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSummary(WaterSimState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Usage',
              '${state.weeklyTotal.toStringAsFixed(0)} liters',
              Icons.water_drop,
              Colors.blue,
            ),
            _buildSummaryRow(
              'Daily Average',
              '${state.weeklyAverage.toStringAsFixed(1)} liters',
              Icons.trending_up,
              state.weeklyAverage <= 150
                  ? Colors.green
                  : state.weeklyAverage <= 250
                      ? Colors.orange
                      : Colors.red,
            ),
            _buildSummaryRow(
              'vs Average Household',
              state.savingsVsAverage > 0
                  ? 'Saved ${state.savingsVsAverage.toStringAsFixed(0)} liters'
                  : 'Used ${(state.savingsVsAverage * -1).toStringAsFixed(0)} liters extra',
              state.savingsVsAverage > 0
                  ? Icons.check_circle
                  : Icons.warning,
              state.savingsVsAverage > 0 ? Colors.green : Colors.red,
            ),
            _buildSummaryRow(
              'Sustainable Target',
              state.weeklyAverage <= 150
                  ? 'Achieved!'
                  : '${(state.weeklyAverage - 150).toStringAsFixed(0)}L over target',
              state.weeklyAverage <= 150
                  ? Icons.eco
                  : Icons.arrow_upward,
              state.weeklyAverage <= 150 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpReward(WaterSimState state) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'XP Earned',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '+${state.xpEarned} XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  Widget _buildConservationTips() {
    final tips = [
      {
        'title': 'Shorter Showers',
        'description': 'Reducing shower time by 2 minutes saves 18 liters daily',
        'icon': Icons.shower,
      },
      {
        'title': 'Fix Leaks',
        'description': 'A dripping tap wastes up to 20 liters per day',
        'icon': Icons.plumbing,
      },
      {
        'title': 'Full Loads Only',
        'description': 'Run washing machines and dishwashers with full loads',
        'icon': Icons.local_laundry_service,
      },
      {
        'title': 'Water-Saving Devices',
        'description': 'Install low-flow showerheads and dual-flush toilets',
        'icon': Icons.devices,
      },
      {
        'title': 'Garden Wisely',
        'description': 'Water plants in the morning and use drip irrigation',
        'icon': Icons.yard,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conservation Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => _buildTipItem(
                  tip['title'] as String,
                  tip['description'] as String,
                  tip['icon'] as IconData,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => ref.read(waterSimProvider.notifier).reset(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Back to Simulations'),
          ),
        ),
      ],
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  final double fillPercentage;
  final Color color;

  _WaterDropPainter({required this.fillPercentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final dropPath = Path();
    dropPath.moveTo(width / 2, 0);
    dropPath.cubicTo(
      width / 2,
      0,
      0,
      height * 0.5,
      0,
      height * 0.7,
    );
    dropPath.arcToPoint(
      Offset(width, height * 0.7),
      radius: Radius.circular(width / 2),
    );
    dropPath.cubicTo(
      width,
      height * 0.5,
      width / 2,
      0,
      width / 2,
      0,
    );
    dropPath.close();

    final fillPath = Path();
    final fillHeight = height * fillPercentage;
    final fillY = height - fillHeight;

    fillPath.moveTo(width / 2, fillY);
    fillPath.cubicTo(
      width / 2,
      fillY,
      0,
      height * 0.5,
      0,
      height * 0.7,
    );
    fillPath.arcToPoint(
      Offset(width, height * 0.7),
      radius: Radius.circular(width / 2),
    );
    fillPath.cubicTo(
      width,
      height * 0.5,
      width / 2,
      fillY,
      width / 2,
      fillY,
    );
    fillPath.close();

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withOpacity(0.5);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.7);

    canvas.drawPath(dropPath, outlinePaint);
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.color != color;
  }
}
