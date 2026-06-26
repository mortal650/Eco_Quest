import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class RenewableEnergySim extends ConsumerStatefulWidget {
  const RenewableEnergySim({super.key});

  @override
  ConsumerState<RenewableEnergySim> createState() => _RenewableEnergySimState();
}

class _RenewableEnergySimState extends ConsumerState<RenewableEnergySim> {
  double solarMW = 0;
  double windMW = 0;
  double hydroMW = 0;
  double batteryMW = 0;

  bool showResults = false;
  int finalScore = 0;

  static const double targetCapacity = 200;
  static const double budgetLimit = 400;

  static const double solarCostPerMW = 1.0;
  static const double windCostPerMW = 1.3;
  static const double hydroCostPerMW = 2.6;
  static const double batteryCostPerMW = 0.5;

  static const double solarCapacityFactor = 0.25;
  static const double windCapacityFactor = 0.35;
  static const double hydroCapacityFactor = 0.50;

  static const double solarCarbon = 20;
  static const double windCarbon = 10;
  static const double hydroCarbon = 5;

  double get totalCapacity => solarMW + windMW + hydroMW;

  double get effectiveCapacity {
    double solar = solarMW * solarCapacityFactor;
    double wind = windMW * windCapacityFactor;
    double hydro = hydroMW * hydroCapacityFactor;
    return solar + wind + hydro;
  }

  double get totalCost =>
      solarMW * solarCostPerMW +
      windMW * windCostPerMW +
      hydroMW * hydroCostPerMW +
      batteryMW * batteryCostPerMW;

  double get reliabilityScore {
    int sources = 0;
    if (solarMW > 0) sources++;
    if (windMW > 0) sources++;
    if (hydroMW > 0) sources++;

    double diversityScore = sources / 3 * 100;

    double storageBonus = batteryMW > 0 ? 15 : 0;

    double capacityBonus = 0;
    if (effectiveCapacity >= targetCapacity) {
      capacityBonus = 10;
    } else {
      capacityBonus = (effectiveCapacity / targetCapacity) * 10;
    }

    return min(100, diversityScore + storageBonus + capacityBonus);
  }

  double get carbonEmissions {
    double solar = solarMW * solarCarbon * 8760 / 1000;
    double wind = windMW * windCarbon * 8760 / 1000;
    double hydro = hydroMW * hydroCarbon * 8760 / 1000;
    return solar + wind + hydro;
  }

  void calculateResults() {
    int score = 0;

    if (effectiveCapacity >= targetCapacity) {
      score += 10;
    }

    if (totalCost <= budgetLimit) {
      score += 10;
    }

    if (reliabilityScore > 80) {
      score += 10;
    }

    if (carbonEmissions < 10000) {
      score += 10;
    }

    int xp = (score / 40 * 35).round();

    setState(() {
      finalScore = xp;
      showResults = true;
    });
  }

