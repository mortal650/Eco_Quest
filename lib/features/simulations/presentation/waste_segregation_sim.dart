import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum WasteBin { recyclable, organic, landfill }

class WasteItem {
  final String name;
  final IconData icon;
  final WasteBin correctBin;
  final String explanation;

  const WasteItem({
    required this.name,
    required this.icon,
    required this.correctBin,
    required this.explanation,
  });
}

const List<WasteItem> _wasteItems = [
  WasteItem(
    name: 'Plastic Bottle',
    icon: Icons.local_drink,
    correctBin: WasteBin.recyclable,
    explanation: 'Plastic bottles are recyclable. Rinse them out and place in your recycling bin. They can be turned into new bottles or fiber for clothing.',
  ),
  WasteItem(
    name: 'Banana Peel',
    icon: Icons.eco,
    correctBin: WasteBin.organic,
    explanation: 'Banana peels are organic waste. They decompose naturally and can be composted to create nutrient-rich soil for gardens.',
  ),
  WasteItem(
    name: 'Styrofoam Cup',
    icon: Icons.local_cafe,
    correctBin: WasteBin.landfill,
    explanation: 'Styrofoam cups cannot be recycled in most facilities. They must go to landfill where they will persist for hundreds of years.',
  ),
  WasteItem(
    name: 'Glass Jar',
    icon: Icons.local_bar,
    correctBin: WasteBin.recyclable,
    explanation: 'Glass jars are infinitely recyclable. Clean them out and place in recycling. Glass can be recycled endlessly without losing quality.',
  ),
  WasteItem(
    name: 'Coffee Grounds',
    icon: Icons.coffee,
    correctBin: WasteBin.organic,
    explanation: 'Coffee grounds are perfect for composting. They add nitrogen to compost piles and can even be used as natural fertilizer in gardens.',
  ),
  WasteItem(
    name: 'Battery',
    icon: Icons.battery_std,
    correctBin: WasteBin.landfill,
    explanation: 'Batteries contain hazardous chemicals like lead, mercury, and cadmium. They should NEVER go in recycling or compost. Take them to a hazardous waste collection facility.',
  ),
  WasteItem(
    name: 'Cardboard Box',
    icon: Icons.inventory_2,
    correctBin: WasteBin.recyclable,
    explanation: 'Cardboard boxes are recyclable. Flatten them first to save space. Make sure they are clean and dry before placing in recycling.',
  ),
  WasteItem(
    name: 'Food Scraps',
    icon: Icons.restaurant,
    correctBin: WasteBin.organic,
    explanation: 'Food scraps are organic waste that can be composted. They break down naturally and create valuable compost for plants and soil.',
  ),
  WasteItem(
    name: 'Plastic Bag',
    icon: Icons.shopping_bag,
    correctBin: WasteBin.landfill,
    explanation: 'Most recycling facilities cannot process plastic bags as they jam sorting machines. Return them to grocery store collection bins instead of putting in regular recycling.',
  ),
  WasteItem(
    name: 'Aluminum Can',
    icon: Icons.liquor,
    correctBin: WasteBin.recyclable,
    explanation: 'Aluminum cans are one of the most recyclable items. They can be recycled indefinitely and using recycled aluminum saves 95% of the energy needed to make new aluminum.',
  ),
];

class WasteSegregationSim extends ConsumerStatefulWidget {
  const WasteSegregationSim({super.key});

  @override
  ConsumerState<WasteSegregationSim> createState() => _WasteSegregationSimState();
}

