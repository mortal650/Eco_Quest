import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/data/user_profile_notifier.dart';

class BiodiversitySimScreen extends ConsumerStatefulWidget {
  const BiodiversitySimScreen({super.key});

  @override
  ConsumerState<BiodiversitySimScreen> createState() =>
      _BiodiversitySimScreenState();
}

class _BiodiversitySimScreenState extends ConsumerState<BiodiversitySimScreen> {
  double _forest = 250;
  double _wetland = 75;
  double _organic = 150;
  double _corridors = 50;
  double _urban = 100;
  bool _submitted = false;
  int _totalScore = 0;
  int _xpEarned = 0;

  static const _totalLand = 1000.0;

  double get _remaining =>
      _totalLand - _forest - _wetland - _organic - _corridors - _urban;

  double get _biodiversity {
    final habitat = (_forest * 0.35 + _wetland * 0.25 + _organic * 0.15);
    final connectivity = _corridors * 0.6;
    final urbanPenalty = _urban * 0.15;
    final raw = (habitat + connectivity - urbanPenalty) / 8.5;
    return raw.clamp(0, 100);
  }

  double get _carbonStorage {
    final raw = (_forest * 0.5 + _wetland * 0.3 + _organic * 0.05) / 6.0;
    return raw.clamp(0, 100);
  }

  double get _communityWellbeing {
    final food = (_organic * 0.4 + 200 * 0.2);
    final economy = _urban * 0.3;
    final raw = (food + economy) / 5.0;
    return raw.clamp(0, 100);
  }

  int get _calculatedScore {
    int score = 0;
    if (_biodiversity > 70) score += 10;
    if (_carbonStorage > 60) score += 10;
    if (_communityWellbeing > 60) score += 10;
    if (_biodiversity > 50 && _carbonStorage > 50 && _communityWellbeing > 50) {
      score += 10;
    }
    return score;
  }

  int get _xpFromScore => ((_calculatedScore / 40) * 30).round();

  void _submit() {
    if (_remaining < 0) return;
    setState(() {
      _submitted = true;
      _totalScore = _calculatedScore;
      _xpEarned = _xpFromScore;
    });
    _awardXp();
  }

  Future<void> _awardXp() async {
    if (_xpEarned <= 0) return;
    await ref.read(userProfileProvider.notifier).addXP(_xpEarned);
  }