  void resetSimulation() {
    setState(() {
      solarMW = 0;
      windMW = 0;
      hydroMW = 0;
      batteryMW = 0;
      showResults = false;
      finalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewable Energy Planner'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetSimulation,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCityInfoCard(theme),
            const SizedBox(height: 16),
            _buildRequirementsCard(theme),
            const SizedBox(height: 16),
            _buildEnergySliders(theme),
            const SizedBox(height: 16),
            _buildRealTimeCalculations(theme),
            const SizedBox(height: 16),
            _buildEnergyMixChart(theme),
            const SizedBox(height: 16),
            _buildEducationalTips(theme),
            const SizedBox(height: 16),
            if (showResults) _buildResultsCard(theme),
            const SizedBox(height: 16),
            _buildActionButtons(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCityInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'City: Greenfield',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Population: 100,000 citizens'),
            Text('Mission: Design a sustainable energy system'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy Requirements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.bolt, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                const Text('Required Capacity: 200 MW'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                const Text('Budget Limit: \$400 Million'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergySliders(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allocate Energy Capacity (MW)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEnergySlider(
              label: 'Solar',
              value: solarMW,
              max: 300,
              color: Colors.orange,
              icon: Icons.wb_sunny,
              cost: solarCostPerMW,
              onChanged: (v) => setState(() => solarMW = v),
            ),
            _buildEnergySlider(
              label: 'Wind',
              value: windMW,
              max: 300,
              color: Colors.lightBlue,
              icon: Icons.air,
              cost: windCostPerMW,
              onChanged: (v) => setState(() => windMW = v),
            ),
            _buildEnergySlider(
              label: 'Hydro',
              value: hydroMW,
              max: 300,
              color: Colors.blue,
              icon: Icons.water,
              cost: hydroCostPerMW,
              onChanged: (v) => setState(() => hydroMW = v),
            ),
            _buildEnergySlider(
              label: 'Battery Storage',
              value: batteryMW,
              max: 300,
              color: Colors.green,
              icon: Icons.battery_charging_full,
              cost: batteryCostPerMW,
              onChanged: (v) => setState(() => batteryMW = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergySlider({
    required String label,
    required double value,
    required double max,
    required Color color,
    required IconData icon,
    required double cost,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(0)} MW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(\$${(value * cost).toStringAsFixed(1)}M)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: 30,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeCalculations(ThemeData theme) {
    bool meetsCapacity = effectiveCapacity >= targetCapacity;
    bool underBudget = totalCost <= budgetLimit;
    bool goodReliability = reliabilityScore > 80;
    bool lowCarbon = carbonEmissions < 10000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-Time Metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Total Installed Capacity',
              '${totalCapacity.toStringAsFixed(0)} MW',
              totalCapacity >= targetCapacity
                  ? Colors.green
                  : totalCapacity >= targetCapacity * 0.8
                      ? Colors.orange
                      : Colors.red,
            ),
            _buildMetricRow(
              'Effective Capacity (Avg)',
              '${effectiveCapacity.toStringAsFixed(0)} MW',
              meetsCapacity ? Colors.green : Colors.orange,
            ),
            _buildMetricRow(
              'Total Cost',
              '\$${totalCost.toStringAsFixed(1)} Million',
              underBudget ? Colors.green : Colors.red,
            ),
            _buildMetricRow(
              'Reliability Score',
              '${reliabilityScore.toStringAsFixed(0)}%',
              goodReliability ? Colors.green : Colors.orange,
            ),
            _buildMetricRow(
              'Carbon Emissions',
              '${carbonEmissions.toStringAsFixed(0)} tons/year',
              lowCarbon ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyMixChart(ThemeData theme) {
    if (totalCapacity == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Energy Mix',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.pie_chart_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Use sliders above to allocate energy sources',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy Mix Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 16),
            _buildPieChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final total = totalCapacity;
    if (total == 0) return const SizedBox();

    final solarPercent = (solarMW / total * 100);
    final windPercent = (windMW / total * 100);
    final hydroPercent = (hydroMW / total * 100);

    return Column(
      children: [
        _buildBar('Solar', solarPercent, Colors.orange, Icons.wb_sunny),
        const SizedBox(height: 8),
        _buildBar('Wind', windPercent, Colors.lightBlue, Icons.air),
        const SizedBox(height: 8),
        _buildBar('Hydro', hydroPercent, Colors.blue, Icons.water),
      ],
    );
  }

  Widget _buildBar(String label, double percent, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (percent > 0)
                Container(
                  height: 24,
                  width: percent * 2.5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '${percent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartLegend() {
    final total = totalCapacity;
    if (total == 0) return const SizedBox();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Solar', Colors.orange, solarMW),
        _buildLegendItem('Wind', Colors.lightBlue, windMW),
        _buildLegendItem('Hydro', Colors.blue, hydroMW),
        if (batteryMW > 0)
          _buildLegendItem('Battery', Colors.green, batteryMW),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(
          '$label: ${value.toStringAsFixed(0)} MW',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEducationalTips(ThemeData theme) {
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: ExpansionTile(
        leading: Icon(Icons.lightbulb, color: theme.colorScheme.tertiary),
        title: const Text('Educational Tips'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem(
                  Icons.wb_sunny,
                  'Solar Energy',
                  'Best in sunny regions. Capacity factor: 25%. '
                      'Cost-effective at scale. No emissions during operation.',
                  Colors.orange,
                ),
                const Divider(),
                _buildTipItem(
                  Icons.air,
                  'Wind Energy',
                  'Ideal in windy areas. Capacity factor: 35%. '
                      'Higher upfront cost but excellent long-term value.',
                  Colors.lightBlue,
                ),
                const Divider(),
                _buildTipItem(
                  Icons.water,
                  'Hydro Energy',
                  'Most reliable renewable. Capacity factor: 50%. '
                      'Higher cost but consistent output day and night.',
                  Colors.blue,
                ),
                const Divider(),
                _buildTipItem(
                  Icons.battery_charging_full,
                  'Battery Storage',
                  'Stores excess energy for peak demand. '
                      'Essential for grid stability and reliability.',
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCard(ThemeData theme) {
    bool meetsCapacity = effectiveCapacity >= targetCapacity;
    bool underBudget = totalCost <= budgetLimit;
    bool goodReliability = reliabilityScore > 80;
    bool lowCarbon = carbonEmissions < 10000;

    int xpEarned = finalScore;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                const SizedBox(width: 8),
                Text(
                  'Final Results',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Performance Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildResultCheck(
              'Meets 200 MW Capacity',
              meetsCapacity,
              '+10 points',
            ),
            _buildResultCheck(
              'Under Budget (\$400M)',
              underBudget,
              '+10 points',
            ),
            _buildResultCheck(
              'Reliability > 80%',
              goodReliability,
              '+10 points',
            ),
            _buildResultCheck(
              'Carbon < 10,000 tons/year',
              lowCarbon,
              '+10 points',
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Score:'),
                Text(
                  '${(meetsCapacity ? 10 : 0) + (underBudget ? 10 : 0) + (goodReliability ? 10 : 0) + (lowCarbon ? 10 : 0)}/40',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '$xpEarned XP Earned',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildResultCheck(String label, bool passed, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            passed ? points : '0 pts',
            style: TextStyle(
              color: passed ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: resetSimulation,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: showResults ? null : calculateResults,
            icon: Icon(showResults ? Icons.check : Icons.calculate),
            label: Text(showResults ? 'Submitted' : 'Calculate Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
