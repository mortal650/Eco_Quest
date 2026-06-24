import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/module_model.dart';

final modulesRepositoryProvider = Provider<ModulesRepository>((ref) {
  return ModulesRepository(FirebaseFirestore.instance);
});

final modulesStreamProvider = StreamProvider<List<EcoModule>>((ref) {
  return ref.watch(modulesRepositoryProvider).watchModules();
});

final moduleDetailProvider =
    StreamProvider.family<EcoModule?, String>((ref, moduleId) {
  return ref.watch(modulesRepositoryProvider).watchModule(moduleId);
});

class ModulesRepository {
  const ModulesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _modulesCol =>
      _firestore.collection('modules');

  Stream<List<EcoModule>> watchModules() {
    return _modulesCol.orderBy('order').snapshots().map(
          (snap) => snap.docs
              .map((doc) => EcoModule.fromJson(doc.data()..['id'] = doc.id))
              .toList(),
        );
  }

  Stream<EcoModule?> watchModule(String id) {
    return _modulesCol.doc(id).snapshots().map(
          (doc) => doc.exists ? EcoModule.fromJson(doc.data()!..['id'] = doc.id) : null,
        );
  }

  Future<void> seedModules() async {
    final batch = _firestore.batch();
    final modules = _modulesCol;

    final data = [
      {
        'title': 'Plastic Pollution',
        'description': 'Impact of plastic on oceans and ecosystems.',
        'icon': 'biotech',
        'order': 1,
        'lessons': [
          {'title': 'Ocean Plastic Crisis', 'content': 'Every year, over 8 million tons of plastic end up in our oceans. This plastic breaks down into microplastics that enter the food chain, affecting marine life and human health. Sea turtles, birds, and fish mistake plastic for food, leading to choking, starvation, and toxic contamination.'},
          {'title': 'Microplastics in Daily Life', 'content': 'Microplastics are found in drinking water, salt, seafood, and even the air we breathe. Studies show the average person ingests about 5 grams of plastic per week — roughly the weight of a credit card. These particles have been found in human blood, lungs, and placenta.'},
          {'title': 'Reducing Your Plastic Footprint', 'content': 'Switch to reusable bags, bottles, and containers. Avoid single-use plastics like straws and cutlery. Choose products with minimal packaging. Support brands that use recycled materials. Participate in local beach or river cleanups to directly remove plastic from the environment.'},
        ],
      },
      {
        'title': 'Rainwater Management',
        'description': 'Efficiently harvesting and managing rainwater.',
        'icon': 'water_drop',
        'order': 2,
        'lessons': [
          {'title': 'Why Rainwater Harvesting Matters', 'content': 'Rainwater harvesting captures runoff from rooftops and surfaces for later use. It reduces stormwater pollution, decreases demand on municipal water supplies, and helps recharge groundwater. In water-scarce regions, it can provide up to 50% of household water needs.'},
          {'title': 'Basic Harvesting Systems', 'content': 'A simple rain barrel system connects to your gutter downspout and stores water for garden use. More advanced systems include first-flush diverters, filtration, and underground cisterns. A 1,000 sq ft roof can collect about 600 gallons per inch of rainfall.'},
          {'title': 'Permeable Surfaces and Bioswales', 'content': 'Replacing concrete with permeable pavers, gravel, or grass allows rainwater to infiltrate the soil naturally. Bioswales are vegetated channels that filter and slow stormwater runoff. Together, these green infrastructure solutions reduce flooding and recharge aquifers.'},
        ],
      },
      {
        'title': 'Energy Sources',
        'description': 'Renewable vs Non-Renewable energy comparison.',
        'icon': 'bolt',
        'order': 3,
        'lessons': [
          {'title': 'Understanding Energy Sources', 'content': 'Non-renewable sources (coal, oil, natural gas) formed over millions of years and release CO2 when burned. Renewable sources (solar, wind, hydro, geothermal) are naturally replenished and produce minimal emissions during operation. The global energy mix is shifting rapidly toward renewables.'},
          {'title': 'Solar and Wind Power', 'content': 'Solar panels convert sunlight directly into electricity using photovoltaic cells. Costs have dropped 89% since 2010. Wind turbines harness kinetic energy from moving air. Together, solar and wind now provide over 12% of global electricity and are the fastest-growing energy sources.'},
          {'title': 'Your Energy Choices', 'content': 'Switch to a green energy provider. Install solar panels or join a community solar program. Improve home insulation to reduce energy waste. Use smart thermostats and LED lighting. Every kilowatt-hour of clean energy displaces about 0.9 pounds of CO2 from fossil fuel plants.'},
        ],
      },
      {
        'title': 'Industrial Agriculture',
        'description': 'Feeding the world sustainably.',
        'icon': 'agriculture',
        'order': 4,
        'lessons': [
          {'title': 'The Environmental Cost of Industrial Farming', 'content': 'Industrial agriculture uses 70% of global freshwater, contributes 25% of greenhouse gas emissions, and is the leading cause of deforestation and biodiversity loss. Heavy use of pesticides and fertilizers pollutes waterways and creates dead zones in oceans.'},
          {'title': 'Regenerative Agriculture', 'content': 'Regenerative farming rebuilds soil health through cover cropping, no-till farming, crop rotation, and composting. Healthy soil sequesters carbon, retains more water, and produces more nutritious food. It can reverse decades of soil degradation while supporting farm profitability.'},
          {'title': 'Sustainable Food Choices', 'content': 'Eat more plant-based meals — livestock farming uses 77% of agricultural land but provides only 18% of calories. Buy local and seasonal produce to reduce transport emissions. Reduce food waste by planning meals and composting scraps. Even one meatless day per week makes a measurable impact.'},
        ],
      },
      {
        'title': 'Climate Change',
        'description': 'Understanding the greenhouse effect.',
        'icon': 'thermostat',
        'order': 5,
        'lessons': [
          {'title': 'The Greenhouse Effect Explained', 'content': 'Greenhouse gases (CO2, methane, nitrous oxide) trap heat in Earth atmosphere like a blanket. Since the Industrial Revolution, CO2 levels have risen from 280ppm to over 420ppm. This extra heat causes glaciers to melt, sea levels to rise, and weather patterns to become more extreme.'},
          {'title': 'Climate Impacts We See Today', 'content': 'Global average temperature has risen 1.1°C above pre-industrial levels. This is causing more intense hurricanes, longer droughts, worse wildfires, and stronger heatwaves. Arctic sea ice is declining at 13% per decade. Sea levels have risen 20cm since 1900 and the rate is accelerating.'},
          {'title': 'Individual Climate Action', 'content': 'The biggest impact areas are diet (plant-based eating), transport (walk, bike, public transit, EVs), energy (renewables), and consumption (buy less, buy better). Calculate your carbon footprint and set reduction targets. Advocate for systemic change through voting and community organizing.'},
        ],
      },
      {
        'title': 'Human Microbiome',
        'description': 'Health and the environment connection.',
        'icon': 'science',
        'order': 6,
        'lessons': [
          {'title': 'Your Inner Ecosystem', 'content': 'Your body hosts trillions of microorganisms — bacteria, fungi, viruses — collectively called the microbiome. Most live in your gut and play crucial roles in digestion, immunity, and even mental health. A diverse microbiome is associated with better health outcomes.'},
          {'title': 'Environmental Factors Affecting Your Microbiome', 'content': 'Exposure to nature, diverse diets rich in fiber, and fermented foods promote microbiome diversity. Antibiotics, processed foods, pollution, and indoor living reduce it. People living near green spaces have more diverse gut bacteria than those in concrete-heavy urban areas.'},
          {'title': 'Protecting Microbial Health', 'content': 'Eat a varied diet with plenty of fruits, vegetables, and fermented foods like yogurt, kimchi, and sauerkraut. Spend time outdoors in natural environments. Avoid unnecessary antibiotics. Support environmental policies that reduce pollution and preserve biodiversity — your microbiome depends on it.'},
        ],
      },
    ];

    for (final module in data) {
      batch.set(modules.doc(), module);
    }

    await batch.commit();
  }
}