class _WasteSegregationSimState extends ConsumerState<WasteSegregationSim>
    with SingleTickerProviderStateMixin {
  int _currentRound = 0;
  int _score = 0;
  int _xpEarned = 0;
  WasteBin? _selectedBin;
  bool _answered = false;
  bool _showFeedback = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectBin(WasteBin bin) {
    if (_answered) return;

    setState(() {
      _selectedBin = bin;
    });
  }

  void _submitAnswer() {
    if (_selectedBin == null) return;

    final item = _wasteItems[_currentRound];
    final isCorrect = _selectedBin == item.correctBin;

    setState(() {
      _answered = true;
      if (isCorrect) {
        _score++;
        _xpEarned += 2;
      }
    });

    _controller.forward().then((_) {
      setState(() {
        _showFeedback = true;
      });
    });
  }

  void _nextRound() {
    if (_currentRound < _wasteItems.length - 1) {
      setState(() {
        _currentRound++;
        _selectedBin = null;
        _answered = false;
        _showFeedback = false;
      });
      _controller.reset();
    }
  }

  void _restartSimulation() {
    setState(() {
      _currentRound = 0;
      _score = 0;
      _xpEarned = 0;
      _selectedBin = null;
      _answered = false;
      _showFeedback = false;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _currentRound >= _wasteItems.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isComplete ? 'Results' : 'Waste Segregation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: isComplete ? _buildResults(context) : _buildGame(context),
    );
  }

  Widget _buildGame(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = _wasteItems[_currentRound];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentRound + 1) / _wasteItems.length,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentRound + 1} / ${_wasteItems.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sort this item',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the correct bin for this waste item',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _answered
                    ? (_selectedBin == item.correctBin ? _scaleAnimation.value : 1.0)
                    : 1.0,
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _answered
                    ? (_selectedBin == item.correctBin
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15))
                    : colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _answered
                      ? (_selectedBin == item.correctBin ? Colors.green : Colors.red)
                      : colorScheme.primary,
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 48,
                    color: _answered
                        ? (_selectedBin == item.correctBin ? Colors.green : Colors.red)
                        : colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (_showFeedback) ...[
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedBin == item.correctBin
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedBin == item.correctBin ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedBin == item.correctBin
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _selectedBin == item.correctBin ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedBin == item.correctBin ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _selectedBin == item.correctBin ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.explanation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (!_answered) ...[
            _buildBinButtons(context),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedBin == null ? null : _submitAnswer,
                child: const Text('Submit Answer'),
              ),
            ),
          ] else if (_showFeedback) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _nextRound,
                child: Text(
                  _currentRound < _wasteItems.length - 1 ? 'Next Item' : 'See Results',
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBinButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BinButton(
            label: 'Recyclable',
            color: Colors.blue,
            icon: Icons.recycling,
            isSelected: _selectedBin == WasteBin.recyclable,
            onTap: () => _selectBin(WasteBin.recyclable),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BinButton(
            label: 'Organic',
            color: Colors.green,
            icon: Icons.eco,
            isSelected: _selectedBin == WasteBin.organic,
            onTap: () => _selectBin(WasteBin.organic),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BinButton(
            label: 'Landfill',
            color: Colors.grey,
            icon: Icons.delete,
            isSelected: _selectedBin == WasteBin.landfill,
            onTap: () => _selectBin(WasteBin.landfill),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (_score / _wasteItems.length * 100).round();

    String impactMessage;
    if (percentage >= 90) {
      impactMessage = 'Outstanding! You\'re a waste management expert. Your knowledge helps protect the environment and conserve resources.';
    } else if (percentage >= 70) {
      impactMessage = 'Great job! You understand most waste segregation principles. Learning proper disposal helps reduce landfill waste.';
    } else if (percentage >= 50) {
      impactMessage = 'Good effort! Improving your waste sorting skills will help reduce pollution and protect natural habitats.';
    } else {
      impactMessage = 'Keep learning! Understanding waste segregation is crucial for environmental protection. Every correct choice makes a difference.';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            percentage >= 70 ? Icons.emoji_events : Icons.school,
            size: 80,
            color: percentage >= 70 ? Colors.amber : colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            percentage >= 70 ? 'Congratulations!' : 'Good Effort!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You got $_score out of ${_wasteItems.length} correct',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '$_score / ${_wasteItems.length}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage% Accuracy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '+$_xpEarned XP Earned',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Environmental Impact',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  impactMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _restartSimulation,
              child: const Text('Try Again'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BinButton extends StatelessWidget {
  const _BinButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
