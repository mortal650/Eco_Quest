import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/data/user_profile_notifier.dart';

class CarbonFootprintSim extends ConsumerStatefulWidget {
  const CarbonFootprintSim({super.key});

  @override
  ConsumerState<CarbonFootprintSim> createState() =>
      _CarbonFootprintSimState();
}

class _CarbonFootprintSimState extends ConsumerState<CarbonFootprintSim>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeAnimController;
  late Animation<double> _gaugeAnim;

  int _currentStep = 0;
  bool _completed = false;

  // Step 1 - Transportation
  String _commuteMode = 'car';
  double _dailyDistanceKm = 10;

  // Step 2 - Diet
  String _dietType = 'omnivore';

  // Step 3 - Home Energy
  String _electricitySource = 'mixed';
  double _energyUsageLevel = 0.5; // 0 = low, 1 = high

  // Step 4 - Shopping
  String _shoppingLevel = 'medium';

  static const double _carFactor = 0.21;
  static const double _busFactor = 0.089;
  static const double _bikeFactor = 0.0;
  static const double _walkFactor = 0.0;

  static const double _omnivoreFactor = 2.5;
  static const double _vegetarianFactor = 1.7;
  static const double _veganFactor = 1.5;

  static const double _fossilFactor = 0.9;
  static const double _mixedFactor = 0.4;
  static const double _renewableFactor = 0.05;

  static const double _shoppingHigh = 2.0;
  static const double _shoppingMedium = 1.0;
  static const double _shoppingLow = 0.5;

  static const double _avgIndia = 4.0;
  static const double _avgUSA = 16.0;
  static const double _globalTarget = 2.5;

  @override
  void initState() {
    super.initState();
    _gaugeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gaugeAnim = CurvedAnimation(
      parent: _gaugeAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _gaugeAnimController.dispose();
    super.dispose();
  }

  double get _transportEmissions {
    final factor = switch (_commuteMode) {
      'car' => _carFactor,
      'bus' => _busFactor,
      'bike' => _bikeFactor,
      'walk' => _walkFactor,
      _ => 0.0,
    };
    return factor * _dailyDistanceKm * 365 / 1000;
  }

  double get _dietEmissions {
    return switch (_dietType) {
      'omnivore' => _omnivoreFactor,
      'vegetarian' => _vegetarianFactor,
      'vegan' => _veganFactor,
      _ => 0.0,
    };
  }

  double get _energyEmissions {
    final baseFactor = switch (_electricitySource) {
      'fossil' => _fossilFactor,
      'mixed' => _mixedFactor,
      'renewable' => _renewableFactor,
      _ => 0.0,
    };
    final avgHouseholdKwh = 1500.0;
    return baseFactor * avgHouseholdKwh * _energyUsageLevel / 1000;
  }

  double get _shoppingEmissions {
    return switch (_shoppingLevel) {
      'high' => _shoppingHigh,
      'medium' => _shoppingMedium,
      'low' => _shoppingLow,
      _ => 0.0,
    };
  }

  double get _totalEmissions =>
      _transportEmissions +
      _dietEmissions +
      _energyEmissions +
      _shoppingEmissions;

  Color _gaugeColor(double value) {
    if (value <= _globalTarget) return const Color(0xFF2E7D32);
    if (value <= _avgIndia) return const Color(0xFFFBC02D);
    return const Color(0xFFD32F2F);
  }

  String _ratingLabel(double value) {
    if (value <= _globalTarget) return 'Excellent';
    if (value <= _avgIndia) return 'Moderate';
    return 'High';
  }

  List<String> _getTips() {
    final tips = <String>[];
    final categories = [
      _CategoryTip('Transportation', _transportEmissions, () {
        tips.add(
          'Switching from car to bus or cycling can cut transport emissions '
          'by over 60%. Try carpooling or public transit a few days a week!',
        );
      }),
      _CategoryTip('Diet', _dietEmissions, () {
        tips.add(
          'Reducing meat consumption is one of the most impactful changes. '
          'Even one meatless day per week saves ~0.2 tonnes of CO\u2082 per year.',
        );
      }),
      _CategoryTip('Home Energy', _energyEmissions, () {
        tips.add(
          'Switching to renewable energy sources or using energy-efficient '
          'appliances can dramatically lower your household emissions.',
        );
      }),
      _CategoryTip('Shopping', _shoppingEmissions, () {
        tips.add(
          'Buy less, choose well, and make it last. Opt for second-hand, '
          'repair items, and avoid fast fashion to cut shopping emissions.',
        );
      }),
    ];

    categories.sort((a, b) => b.emissions.compareTo(a.emissions));
    for (final cat in categories.take(3)) {
      cat.tipBuilder();
    }
    return tips;
  }

  Future<void> _awardXP() async {
    await ref.read(userProfileProvider.notifier).addXP(30);
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      setState(() => _completed = true);
      _gaugeAnimController.forward();
      _awardXP();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _completed
          ? _buildResult(context, colorScheme)
          : _buildSteps(context, colorScheme),
    );
  }

  Widget _buildSteps(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: List.generate(4, (i) {
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDone
                        ? colorScheme.primary
                        : isActive
                            ? colorScheme.primary.withValues(alpha: 0.5)
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of 4',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              Text(
                ['Transportation', 'Diet', 'Home Energy', 'Shopping']
                    [_currentStep],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildTransportStep(context),
              _buildDietStep(context),
              _buildEnergyStep(context),
              _buildShoppingStep(context),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevStep,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == 3 ? 'Calculate' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you commute?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Select your primary mode of daily transportation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  icon: Icons.directions_car,
                  label: 'Car',
                  isSelected: _commuteMode == 'car',
                  onTap: () => setState(() => _commuteMode = 'car'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  icon: Icons.directions_bus,
                  label: 'Bus',
                  isSelected: _commuteMode == 'bus',
                  onTap: () => setState(() => _commuteMode = 'bus'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  icon: Icons.pedal_bike,
                  label: 'Bike',
                  isSelected: _commuteMode == 'bike',
                  onTap: () => setState(() => _commuteMode = 'bike'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  icon: Icons.directions_walk,
                  label: 'Walk',
                  isSelected: _commuteMode == 'walk',
                  onTap: () => setState(() => _commuteMode = 'walk'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Daily distance (km)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${_dailyDistanceKm.round()} km each way',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Slider(
            value: _dailyDistanceKm,
            min: 1,
            max: 100,
            divisions: 99,
            label: '${_dailyDistanceKm.round()} km',
            onChanged: (v) => setState(() => _dailyDistanceKm = v),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.eco,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _commuteMode == 'bike' || _commuteMode == 'walk'
                        ? 'Zero emissions - great choice!'
                        : 'Estimated: ${_transportEmissions.toStringAsFixed(2)} tonnes CO\u2082/year',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDietStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your diet?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Your diet has a significant impact on your carbon footprint.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          _DietCard(
            icon: Icons.restaurant,
            title: 'Omnivore',
            subtitle: 'Eats all types of food including meat and dairy',
            factor: '$_omnivoreFactor tonnes CO\u2082/year',
            color: Colors.orange,
            isSelected: _dietType == 'omnivore',
            onTap: () => setState(() => _dietType = 'omnivore'),
          ),
          const SizedBox(height: 10),
          _DietCard(
            icon: Icons.eco,
            title: 'Vegetarian',
            subtitle: 'No meat, but includes dairy and eggs',
            factor: '$_vegetarianFactor tonnes CO\u2082/year',
            color: Colors.green,
            isSelected: _dietType == 'vegetarian',
            onTap: () => setState(() => _dietType = 'vegetarian'),
          ),
          const SizedBox(height: 10),
          _DietCard(
            icon: Icons.spa,
            title: 'Vegan',
            subtitle: 'No animal products at all',
            factor: '$_veganFactor tonnes CO\u2082/year',
            color: Colors.teal,
            isSelected: _dietType == 'vegan',
            onTap: () => setState(() => _dietType = 'vegan'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Meat production generates significantly more greenhouse gases than plant-based foods.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnergyStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Home energy source',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'What powers your home electricity?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  icon: Icons.local_fire_department,
                  label: 'Fossil\nFuel',
                  isSelected: _electricitySource == 'fossil',
                  onTap: () =>
                      setState(() => _electricitySource = 'fossil'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  icon: Icons.power,
                  label: 'Mixed',
                  isSelected: _electricitySource == 'mixed',
                  onTap: () =>
                      setState(() => _electricitySource = 'mixed'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectionCard(
                  icon: Icons.solar_power,
                  label: 'Renew-\nable',
                  isSelected: _electricitySource == 'renewable',
                  onTap: () =>
                      setState(() => _electricitySource = 'renewable'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Energy usage level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                'High',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Slider(
            value: _energyUsageLevel,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: (_energyUsageLevel * 100).round().toString() + '%',
            onChanged: (v) => setState(() => _energyUsageLevel = v),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimated: ${_energyEmissions.toStringAsFixed(2)} tonnes CO\u2082/year',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShoppingStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping habits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'How much do you buy new each year?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          _ShoppingCard(
            icon: Icons.shopping_bag,
            title: 'High',
            description: 'Frequent purchases, new clothes, gadgets, home decor',
            factor: '$_shoppingHigh tonnes CO\u2082/year',
            color: Colors.red,
            isSelected: _shoppingLevel == 'high',
            onTap: () => setState(() => _shoppingLevel = 'high'),
          ),
          const SizedBox(height: 10),
          _ShoppingCard(
            icon: Icons.shopping_cart,
            title: 'Medium',
            description: 'Moderate spending, occasional new items',
            factor: '$_shoppingMedium tonnes CO\u2082/year',
            color: Colors.orange,
            isSelected: _shoppingLevel == 'medium',
            onTap: () => setState(() => _shoppingLevel = 'medium'),
          ),
          const SizedBox(height: 10),
          _ShoppingCard(
            icon: Icons.shopping_basket,
            title: 'Low',
            description: 'Minimal purchases, prefers second-hand and repair',
            factor: '$_shoppingLow tonnes CO\u2082/year',
            color: Colors.green,
            isSelected: _shoppingLevel == 'low',
            onTap: () => setState(() => _shoppingLevel = 'low'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, ColorScheme colorScheme) {
    final total = _totalEmissions;
    final gaugeColor = _gaugeColor(total);
    final tips = _getTips();
    final categories = [
      _BreakdownData('Transport', _transportEmissions, Colors.blue),
      _BreakdownData('Diet', _dietEmissions, Colors.orange),
      _BreakdownData('Energy', _energyEmissions, Colors.amber),
      _BreakdownData('Shopping', _shoppingEmissions, Colors.purple),
    ];
    final maxEmission =
        categories.map((c) => c.value).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Your Carbon Footprint',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            width: 200,
            child: AnimatedBuilder(
              animation: _gaugeAnim,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GaugePainter(
                    value: _gaugeAnim.value,
                    totalEmissions: total,
                    color: gaugeColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '${total.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: gaugeColor,
                              ),
                        ),
                        Text(
                          'tonnes CO\u2082/year',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: gaugeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _ratingLabel(total),
              style: TextStyle(
                color: gaugeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ComparisonBar(
                    label: 'Your footprint',
                    value: total,
                    maxValue: _avgUSA,
                    color: gaugeColor,
                  ),
                  _ComparisonBar(
                    label: 'India average',
                    value: _avgIndia,
                    maxValue: _avgUSA,
                    color: Colors.blueGrey,
                  ),
                  _ComparisonBar(
                    label: 'USA average',
                    value: _avgUSA,
                    maxValue: _avgUSA,
                    color: Colors.red,
                  ),
                  _ComparisonBar(
                    label: 'Global target',
                    value: _globalTarget,
                    maxValue: _avgUSA,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakdown by Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...categories.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.label,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '${c.value.toStringAsFixed(2)} t',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value:
                                    maxEmission > 0 ? c.value / maxEmission : 0,
                                minHeight: 10,
                                backgroundColor: colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                valueColor:
                                    AlwaysStoppedAnimation(c.color),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb,
                            color: colorScheme.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Personalized Tips',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle,
                                  color: colorScheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('+30 XP Earned!'),
              subtitle: const Text('Carbon footprint calculation complete'),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Back to Dashboard'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _completed = false;
                  _currentStep = 0;
                  _commuteMode = 'car';
                  _dailyDistanceKm = 10;
                  _dietType = 'omnivore';
                  _electricitySource = 'mixed';
                  _energyUsageLevel = 0.5;
                  _shoppingLevel = 'medium';
                });
                _gaugeAnimController.reset();
              },
              icon: const Icon(Icons.replay),
              label: const Text('Recalculate'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.4)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DietCard extends StatelessWidget {
  const _DietCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.factor,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String factor;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 22)
                  else
                    Icon(Icons.radio_button_unchecked,
                        color: Theme.of(context).colorScheme.outline, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    factor,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  const _ShoppingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.factor,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String factor;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 22)
                  else
                    Icon(Icons.radio_button_unchecked,
                        color: Theme.of(context).colorScheme.outline, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    factor,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${value.toStringAsFixed(1)}t',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0,
              minHeight: 8,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.totalEmissions,
    required this.color,
  });

  final double value;
  final double totalEmissions;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value.clamp(0.0, 1.0),
      false,
      fgPaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    for (int i = 0; i <= 10; i++) {
      final angle = startAngle + sweepAngle * (i / 10);
      final outer = Offset(
        center.dx + (radius + 14) * math.cos(angle),
        center.dy + (radius + 14) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius + 6) * math.cos(angle),
        center.dy + (radius + 6) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class _CategoryTip {
  _CategoryTip(this.name, this.emissions, this.tipBuilder);

  final String name;
  final double emissions;
  final VoidCallback tipBuilder;
}

class _BreakdownData {
  _BreakdownData(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}