  void _reset() {
    setState(() {
      _forest = 250;
      _wetland = 75;
      _organic = 150;
      _corridors = 50;
      _urban = 100;
      _submitted = false;
      _totalScore = 0;
      _xpEarned = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overBudget = _remaining < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biodiversity Protector'),
        actions: [
          if (_submitted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: _submitted
          ? _buildResult(context)
          : _buildSimulation(context, colorScheme, overBudget),
    );
  }

  Widget _buildSimulation(
      BuildContext context, ColorScheme colorScheme, bool overBudget) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.park, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verdant Valley Ecosystem',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Manage 1,000 hectares of land. Balance biodiversity, carbon storage, and community needs.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetricBar(
                  label: 'Biodiversity',
                  value: _biodiversity,
                  color: Colors.green,
                  icon: Icons.pets,
                ),
                const SizedBox(height: 8),
                _MetricBar(
                  label: 'Carbon Storage',
                  value: _carbonStorage,
                  color: Colors.teal,
                  icon: Icons.cloud,
                ),
                const SizedBox(height: 8),
                _MetricBar(
                  label: 'Community Well-being',
                  value: _communityWellbeing,
                  color: Colors.amber,
                  icon: Icons.groups,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      overBudget ? Icons.error_outline : Icons.landscape,
                      color: overBudget ? colorScheme.error : colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Land remaining: ${_remaining.toStringAsFixed(0)} ha',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            overBudget ? colorScheme.error : colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Score: ${_calculatedScore}/40',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ecosystem Map',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _EcosystemGrid(
          forest: _forest,
          wetland: _wetland,
          organic: _organic,
          corridors: _corridors,
          urban: _urban,
          total: _totalLand,
        ),
        const SizedBox(height: 16),
        _LandUseSlider(
          label: 'Forest Area',
          value: _forest,
          min: 0,
          max: 500,
          color: const Color(0xFF2E7D32),
          icon: Icons.forest,
          info:
              'Forests store carbon, provide habitat for countless species, and protect watersheds. Old-growth forests are biodiversity hotspots.',
          onChanged: (v) => setState(() => _forest = v),
        ),
        _LandUseSlider(
          label: 'Wetland Protection',
          value: _wetland,
          min: 0,
          max: 150,
          color: const Color(0xFF0288D1),
          icon: Icons.water,
          info:
              'Wetlands filter pollutants from water, absorb flood surges, and support unique plant and animal communities.',
          onChanged: (v) => setState(() => _wetland = v),
        ),
        _LandUseSlider(
          label: 'Organic Farming',
          value: _organic,
          min: 0,
          max: 300,
          color: const Color(0xFF8BC34A),
          icon: Icons.eco,
          info:
              'Organic farming avoids synthetic chemicals, supports pollinators, and produces healthier food at slightly lower yields.',
          onChanged: (v) => setState(() => _organic = v),
        ),
        _LandUseSlider(
          label: 'Wildlife Corridors',
          value: _corridors,
          min: 0,
          max: 100,
          color: const Color(0xFF4CAF50),
          icon: Icons.route,
          info:
              'Corridors connect isolated habitats, allowing species to migrate, find mates, and maintain genetic diversity across the landscape.',
          onChanged: (v) => setState(() => _corridors = v),
        ),
        _LandUseSlider(
          label: 'Urban Development',
          value: _urban,
          min: 0,
          max: 200,
          color: const Color(0xFF78909C),
          icon: Icons.location_city,
          info:
              'Urban areas provide housing, jobs, and services for communities. Planning green spaces within cities can reduce environmental impact.',
          onChanged: (v) => setState(() => _urban = v),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: overBudget ? null : _submit,
          icon: const Icon(Icons.check),
          label: const Text('Submit Land Use Plan'),
        ),
        if (overBudget)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'You have allocated ${(-_remaining).toStringAsFixed(0)} ha over the limit. Reduce some allocations.',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final species = (_biodiversity * 4.2 + _corridors * 1.5).round();
    final carbonTons = (_carbonStorage * 120 + _forest * 0.8).round();
    final grade = _totalScore >= 35
        ? 'S'
        : _totalScore >= 25
            ? 'A'
            : _totalScore >= 15
                ? 'B'
                : 'C';
    final gradeColor = _totalScore >= 35
        ? Colors.green
        : _totalScore >= 25
            ? Colors.teal
            : _totalScore >= 15
                ? Colors.amber
                : Colors.orange;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: gradeColor.withValues(alpha: 0.2),
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ecosystem Grade: $grade',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: $_totalScore/40  |  +$_xpEarned XP',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ResultMetricCard(
          icon: Icons.pets,
          title: 'Species Supported',
          value: '$species species',
          subtitle:
              'Your habitat network supports a ${_biodiversity > 70 ? "thriving" : _biodiversity > 50 ? "moderate" : "limited"} range of wildlife.',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _ResultMetricCard(
          icon: Icons.cloud,
          title: 'Carbon Stored',
          value: '${(carbonTons / 1000).toStringAsFixed(1)}k tons CO₂',
          subtitle:
              'Your forests and wetlands sequester carbon equivalent to removing ${(carbonTons / 4600).round()} cars from roads annually.',
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        _ResultMetricCard(
          icon: Icons.groups,
          title: 'Community Impact',
          value: '${_communityWellbeing.round()}/100',
          subtitle: _communityWellbeing > 70
              ? 'Strong balance of food production and economic opportunities.'
              : 'Room to improve community access while protecting nature.',
          color: Colors.amber,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scoring Breakdown',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _ScoreRow(
                  label: 'Biodiversity > 70',
                  met: _biodiversity > 70,
                ),
                _ScoreRow(
                  label: 'Carbon Storage > 60',
                  met: _carbonStorage > 60,
                ),
                _ScoreRow(
                  label: 'Community Well-being > 60',
                  met: _communityWellbeing > 60,
                ),
                _ScoreRow(
                  label: 'All three > 50 (balanced bonus)',
                  met: _biodiversity > 50 &&
                      _carbonStorage > 50 &&
                      _communityWellbeing > 50,
                ),
              ],
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
                  'Your Land Allocation',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _AllocRow('Forest', _forest, 500, const Color(0xFF2E7D32)),
                _AllocRow('Wetland', _wetland, 150, const Color(0xFF0288D1)),
                _AllocRow(
                    'Organic Farming', _organic, 300, const Color(0xFF8BC34A)),
                _AllocRow(
                    'Wildlife Corridors', _corridors, 100, const Color(0xFF4CAF50)),
                _AllocRow(
                    'Urban Development', _urban, 200, const Color(0xFF78909C)),
                if (_remaining > 0)
                  _AllocRow(
                      'Unallocated', _remaining, 1000, Colors.grey.shade300),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            value.round().toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _EcosystemGrid extends StatelessWidget {
  const _EcosystemGrid({
    required this.forest,
    required this.wetland,
    required this.organic,
    required this.corridors,
    required this.urban,
    required this.total,
  });

  final double forest;
  final double wetland;
  final double organic;
  final double corridors;
  final double urban;
  final double total;

  @override
  Widget build(BuildContext context) {
    final size = 20;
    final cells = size * size;
    final cellsForest = (forest / total * cells).round();
    final cellsWetland = (wetland / total * cells).round();
    final cellsOrganic = (organic / total * cells).round();
    final cellsCorridors = (corridors / total * cells).round();
    final cellsUrban = (urban / total * cells).round();
    final cellsEmpty = cells - cellsForest - cellsWetland - cellsOrganic - cellsCorridors - cellsUrban;

    final zones = <_Zone>[];
    for (var i = 0; i < cellsForest; i++) {
      zones.add(_Zone(const Color(0xFF2E7D32), 'F'));
    }
    for (var i = 0; i < cellsWetland; i++) {
      zones.add(_Zone(const Color(0xFF0288D1), 'W'));
    }
    for (var i = 0; i < cellsOrganic; i++) {
      zones.add(_Zone(const Color(0xFF8BC34A), 'O'));
    }
    for (var i = 0; i < cellsCorridors; i++) {
      zones.add(_Zone(const Color(0xFF4CAF50), 'C'));
    }
    for (var i = 0; i < cellsUrban; i++) {
      zones.add(_Zone(const Color(0xFF78909C), 'U'));
    }
    for (var i = 0; i < cellsEmpty.clamp(0, cells); i++) {
      zones.add(_Zone(Colors.grey.shade200, 'E'));
    }
    final shuffled = List<_Zone>.from(zones)..shuffle(Random(42));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: min(shuffled.length, cells),
              itemBuilder: (context, i) {
                return Container(
                  decoration: BoxDecoration(
                    color: shuffled[i].color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _LegendDot(const Color(0xFF2E7D32), 'Forest'),
                _LegendDot(const Color(0xFF0288D1), 'Wetland'),
                _LegendDot(const Color(0xFF8BC34A), 'Organic'),
                _LegendDot(const Color(0xFF4CAF50), 'Corridors'),
                _LegendDot(const Color(0xFF78909C), 'Urban'),
                _LegendDot(Colors.grey.shade200, 'Unallocated'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Zone {
  final Color color;
  final String type;
  _Zone(this.color, this.type);
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _LandUseSlider extends StatefulWidget {
  const _LandUseSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.icon,
    required this.info,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final IconData icon;
  final String info;
  final ValueChanged<double> onChanged;

  @override
  State<_LandUseSlider> createState() => _LandUseSliderState();
}

class _LandUseSliderState extends State<_LandUseSlider> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.color.withValues(alpha: 0.15),
                    child: Icon(widget.icon, color: widget.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${widget.value.round()} ha',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                ],
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: widget.color,
                thumbColor: widget.color,
                overlayColor: widget.color.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: widget.value,
                min: widget.min,
                max: widget.max,
                divisions: widget.max.round(),
                label: '${widget.value.round()} ha',
                onChanged: widget.onChanged,
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                widget.info,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultMetricCard extends StatelessWidget {
  const _ResultMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? Colors.green : Colors.red.shade300,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            met ? '+10' : '0',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: met ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocRow extends StatelessWidget {
  const _AllocRow(this.label, this.value, this.max, this.color);
  final String label;
  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            '${value.round()} ha',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}


