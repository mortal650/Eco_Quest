import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/data/user_profile_notifier.dart';

class GutHealthSimScreen extends ConsumerStatefulWidget {
  const GutHealthSimScreen({super.key});

  @override
  ConsumerState<GutHealthSimScreen> createState() =>
      _GutHealthSimScreenState();
}

class _GutHealthSimScreenState extends ConsumerState<GutHealthSimScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fermentController;
  late Animation<double> _fermentAnimation;

  int _currentStep = 0;
  int _gutHealthScore = 0;
  bool _completed = false;
  bool _fermenting = false;
  int _selectedMillet = 0;
  int _selectedMethod = 0;
  int _xpEarned = 0;
  String _lastBenefit = '';
  bool _showBenefit = false;
  int _daysCompleted = 0;

  static const List<_Millet> _millets = [
    _Millet(
      name: 'Korallu (Kodo Millet)',
      color: Color(0xFF8D6E63),
      probiotics: 12,
      digestion: 10,
      absorption: 8,
      inflammation: 10,
      benefit:
          'Korallu is rich in antioxidants and has strong anti-inflammatory properties. Its polyphenol content reduces gut inflammation and oxidative stress. Dr. Kadhar Valli recommends it as the base millet for amballi.',
      fact:
          'Kodo millet contains trypsin inhibitors that support digestive enzyme production. It has been used in Siddha medicine for centuries.',
    ),
    _Millet(
      name: 'Andu Korallu (Barnyard Millet)',
      color: Color(0xFFD7CCC8),
      probiotics: 10,
      digestion: 12,
      absorption: 9,
      inflammation: 8,
      benefit:
          'Andu Korallu has the highest fiber content among siridhanyalu (11.5g/100g). Fermentation produces short-chain fatty acids that nourish colon cells and reduce inflammation. Excellent for gut cleansing.',
      fact:
          'Barnyard millet fermentation by Lactobacillus plantarum reduces anti-nutritional factors by 60%, making it ideal for gut restoration.',
    ),
    _Millet(
      name: 'Samalu (Foxtail Millet)',
      color: Color(0xFFFFCC80),
      probiotics: 9,
      digestion: 11,
      absorption: 11,
      inflammation: 7,
      benefit:
          'Samalu has the lowest glycemic index among millets. Fermentation creates resistant starch that feeds beneficial bacteria and improves insulin sensitivity. It contains serotonin for gut-brain axis health.',
      fact:
          'Foxtail millet contains serotonin which helps with mood regulation. Fermentation increases its antioxidant capacity by 40%.',
    ),
    _Millet(
      name: 'Udal (Kodo Variant)',
      color: Color(0xFFBCAAA4),
      probiotics: 8,
      digestion: 9,
      absorption: 10,
      inflammation: 11,
      benefit:
          'Udal supports digestive enzyme production and gut lining repair. Its fermentation produces high levels of lactic acid bacteria that colonize the gut and produce antimicrobial compounds against pathogens.',
      fact:
          'Udal has been traditionally used for gut healing in South Indian medicine. It is particularly effective for IBS symptoms.',
    ),
    _Millet(
      name: 'Arikelu (Browntop Millet)',
      color: Color(0xFFEFEBE9),
      probiotics: 11,
      digestion: 10,
      absorption: 9,
      inflammation: 9,
      benefit:
          'Arikelu is the rarest and most powerful of the siridhanyalu. It has exceptional prebiotic fiber content. Fermentation produces high levels of folate and vitamin K2 for gut and bone health. Dr. Kadhar Valli\'s top recommendation.',
      fact:
          'Browntop millet grows without irrigation, making it environmentally sustainable. It is Dr. Kadhar Valli\'s top recommendation for complete gut restoration.',
    ),
  ];

  static const List<_FermentationMethod> _methods = [
    _FermentationMethod(
      name: 'Traditional Pot Fermentation',
      duration: '24 hours',
      hours: 24,
      bonus: 5,
      description:
          'Clay pot at room temperature. The porous clay creates ideal conditions for Lactobacillus growth. Dr. Kadhar Valli\'s preferred method.',
    ),
    _FermentationMethod(
      name: 'Quick Yogurt Culture',
      duration: '12 hours',
      hours: 12,
      bonus: 3,
      description:
          'Add 2 tbsp curd to soaked millet batter. The existing probiotics accelerate fermentation.',
    ),
    _FermentationMethod(
      name: 'Sprout & Ferment',
      duration: '18 hours',
      hours: 18,
      bonus: 4,
      description:
          'Sprout millet first, then grind and ferment. This doubles the enzyme activity and nutrient availability.',
    ),
  ];

  static const List<_AmballiStep> _steps = [
    _AmballiStep(
      title: 'Cleaning & Sorting',
      description: 'Spread millets on a clean cloth. Remove stones, husks, and damaged grains. Respect the grain — this is the first act of love toward your food.',
      icon: Icons.cleaning_services,
      tip: 'Dr. Kadhar Valli: "Clean the millet carefully. Every grain took 90 days of sunshine to grow."',
    ),
    _AmballiStep(
      title: 'Washing (3-4 times)',
      description: 'Wash the millets thoroughly in clean water. Each wash removes dust, pesticides, and surface impurities. The water should run clear after 3-4 washes.',
      icon: Icons.water_drop,
      tip: 'Washing removes surface contaminants and prepares the millet for soaking.',
    ),
    _AmballiStep(
      title: 'Soaking (8-12 hours)',
      description: 'Soak the washed millets in clean water for 8-12 hours (overnight). Use 1 cup millets to 3 cups water. Soaking activates enzymes and begins breaking down anti-nutrients.',
      icon: Icons.pool,
      tip: 'The water turns slightly yellow — this is normal. The enzymes are activating.',
    ),
    _AmballiStep(
      title: 'Sprouting (12-24 hours)',
      description: 'Drain water after soaking. Tie in a clean cotton cloth. Hang in a warm, dark place for 12-24 hours. Small white sprouts should appear — this doubles the nutrition.',
      icon: Icons.eco,
      tip: 'Dr. Kadhar Valli: "Sprouting doubles the nutrition. The grain is trying to create life — we harness that energy."',
    ),
    _AmballiStep(
      title: 'Grinding',
      description: 'Grind the sprouted millets into a coarse paste. Use a traditional stone grinder (sil batta) or mixer with minimal water. The paste should be slightly coarse, not completely smooth.',
      icon: Icons.blender,
      tip: 'A coarse texture is better — it creates more surface area for fermentation bacteria.',
    ),
    _AmballiStep(
      title: 'Fermentation (12-24 hours)',
      description: 'Transfer paste to a clay pot or glass container. Add 2 tbsp starter culture (previous batch or yogurt). Cover loosely with cloth. Place in warm spot (25-35°C) for 12-24 hours. The batter will rise and develop air pockets.',
      icon: Icons.science,
      tip: 'Dr. Kadhar Valli: "The clay pot breathes. It releases minerals. The fermentation in clay is alive — in metal, it dies."',
    ),
    _AmballiStep(
      title: 'Making Amballi Drink',
      description: 'Mix 1 cup fermented batter with 2 cups cool water (or buttermilk). Add a pinch of rock salt. Stir well — consistency should be like thin porridge. Optionally add curry leaves, ginger, or green chili.',
      icon: Icons.local_cafe,
      tip: 'Serve immediately for maximum probiotic benefit. Never boil amballi after fermentation — you kill the probiotics.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fermentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fermentAnimation = CurvedAnimation(
      parent: _fermentController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fermentController.dispose();
    super.dispose();
  }

  int get _dayScore {
    final m = _millets[_selectedMillet];
    final meth = _methods[_selectedMethod];
    return m.probiotics + m.digestion + m.absorption + m.inflammation + meth.bonus;
  }

  void _startFermentation() {
    setState(() => _fermenting = true);
    _fermentController.forward(from: 0).then((_) {
      setState(() {
        _fermenting = false;
        _gutHealthScore = (_gutHealthScore + _dayScore).clamp(0, 100);
        _showBenefit = true;
        _lastBenefit = _millets[_selectedMillet].benefit;
      });
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      } else {
        _showBenefit = false;
        _daysCompleted++;
        if (_daysCompleted >= 3) {
          _completed = true;
          _xpEarned = _gutHealthScore > 60 ? 40 : (_gutHealthScore > 40 ? 20 : 5);
          _awardXP();
        } else {
          _currentStep = 0;
          _selectedMillet = (_selectedMillet + 1) % _millets.length;
          _selectedMethod = 0;
        }
      }
    });
  }

  Future<void> _awardXP() async {
    if (_xpEarned <= 0) return;
    await ref.read(userProfileProvider.notifier).addXP(_xpEarned);
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _gutHealthScore = 0;
      _completed = false;
      _fermenting = false;
      _selectedMillet = 0;
      _selectedMethod = 0;
      _xpEarned = 0;
      _lastBenefit = '';
      _showBenefit = false;
      _daysCompleted = 0;
    });
    _fermentController.reset();
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
        title: const Text('Amballi Making'),
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
    final millet = _millets[_selectedMillet];
    final step = _steps[_currentStep];

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
                        'Day ${_daysCompleted + 1} of 3',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        'Gut Health: $_gutHealthScore/100',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _gutHealthScore > 60
                              ? Colors.green
                              : _gutHealthScore > 40
                                  ? Colors.orange
                                  : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _gutHealthScore / 100,
                      minHeight: 12,
                      backgroundColor: Colors.brown.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        _gutHealthScore > 60
                            ? Colors.green
                            : _gutHealthScore > 40
                                ? Colors.orange
                                : Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Gut Health Score',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose Your Millet',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _millets.length,
              itemBuilder: (context, index) {
                final m = _millets[index];
                final isSelected = _selectedMillet == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMillet = index),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? m.color.withValues(alpha: 0.3)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? m.color : colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grass,
                            color: m.color,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.name.split(' ')[0],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: isSelected ? m.color : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fermentation Method',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List.generate(_methods.length, (index) {
            final meth = _methods[index];
            final isSelected = _selectedMethod == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected
                    ? Colors.brown.withValues(alpha: 0.1)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.brown : colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedMethod = index),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.brown.withValues(alpha: 0.15),
                          child: Icon(
                            index == 0
                                ? Icons.account_balance
                                : index == 1
                                    ? Icons.local_cafe
                                    : Icons.spa,
                            color: Colors.brown,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meth.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Duration: ${meth.duration}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: Colors.brown, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          if (_fermenting) ...[
            Builder(
              builder: (context) {
                final meth = _methods[_selectedMethod];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.science,
                          size: 40,
                          color: Colors.brown,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Fermenting...',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _fermentAnimation,
                          builder: (context, child) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _fermentAnimation.value,
                                    minHeight: 14,
                                    backgroundColor:
                                        Colors.brown.withValues(alpha: 0.15),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.brown,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(meth.hours * _fermentAnimation.value).round()}/${meth.hours} hours',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meth.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else if (_showBenefit) ...[
            Card(
              color: Colors.green.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Day ${_daysCompleted + 1} Complete!',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastBenefit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BenefitChip(
                          icon: Icons.science,
                          label: 'Probiotics',
                          value: '+${millet.probiotics}',
                        ),
                        _BenefitChip(
                          icon: Icons.restaurant_menu,
                          label: 'Digestion',
                          value: '+${millet.digestion}',
                        ),
                        _BenefitChip(
                          icon: Icons.bloodtype,
                          label: 'Absorption',
                          value: '+${millet.absorption}',
                        ),
                        _BenefitChip(
                          icon: Icons.healing,
                          label: 'Anti-Inflam',
                          value: '+${millet.inflammation}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.brown.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              color: Colors.brown,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                millet.fact,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
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
                onPressed: _nextStep,
                child: Text(
                  _daysCompleted < 2
                      ? 'Start Day ${_daysCompleted + 2}'
                      : 'See Results',
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: step.icon == Icons.science
                          ? Colors.brown.withValues(alpha: 0.2)
                          : colorScheme.primaryContainer,
                      child: Icon(
                        step.icon,
                        color: step.icon == Icons.science
                            ? Colors.brown
                            : colorScheme.onPrimaryContainer,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Step ${_currentStep + 1} of ${_steps.length}',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.brown.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.brown,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step.tip,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _currentStep == _steps.length - 1
                    ? _startFermentation
                    : _nextStep,
                icon: Icon(
                  _currentStep == _steps.length - 1
                      ? Icons.science
                      : Icons.arrow_forward,
                ),
                label: Text(
                  _currentStep == _steps.length - 1
                      ? 'Start Fermentation (${_methods[_selectedMethod].duration})'
                      : 'Next Step',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, ColorScheme colorScheme) {
    final success = _gutHealthScore > 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            color: success
                ? Colors.green.withValues(alpha: 0.1)
                : colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: success
                        ? Colors.green.withValues(alpha: 0.2)
                        : colorScheme.error.withValues(alpha: 0.2),
                    child: Icon(
                      success ? Icons.spa : Icons.refresh,
                      size: 36,
                      color: success ? Colors.green : colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    success
                        ? 'Amballi Mastered!'
                        : 'Keep Practicing!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final Score: $_gutHealthScore/100',
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
                    '3-Day Amballi Progress',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_millets.length, (index) {
                    final m = _millets[index];
                    final dayScore =
                        m.probiotics + m.digestion + m.absorption + m.inflammation;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              m.name.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: dayScore / 50,
                                minHeight: 8,
                                backgroundColor:
                                    m.color.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation(m.color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+$dayScore',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: m.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                    'Amballi Benefits',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _ResultBenefit(
                    icon: Icons.science,
                    title: 'Probiotic Boost',
                    text:
                        'Fermentation increases Lactobacillus count by 10x. These bacteria produce lactic acid that lowers gut pH, inhibiting pathogens.',
                  ),
                  _ResultBenefit(
                    icon: Icons.restaurant_menu,
                    title: 'Improved Digestion',
                    text:
                        'Enzymes produced during fermentation break down complex carbs and proteins, reducing bloating and gas.',
                  ),
                  _ResultBenefit(
                    icon: Icons.bloodtype,
                    title: 'Better Nutrient Absorption',
                    text:
                        'Fermentation reduces phytic acid by 60-80%, unlocking iron, zinc, and calcium for absorption.',
                  ),
                  _ResultBenefit(
                    icon: Icons.healing,
                    title: 'Reduced Inflammation',
                    text:
                        'Short-chain fatty acids (butyrate, propionate) produced during fermentation reduce gut inflammation and strengthen the gut barrier.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.brown.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.brown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dr. Kadhar Valli\'s Advice',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Siridhanyalu (sweet millets) are not just grains — they are medicine for the gut. Fermenting them activates their healing properties. The gut microbiome thrives on diversity — 5 millets in 5 days creates a complete probiotic ecosystem. Start with amballi daily and watch your gut transform.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— Based on Dr. Kadhar Valli\'s Siridhanyalu wellness teachings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
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
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Dashboard'),
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

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.brown),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}

class _ResultBenefit extends StatelessWidget {
  const _ResultBenefit({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.withValues(alpha: 0.15),
            child: Icon(icon, size: 18, color: Colors.green),
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

class _Millet {
  const _Millet({
    required this.name,
    required this.color,
    required this.probiotics,
    required this.digestion,
    required this.absorption,
    this.inflammation = 0,
    required this.benefit,
    required this.fact,
  });

  final String name;
  final Color color;
  final int probiotics;
  final int digestion;
  final int absorption;
  final int inflammation;
  final String benefit;
  final String fact;
}

class _FermentationMethod {
  const _FermentationMethod({
    required this.name,
    required this.duration,
    required this.hours,
    required this.bonus,
    required this.description,
  });

  final String name;
  final String duration;
  final int hours;
  final int bonus;
  final String description;
}

class _AmballiStep {
  const _AmballiStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.tip,
  });

  final String title;
  final String description;
  final IconData icon;
  final String tip;
}
