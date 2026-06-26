import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/data/user_profile_notifier.dart';

class GutMicrobiomeSimScreen extends ConsumerStatefulWidget {
  const GutMicrobiomeSimScreen({super.key});

  @override
  ConsumerState<GutMicrobiomeSimScreen> createState() =>
      _GutMicrobiomeSimScreenState();
}

class _GutMicrobiomeSimScreenState
    extends ConsumerState<GutMicrobiomeSimScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  int _currentRound = 0;
  int _goodBacteria = 50;
  int _badBacteria = 50;
  bool _completed = false;
  bool _choseEat = false;
  int _xpEarned = 0;
  String _lastExplanation = '';
  bool _showExplanation = false;

  static const List<_FoodItem> _foods = [
    _FoodItem(
      name: 'Yogurt',
      icon: Icons.icecream,
      isGood: true,
      goodIncrease: 12,
      badDecrease: 5,
      explanation:
          'Yogurt contains Lactobacillus and Bifidobacterium — live probiotics that colonize your gut and outcompete harmful bacteria. The calcium and protein also support gut lining repair.',
    ),
    _FoodItem(
      name: 'Processed Burger',
      icon: Icons.lunch_dining,
      isGood: false,
      badIncrease: 10,
      goodDecrease: 8,
      explanation:
          'Processed meat is high in saturated fat and preservatives like nitrates. These promote E. coli overgrowth and reduce beneficial bacteria diversity. The emulsifiers in buns can erode the mucus layer protecting your gut wall.',
    ),
    _FoodItem(
      name: 'Fermented Millets',
      icon: Icons.grass,
      isGood: true,
      goodIncrease: 15,
      badDecrease: 7,
      explanation:
          'Fermented millets are rich in prebiotics and probiotics. The fermentation process breaks down anti-nutrients, making minerals more bioavailable. Millets like Ragi and Jowar feed beneficial Lactobacillus species.',
    ),
    _FoodItem(
      name: 'Soda',
      icon: Icons.local_drink,
      isGood: false,
      badIncrease: 8,
      goodDecrease: 10,
      explanation:
          'High sugar content in soda feeds Candida and pathogenic bacteria. The phosphoric acid disrupts stomach pH, killing beneficial microbes. Artificial sweeteners in diet sodas also harm microbiome diversity.',
    ),
    _FoodItem(
      name: 'Kimchi',
      icon: Icons.soup_kitchen,
      isGood: true,
      goodIncrease: 14,
      badDecrease: 6,
      explanation:
          'Kimchi is a fermented vegetable dish loaded with Lactobacillus kimchii. It contains vitamins B and K, and the fiber from cabbage acts as a prebiotic, feeding your good bacteria colonies.',
    ),
    _FoodItem(
      name: 'Chips',
      icon: Icons.fastfood,
      isGood: false,
      badIncrease: 9,
      goodDecrease: 7,
      explanation:
          'Chips are fried in refined oils that promote inflammation in the gut lining. The artificial flavoring and excess salt disrupt the osmotic balance, harmful for gut bacteria. Acrylamide from frying damages gut cells.',
    ),
    _FoodItem(
      name: 'Idli',
      icon: Icons.dinner_dining,
      isGood: true,
      goodIncrease: 11,
      badDecrease: 4,
      explanation:
          'Idli batter is naturally fermented by Lactobacillus and wild yeasts. This fermentation produces beneficial organic acids that lower gut pH, creating an environment hostile to pathogens while feeding good bacteria.',
    ),
    _FoodItem(
      name: 'Pizza',
      icon: Icons.local_pizza,
      isGood: false,
      badIncrease: 7,
      goodDecrease: 9,
      explanation:
          'Pizza combines refined flour (low fiber), excess cheese (saturated fat), and processed toppings. This combination slows gut motility and promotes gas-producing bacteria. The grease can trigger bile acid changes.',
    ),
    _FoodItem(
      name: 'Curd Rice',
      icon: Icons.rice_bowl,
      isGood: true,
      goodIncrease: 13,
      badDecrease: 5,
      explanation:
          'Curd (yogurt) mixed with rice is a traditional probiotic food. The rice starch acts as a prebiotic, while curd provides live cultures. This combination helps restore gut flora after illness or antibiotic use.',
    ),
    _FoodItem(
      name: 'Energy Drink',
      icon: Icons.battery_charging_full,
      isGood: false,
      badIncrease: 11,
      goodDecrease: 6,
      explanation:
          'Energy drinks contain high caffeine, taurine, and artificial stimulants. These chemicals are toxic to many beneficial gut bacteria. The extreme acidity (pH 2.5-3.5) can damage the gut mucosal barrier.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  double get _goodRatio => _goodBacteria / (_goodBacteria + _badBacteria);

  int get _finalScore {
    if (_goodBacteria > 60) return 30;
    if (_goodBacteria > 50) return 15;
    return 5;
  }

  void _makeChoice(bool eat) {
    final food = _foods[_currentRound];
    setState(() {
      _choseEat = eat;
      _showExplanation = true;
      _lastExplanation = food.explanation;

      if (eat) {
        if (food.isGood) {
          _goodBacteria = (_goodBacteria + food.goodIncrease).clamp(0, 100);
          _badBacteria = (_badBacteria - food.badDecrease).clamp(0, 100);
        } else {
          _badBacteria = (_badBacteria + food.badIncrease).clamp(0, 100);
          _goodBacteria = (_goodBacteria - food.goodDecrease).clamp(0, 100);
        }
      }
    });
  }

  void _nextRound() {
    setState(() {
      _showExplanation = false;
      _choseEat = false;
      if (_currentRound < _foods.length - 1) {
        _currentRound++;
      } else {
        _completed = true;
        _xpEarned = _finalScore;
        _gaugeController.forward();
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
      _goodBacteria = 50;
      _badBacteria = 50;
      _completed = false;
      _choseEat = false;
      _xpEarned = 0;
      _lastExplanation = '';
      _showExplanation = false;
    });
    _gaugeController.reset();
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
        title: const Text('Gut Microbiome Balance'),
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
    final food = _foods[_currentRound];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Round ${_currentRound + 1} of ${_foods.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 12, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Good: $_goodBacteria',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.circle, size: 12, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        'Bad: $_badBacteria',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _gaugeAnimation,
              builder: (context, child) {
                final ratio = _completed
                    ? _gaugeAnimation.value * _goodRatio
                    : _goodRatio;
                return CustomPaint(
                  painter: _GutGaugePainter(
                    goodRatio: ratio,
                    goodBacteria: _goodBacteria.toDouble(),
                    badBacteria: _badBacteria.toDouble(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          '${(_goodRatio * 100).round()}%',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _goodRatio > 0.6
                                        ? Colors.green
                                        : _goodRatio > 0.4
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                        ),
                        Text(
                          'Good Bacteria',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                    backgroundColor: food.isGood
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    child: Icon(
                      food.icon,
                      size: 30,
                      color: food.isGood ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    food.name,
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
                      color: food.isGood
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      food.isGood ? 'Probiotic Rich' : 'Gut Disruptor',
                      style: TextStyle(
                        color: food.isGood ? Colors.green : Colors.red,
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
          if (_showExplanation) ...[
            Card(
              color: _choseEat
                  ? (food.isGood
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.red.withValues(alpha: 0.08))
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _choseEat
                              ? (food.isGood
                                  ? Icons.check_circle
                                  : Icons.warning)
                              : Icons.info_outline,
                          color: _choseEat
                              ? (food.isGood ? Colors.green : Colors.red)
                              : colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _choseEat
                              ? (food.isGood
                                  ? 'Great choice! +${food.goodIncrease} good'
                                  : 'Oops! +${food.badIncrease} bad bacteria')
                              : 'Skipped — no change',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastExplanation,
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
                  _currentRound < _foods.length - 1
                      ? 'Next Round'
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
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Eat It'),
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
                      icon: const Icon(Icons.close),
                      label: const Text('Skip'),
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
    final isHealthy = _goodBacteria > 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            color: isHealthy
                ? Colors.green.withValues(alpha: 0.1)
                : colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isHealthy
                        ? Colors.green.withValues(alpha: 0.2)
                        : colorScheme.error.withValues(alpha: 0.2),
                    child: Icon(
                      isHealthy ? Icons.check_circle : Icons.warning,
                      size: 36,
                      color: isHealthy ? Colors.green : colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHealthy
                        ? 'Healthy Microbiome!'
                        : 'Imbalanced Microbiome',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Good: $_goodBacteria  |  Bad: $_badBacteria',
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
                    'Bacteria Breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _BacteriaRow(
                    label: 'Lactobacillus',
                    count: (_goodBacteria * 0.4).round(),
                    color: Colors.green,
                  ),
                  _BacteriaRow(
                    label: 'Bifidobacterium',
                    count: (_goodBacteria * 0.35).round(),
                    color: Colors.teal,
                  ),
                  _BacteriaRow(
                    label: 'Other Beneficial',
                    count: (_goodBacteria * 0.25).round(),
                    color: Colors.lightGreen,
                  ),
                  const Divider(height: 24),
                  _BacteriaRow(
                    label: 'E. coli (overgrowth)',
                    count: (_badBacteria * 0.5).round(),
                    color: Colors.red,
                  ),
                  _BacteriaRow(
                    label: 'Candida',
                    count: (_badBacteria * 0.3).round(),
                    color: Colors.deepOrange,
                  ),
                  _BacteriaRow(
                    label: 'Other Pathogenic',
                    count: (_badBacteria * 0.2).round(),
                    color: Colors.brown,
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
                    'Gut Health Tips',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _TipRow(
                    icon: Icons.spa,
                    text:
                        'Include fermented foods like curd, idli, and kimchi daily to maintain probiotic diversity.',
                  ),
                  _TipRow(
                    icon: Icons.grass,
                    text:
                        'Fermented millets (Ragi, Jowar, Bajra) are prebiotics that feed good bacteria.',
                  ),
                  _TipRow(
                    icon: Icons.warning,
                    text:
                        'Avoid processed foods and sugary drinks — they promote harmful bacteria growth.',
                  ),
                  _TipRow(
                    icon: Icons.science,
                    text:
                        'A healthy gut has 100 trillion bacteria across 1,000+ species. Diversity is key.',
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

class _GutGaugePainter extends CustomPainter {
  _GutGaugePainter({
    required this.goodRatio,
    required this.goodBacteria,
    required this.badBacteria,
  });

  final double goodRatio;
  final double goodBacteria;
  final double badBacteria;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * goodRatio;

    final goodPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      goodPaint,
    );

    final badPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + sweepAngle,
      2 * pi * (1 - goodRatio),
      false,
      badPaint,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < (goodBacteria / 3).round().clamp(0, 30); i++) {
      final angle = Random(i * 7).nextDouble() * 2 * pi;
      final dist = Random(i * 3).nextDouble() * radius * 0.7;
      final offset = Offset(
        center.dx + dist * cos(angle),
        center.dy + dist * sin(angle),
      );
      dotPaint.color = Colors.green.withValues(alpha: 0.6);
      canvas.drawCircle(offset, 3, dotPaint);
    }

    for (int i = 0; i < (badBacteria / 3).round().clamp(0, 30); i++) {
      final angle = Random(i * 13 + 100).nextDouble() * 2 * pi;
      final dist = Random(i * 11 + 50).nextDouble() * radius * 0.7;
      final offset = Offset(
        center.dx + dist * cos(angle),
        center.dy + dist * sin(angle),
      );
      dotPaint.color = Colors.red.withValues(alpha: 0.6);
      canvas.drawCircle(offset, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GutGaugePainter oldDelegate) {
    return oldDelegate.goodRatio != goodRatio ||
        oldDelegate.goodBacteria != goodBacteria ||
        oldDelegate.badBacteria != badBacteria;
  }
}

class _BacteriaRow extends StatelessWidget {
  const _BacteriaRow({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            '$count%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

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

class _FoodItem {
  const _FoodItem({
    required this.name,
    required this.icon,
    required this.isGood,
    this.goodIncrease = 0,
    this.badDecrease = 0,
    this.badIncrease = 0,
    this.goodDecrease = 0,
    required this.explanation,
  });

  final String name;
  final IconData icon;
  final bool isGood;
  final int goodIncrease;
  final int badDecrease;
  final int badIncrease;
  final int goodDecrease;
  final String explanation;
}
