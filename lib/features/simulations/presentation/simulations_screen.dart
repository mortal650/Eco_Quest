import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SimulationsScreen extends StatelessWidget {
  const SimulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Simulations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Learn by doing',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Interactive simulations to practice environmental decision-making.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          _SimulationCard(
            icon: Icons.delete_outline,
            title: 'Waste Segregation',
            description: 'Sort waste into the correct bins. Learn what goes where and why proper disposal matters.',
            color: Colors.green,
            xpReward: 25,
            onTap: () => context.push('/simulations/waste'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.cloud_outlined,
            title: 'Carbon Footprint Calculator',
            description: 'Calculate your daily carbon footprint and discover ways to reduce it.',
            color: Colors.blue,
            xpReward: 30,
            onTap: () => context.push('/simulations/carbon'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.bolt,
            title: 'Renewable Energy Planner',
            description: 'Design an energy system for a city using solar, wind, and other renewables.',
            color: Colors.amber,
            xpReward: 35,
            onTap: () => context.push('/simulations/energy'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.water_drop_outlined,
            title: 'Water Conservation',
            description: 'Manage household water use and learn conservation strategies.',
            color: Colors.cyan,
            xpReward: 25,
            onTap: () => context.push('/simulations/water'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.pets_outlined,
            title: 'Biodiversity Protector',
            description: 'Protect an ecosystem by making decisions about land use and conservation.',
            color: Colors.teal,
            xpReward: 30,
            onTap: () => context.push('/simulations/biodiversity'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.biotech,
            title: 'Gut Microbiome Balance',
            description: 'Balance good vs bad bacteria in your gut through food choices.',
            color: Colors.green,
            xpReward: 30,
            onTap: () => context.push('/simulations/gut-microbiome'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.shield,
            title: 'Microplastics Shield',
            description: 'See how microplastics accumulate in your colon and block nutrient absorption.',
            color: Colors.orange,
            xpReward: 35,
            onTap: () => context.push('/simulations/microplastics'),
          ),
          const SizedBox(height: 12),
          _SimulationCard(
            icon: Icons.spa,
            title: 'Fermented Millets Kitchen',
            description: 'Learn to ferment siridhanyalu the Dr. Kadhar Valli way for gut health.',
            color: Colors.brown,
            xpReward: 40,
            onTap: () => context.push('/simulations/gut-health'),
          ),
        ],
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  const _SimulationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.xpReward,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int xpReward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Icon(Icons.play_circle_outline, color: color),
                  const SizedBox(height: 4),
                  Text(
                    '+$xpReward XP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
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
