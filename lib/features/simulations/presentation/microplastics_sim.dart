import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/data/user_profile_notifier.dart';

class MicroplasticsSimScreen extends ConsumerStatefulWidget {
  const MicroplasticsSimScreen({super.key});

  @override
  ConsumerState<MicroplasticsSimScreen> createState() =>
      _MicroplasticsSimScreenState();
}

class _MicroplasticsSimScreenState
    extends ConsumerState<MicroplasticsSimScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shieldController;

  int _currentRound = 0;
  double _plasticLevel = 0.0;
  bool _completed = false;
  bool _choseSafe = false;
  int _xpEarned = 0;
  String _lastFact = '';
  bool _showFact = false;

  static const List<_DailyChoice> _choices = [
    _DailyChoice(
      action: 'Bottled Water',
      icon: Icons.water_drop,
      isGood: false,
      plasticChange: 8,
      fact:
          'Plastic water bottles leach microplastics (particles <5mm) into the water, especially when exposed to heat. A single bottle can contain 325,000 microplastic particles.',
    ),
    _DailyChoice(
      action: 'Tea in Plastic Cup',
      icon: Icons.local_cafe,
      isGood: false,
      plasticChange: 10,
      fact:
          'Hot liquids accelerate the leaching of BPA and phthalates from plastic cups. These endocrine disruptors can interfere with hormones and accumulate in colon tissue.',
    ),
    _DailyChoice(
      action: 'Packaged Food',
      icon: Icons.inventory_2,
      isGood: false,
      plasticChange: 7,
      fact:
          'Packaged foods contain microplastics from processing equipment and packaging. Studies found microplastics in 83% of bottled water samples worldwide.',
    ),
    _DailyChoice(
      action: 'Microwave in Plastic',
      icon: Icons.microwave,
      isGood: false,
      plasticChange: 12,
      fact:
          'Heating food in plastic containers releases up to 4.22 billion microplastic particles per square centimeter. BPA and DEHP chemicals leach directly into your food.',
    ),
    _DailyChoice(
      action: 'Steel Water Bottle',
      icon: Icons.water,
      isGood: true,
      plasticChange: -6,
      fact:
          'Stainless steel and glass containers are inert — they don\'t leach chemicals. Using them eliminates a major source of daily microplastic ingestion (avg. 5g/week).',
    ),
    _DailyChoice(
      action: 'Fresh Whole Food',
      icon: Icons.apple,
      isGood: true,
      plasticChange: -5,
      fact:
          'Fresh, unpackaged produce contains no microplastics. Even organic food has 40% less microplastic contamination than processed alternatives.',
    ),
    _DailyChoice(
      action: 'Glass Container',
      icon: Icons.kitchen,
      isGood: true,
      plasticChange: -7,
      fact:
          'Glass is 100% recyclable and non-reactive. It doesn\'t absorb odors or leach any chemicals, making it the safest food storage material.',
    ),
    _DailyChoice(
      action: 'Tupperware for Hot Food',
      icon: Icons.takeout_dining,
      isGood: false,
      plasticChange: 9,
      fact:
          'Not all plastics are microwave-safe. Even "BPA-free" plastics may contain BPS or BPF, which are emerging endocrine disruptors with similar health effects.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _shieldController.dispose();
    super.dispose();
  }

  double get _nutrientAbsorption => (100 - _plasticLevel * 1.5).clamp(0, 100);

  int get _finalScore {
    if (_plasticLevel < 20) return 35;
    if (_plasticLevel < 40) return 35;
    if (_plasticLevel < 60) return 20;
    return 5;
  }

  void _makeChoice(bool safe) {
    final choice = _choices[_currentRound];
    setState(() {
      _choseSafe = safe;
      _showFact = true;
      _lastFact = choice.fact;

      if (safe) {
        _plasticLevel = (_plasticLevel + choice.plasticChange).clamp(0.0, 100.0);
      } else {
        _plasticLevel = (_plasticLevel + choice.plasticChange).clamp(0.0, 100.0);
      }
    });
  }

  void _nextRound() {
    setState(() {
      _showFact = false;
      _choseSafe = false;
      if (_currentRound < _choices.length - 1) {
        _currentRound++;
      } else {
        _completed = true;
        _xpEarned = _finalScore;
        _shieldController.forward();
        _awardXP();
      }
    });
  }

  Future<void> _awardXP() async {
    if (_xpEarned <= 0) return;
    await ref.read(userProfileProvider.notifier).addXP(_xpEarned);
  }

  void _reset() {
    setState(() {
      _currentRound = 0;
      _plasticLevel = 0.0;
      _completed = false;
      _choseSafe = false;
      _xpEarned = 0;
      _lastFact = '';
      _showFact = false;
    });
    _shieldController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Microplastics Shield'),
        actions: [
          if (_completed)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: _completed
            ? _buildResult(context, colorScheme)
            : _buildSimulation(context, colorScheme),
      ),
    );
  }

  Widget _buildSimulation(BuildContext context, ColorScheme colorScheme) {
    final choice = _choices[_currentRound];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Round ${_currentRound + 1} of ${_choices.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        'Plastic: ${_plasticLevel.round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _plasticLevel < 30
                              ? Colors.green
                              : _plasticLevel < 60
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _plasticLevel / 100,
                      minHeight: 12,
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        _plasticLevel < 30
                            ? Colors.green
                            : _plasticLevel < 60
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Colon Plastic Buildup',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      size: const Size(double.infinity, 140),
                      painter: _ColonPainter(
                        plasticLevel: _plasticLevel / 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Colon Cross-Section',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
                children: [
                  Icon(
                    Icons.monitor_heart,
                    size: 28,
                    color: _nutrientAbsorption > 60
                        ? Colors.green
                        : _nutrientAbsorption > 30
                            ? Colors.orange
                            : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nutrient Absorption: ${_nutrientAbsorption.round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _nutrientAbsorption / 100,
                      minHeight: 10,
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        _nutrientAbsorption > 60
                            ? Colors.green
                            : _nutrientAbsorption > 30
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nutrientAbsorption > 60
                        ? 'Healthy absorption rate'
                        : _nutrientAbsorption > 30
                            ? 'Reduced nutrient uptake'
                            : 'Severely impaired absorption',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: choice.isGood
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    child: Icon(
                      choice.icon,
                      size: 30,
                      color: choice.isGood ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    choice.action,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: choice.isGood
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      choice.isGood ? 'Plastic-Free Choice' : 'Microplastic Risk',
                      style: TextStyle(
                        color: choice.isGood ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_showFact) ...[
            Card(
              color: _choseSafe
                  ? Colors.green.withValues(alpha: 0.08)
                  : Colors.orange.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _choseSafe ? Icons.check_circle : Icons.info,
                          color: _choseSafe ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _choseSafe
                                ? 'Plastic reduced by ${choice.plasticChange.abs()}%'
                                : 'Plastic increased by ${choice.plasticChange}%',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastFact,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _nextRound,
                child: Text(
                  _currentRound < _choices.length - 1
                      ? 'Next Day'
                      : 'See Results',
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => _makeChoice(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Choose Safe'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _makeChoice(false),
                      icon: const Icon(Icons.warning),
                      label: const Text('Use Plastic'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, ColorScheme colorScheme) {
    final isProtected = _plasticLevel < 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            color: isProtected
                ? Colors.green.withValues(alpha: 0.1)
                : colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isProtected
                        ? Colors.green.withValues(alpha: 0.2)
                        : colorScheme.error.withValues(alpha: 0.2),
                    child: Icon(
                      isProtected ? Icons.shield : Icons.warning,
                      size: 36,
                      color: isProtected ? Colors.green : colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isProtected
                        ? 'Shield Activated!'
                        : 'Colon Compromised',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plastic Level: ${_plasticLevel.round()}%  |  Nutrient Absorption: ${_nutrientAbsorption.round()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+$_xpEarned XP Earned!',
                      style: TextStyle(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    'Microplastic Facts',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _FactCard(
                    icon: Icons.science,
                    title: 'Particle Size',
                    text:
                        'Microplastics are plastic particles smaller than 5mm. Nanoplastics (<1μm) can cross the gut barrier into the bloodstream.',
                    color: Colors.blue,
                  ),
                  _FactCard(
                    icon: Icons.warning,
                    title: 'BPA (Bisphenol A)',
                    text:
                        'An endocrine disruptor found in polycarbonate plastics. It mimics estrogen and is linked to hormonal imbalances and reproductive issues.',
                    color: Colors.orange,
                  ),
                  _FactCard(
                    icon: Icons.biotech,
                    title: 'Phthalates',
                    text:
                        'Chemicals that make plastics flexible. They leach into food and are associated with developmental and reproductive harm.',
                    color: Colors.purple,
                  ),
                  _FactCard(
                    icon: Icons.water_drop,
                    title: 'Daily Ingestion',
                    text:
                        'Humans ingest approximately 5 grams of microplastic per week — roughly the weight of a credit card.',
                    color: Colors.red,
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
                    'Protective Measures',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _TipItem(
                    icon: Icons.water_drop,
                    text: 'Use stainless steel or glass water bottles instead of plastic.',
                  ),
                  _TipItem(
                    icon: Icons.microwave,
                    text: 'Never heat food in plastic containers — use glass or ceramic.',
                  ),
                  _TipItem(
                    icon: Icons.apple,
                    text: 'Choose fresh, unpackaged foods when possible.',
                  ),
                  _TipItem(
                    icon: Icons.kitchen,
                    text: 'Store food in glass, steel, or ceramic containers.',
                  ),
                  _TipItem(
                    icon: Icons.shopping_bag,
                    text: 'Bring reusable bags and containers for shopping.',
                  ),
                ],
              ),
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
              onPressed: _reset,
              icon: const Icon(Icons.replay),
              label: const Text('Try Again'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ColonPainter extends CustomPainter {
  _ColonPainter({required this.plasticLevel});

  final double plasticLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 10;
    final innerRadius = outerRadius * 0.55;

    final wallPaint = Paint()
      ..color = const Color(0xFFFFCDD2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, outerRadius, wallPaint);

    final lumenPaint = Paint()
      ..color = const Color(0xFFFBE9E7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, lumenPaint);

    final plasticPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final numLayers = (plasticLevel * 20).round();

    for (int i = 0; i < numLayers; i++) {
      final t = i / max(numLayers, 1);
      final r = innerRadius + (outerRadius - innerRadius) * t * 0.9;
      final alpha = (0.3 + plasticLevel * 0.5).clamp(0.0, 1.0);
      plasticPaint.color = Color.lerp(
        Colors.orange,
        Colors.brown,
        plasticLevel,
      )!.withValues(alpha: alpha);

      canvas.drawCircle(
        center,
        r,
        plasticPaint,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: '${(plasticLevel * 100).round()}%',
        style: TextStyle(
          color: Colors.brown.shade700,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );

    final centerLabel = TextPainter(
      text: TextSpan(
        text: 'Lumen',
        style: TextStyle(
          color: Colors.brown.shade400,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    centerLabel.paint(
      canvas,
      Offset(
        center.dx - centerLabel.width / 2,
        center.dy + 10,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ColonPainter oldDelegate) {
    return oldDelegate.plasticLevel != plasticLevel;
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChoice {
  const _DailyChoice({
    required this.action,
    required this.icon,
    required this.isGood,
    required this.plasticChange,
    required this.fact,
  });

  final String action;
  final IconData icon;
  final bool isGood;
  final int plasticChange;
  final String fact;
}
