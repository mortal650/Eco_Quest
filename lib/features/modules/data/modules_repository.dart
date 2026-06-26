import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/module_model.dart';

final modulesRepositoryProvider = Provider<ModulesRepository>((ref) {
  return ModulesRepository(FirebaseFirestore.instance);
});

final modulesStreamProvider = StreamProvider<List<EcoModule>>((ref) async* {
  final repo = ref.watch(modulesRepositoryProvider);
  yield* repo.watchModules();
});

final autoSeedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(modulesRepositoryProvider);
  return repo.autoSeed();
});

final moduleDetailProvider =
    FutureProvider.family<EcoModule?, String>((ref, moduleId) async {
  final repo = ref.read(modulesRepositoryProvider);
  return repo.getModule(moduleId);
});

class ModulesRepository {
  const ModulesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static const _officialModuleIds = {
    'climate_change',
    'waste_management',
    'renewable_energy',
    'biodiversity',
    'sustainable_living',
    'gut_microbiome',
    'microplastics',
    'gut_health_improvement',
  };

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('modules');

  Stream<List<EcoModule>> watchModules() {
    return _col
        .where(FieldPath.documentId,
            whereIn: _officialModuleIds.toList())
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EcoModule.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<EcoModule?> getModule(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return EcoModule.fromJson(snap.data()!..['id'] = snap.id);
  }

  Future<bool> autoSeed() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) {
      await seedMissingModules();
      await forceReseedGutHealthModule();
      return false;
    }
    await seedModules();
    return true;
  }

  Future<void> seedMissingModules() async {
    final existing = await _col.get();
    final existingIds = existing.docs.map((d) => d.id).toSet();
    final missing = _seedModules.where((m) => !existingIds.contains(m.id)).toList();
    if (missing.isEmpty) return;
    final batch = _firestore.batch();
    for (final module in missing) {
      final data = _moduleToFirestore(module);
      batch.set(_col.doc(module.id), data);
    }
    await batch.commit();
  }

  Future<void> seedModules() async {
    final batch = _firestore.batch();
    for (final module in _seedModules) {
      final data = _moduleToFirestore(module);
      batch.set(_col.doc(module.id), data);
    }
    await batch.commit();
  }

  Map<String, dynamic> _moduleToFirestore(EcoModule module) {
    return {
      'id': module.id,
      'title': module.title,
      'description': module.description,
      'icon': module.icon,
      'order': module.order,
      'lessons': module.lessons
          .map((l) => {'title': l.title, 'content': l.content, 'imageUrl': l.imageUrl})
          .toList(),
      'questions': module.questions
          .map((q) => {
                'id': q.id,
                'question': q.question,
                'options': q.options,
                'correctIndex': q.correctIndex,
                'explanation': q.explanation,
                'difficulty': q.difficulty.name,
              })
          .toList(),
    };
  }

  Future<void> forceReseedModules() async {
    await seedModules();
  }

  Future<void> forceReseedGutHealthModule() async {
    final data = _moduleToFirestore(_gutHealthImprovementModule);
    await _col.doc('gut_health_improvement').set(data);
  }

  Future<ModuleVerificationResult> verifyModules() async {
    final results = <String, ModuleVerification>{};

    for (final module in _seedModules) {
      final snap = await _col.doc(module.id).get();
      if (!snap.exists || snap.data() == null) {
        results[module.id] = ModuleVerification(
          moduleId: module.id,
          exists: false,
          lessonCount: 0,
          expectedLessons: module.lessons.length,
          questionCount: 0,
          expectedQuestions: module.questions.length,
          lessonsMatch: false,
          questionsMatch: false,
        );
        continue;
      }

      final data = snap.data()!;
      final lessons = data['lessons'] as List<dynamic>? ?? [];
      final questions = data['questions'] as List<dynamic>? ?? [];

      results[module.id] = ModuleVerification(
        moduleId: module.id,
        exists: true,
        lessonCount: lessons.length,
        expectedLessons: module.lessons.length,
        questionCount: questions.length,
        expectedQuestions: module.questions.length,
        lessonsMatch: lessons.length == module.lessons.length,
        questionsMatch: questions.length == module.questions.length,
      );
    }

    return ModuleVerificationResult(
      modules: results,
      allPassed: results.values.every(
        (v) => v.exists && v.lessonsMatch && v.questionsMatch,
      ),
    );
  }

  static final _seedModules = <EcoModule>[
    _climateChangeModule,
    _wasteManagementModule,
    _renewableEnergyModule,
    _biodiversityModule,
    _sustainableLivingModule,
    _gutMicrobiomeModule,
    _microplasticsModule,
    _gutHealthImprovementModule,
  ];

  static final _climateChangeModule = EcoModule(
    id: 'climate_change',
    title: 'Climate Change',
    description:
        'Understand the science behind climate change, its global impact, and what we can do to address it.',
    icon: 'thermostat',
    order: 1,
    lessons: [
      const Lesson(
        title: 'Introduction to Climate Change',
        content: '''Climate change refers to long-term shifts in global temperatures and weather patterns. While some climate change is natural, human activities have been the dominant driver since the mid-20th century, primarily through the burning of fossil fuels like coal, oil, and natural gas.

The Earth's average surface temperature has risen approximately 1.1°C since the late 19th century. Most of the warming occurred in the past 50 years, with the seven most recent years being the warmest on record. The Intergovernmental Panel on Climate Change (IPCC) has concluded that it is unequivocal that human influence has warmed the atmosphere, ocean, and land.

Key Concepts:
• The greenhouse effect: gases like CO₂ and methane trap heat in the atmosphere
• Global warming vs. climate change: warming refers to temperature rise, climate change encompasses all weather shifts
• Tipping points: thresholds beyond which changes become irreversible
• Carbon cycle: the natural process by which carbon moves between atmosphere, oceans, soil, and living things

Why It Matters:
Climate change affects every ecosystem and human system on Earth. Rising temperatures lead to more extreme weather events, sea-level rise, biodiversity loss, food insecurity, and displacement of millions of people. Understanding the science is the first step toward meaningful action.''',
      ),
      const Lesson(
        title: 'The Greenhouse Effect Explained',
        content: '''The greenhouse effect is a natural process that warms the Earth's surface. When the Sun's energy reaches the Earth's atmosphere, some of it is reflected back to space and the rest is absorbed and re-radiated by greenhouse gases.

How It Works:
1. Solar radiation passes through the atmosphere
2. The Earth's surface absorbs this energy and warms up
3. The warm surface radiates heat (infrared radiation) back toward space
4. Greenhouse gases absorb some of this outgoing heat and re-emit it in all directions
5. This trapped heat warms the lower atmosphere and surface

The main greenhouse gases are:
• Carbon dioxide (CO₂) - from burning fossil fuels, deforestation. Lifetime: centuries
• Methane (CH₄) - from agriculture, landfills, natural gas. 80x more potent than CO₂ over 20 years
• Nitrous oxide (N₂O) - from fertilizers, industry. 273x more potent than CO₂ over 100 years
• Fluorinated gases - from industrial processes. Can be thousands of times more potent

Without the natural greenhouse effect, Earth's average temperature would be about -18°C instead of the habitable 15°C we experience. The problem is the enhanced greenhouse effect - human activities have increased greenhouse gas concentrations by over 50% since pre-industrial times, trapping excess heat.

Real-World Impact:
The extra trapped energy is equivalent to about 4 Hiroshima bombs of heat being added to the Earth system every second. This excess energy drives the warming and extreme weather we observe.''',
      ),
      const Lesson(
        title: 'Causes of Climate Change',
        content: '''While natural factors influence climate, the overwhelming scientific consensus is that human activities are the primary cause of observed warming since the mid-20th century.

Primary Human Causes:

1. Fossil Fuel Combustion (75% of global greenhouse gas emissions)
   • Burning coal, oil, and gas for electricity, heat, and transportation
   • Releases CO₂ that was locked underground for millions of years
   • The energy sector alone accounts for about 73% of global emissions

2. Deforestation and Land Use Change (11% of emissions)
   • Forests absorb about 2.6 billion tonnes of CO₂ annually
   • When forests are cleared or burned, stored carbon is released
   • Tropical deforestation alone produces about 4.8 GtCO₂ per year

3. Agriculture (12% of emissions)
   • Livestock produce methane during digestion (enteric fermentation)
   • Rice paddies generate methane in flooded conditions
   • Synthetic fertilizers release nitrous oxide
   • Food waste in landfills decomposes and produces methane

4. Industrial Processes (2% of emissions)
   • Cement production: heating limestone releases CO₂
   • Steel production: requires burning coal
   • Chemical manufacturing: various process emissions

Natural Factors (minimal recent contribution):
• Volcanic eruptions: temporary cooling effect
• Solar variations: less than 0.1°C impact
• Orbital changes: operate over thousands of years

Case Study - China and India:
Together these nations account for over 35% of global CO₂ emissions. China alone burns more coal than the rest of the world combined. However, both nations are also leading renewable energy deployment - China installed more solar capacity in 2023 than the entire existing solar capacity of the United States.''',
      ),
      const Lesson(
        title: 'Impacts of Climate Change',
        content: '''Climate change impacts are already being felt across the globe and will intensify without dramatic emission reductions.

Temperature and Weather:
• Global temperatures have risen 1.1°C above pre-industrial levels
• Heatwaves are becoming more frequent, intense, and longer-lasting
• The 2023 global temperature was the hottest in recorded human history
• Extreme weather events have increased by 5x over the past 50 years

Sea Level Rise:
• Global sea levels have risen 20cm since 1900
• Current rate: 3.6mm per year and accelerating
• By 2100, sea levels could rise 0.3-1.0m depending on emissions
• Threatens 800+ million people in coastal cities
• Small island nations like Tuvalu face complete inundation

Ecosystem Disruption:
• Coral bleaching: 50% of the Great Barrier Reef has died since 2016
• Arctic sea ice has declined by 13% per decade since 1979
• Species are shifting ranges poleward at 17km per decade
• Ocean acidification: 30% increase in acidity since pre-industrial times

Human Impacts:
• Food security: Crop yields could decline 2-6% per decade
• Water stress: 3.5 billion people could face water scarcity by 2050
• Health: 250,000 additional deaths per year between 2030-2050 (WHO)
• Climate refugees: 200 million displaced by 2050 (World Bank)
• Economic cost: \`23 trillion annual loss by 2100 under high emissions

Case Study - Pakistan Floods (2022):
Devastating floods covered one-third of Pakistan, affecting 33 million people, destroying 2 million homes, and causing \`30 billion in damage. Climate change made these floods 75% more intense, demonstrating how vulnerable developing nations are to climate impacts they did little to cause.''',
      ),
      const Lesson(
        title: 'Climate Solutions: Mitigation',
        content: '''Mitigation means reducing or preventing greenhouse gas emissions. The goal is to limit warming to 1.5°C above pre-industrial levels, as outlined in the Paris Agreement.

Energy Transition:
• Renewable energy: solar and wind are now the cheapest new electricity sources in most of the world
• Solar costs have dropped 89% since 2010; wind dropped 70%
• Nuclear power: provides reliable zero-carbon baseload electricity
• Energy storage: batteries and pumped hydro enable renewable integration
• Grid modernization: smart grids reduce waste and improve efficiency

Transportation:
• Electric vehicles: EV sales exceeded 14 million in 2023 (18% of all car sales)
• Public transit: a single bus replaces 40+ cars
• Active transport: cycling and walking produce zero emissions
• Sustainable aviation fuels: emerging technology for planes and ships
• Urban planning: compact cities reduce commute distances

Industry and Buildings:
• Green hydrogen: for steel, cement, and chemical production
• Electrification: replacing gas heating with heat pumps
• Building efficiency: better insulation reduces energy use by 50-90%
• Circular economy: recycling and reusing materials reduces manufacturing emissions

Carbon Removal:
• Reforestation: planting trees on degraded land
• Direct air capture: machines that pull CO₂ from the atmosphere
• Enhanced weathering: spreading minerals that absorb CO₂
• Biochar: converting biomass into stable carbon in soil

Policy Tools:
• Carbon pricing: making polluters pay for emissions
• Regulations: efficiency standards for vehicles and buildings
• Subsidies: supporting clean energy deployment
• International agreements: Paris Agreement, COP processes

Key Fact: We already have the technology to reduce emissions by 80% by 2050. The main barriers are political will and investment, not technology.''',
      ),
      const Lesson(
        title: 'Climate Solutions: Adaptation',
        content: '''Adaptation means adjusting to the climate change that is already happening or is inevitable. Even with aggressive mitigation, some impacts are locked in.

Infrastructure Resilience:
• Flood defenses: sea walls, levees, and natural barriers like mangroves
• Heat-resistant infrastructure: reflective surfaces, green roofs, urban forests
• Water management: improved drainage, rainwater harvesting, desalination
• Building codes: designing for extreme weather events

Agricultural Adaptation:
• Drought-resistant crops: breeding and genetic engineering
• Precision agriculture: using data to optimize water and fertilizer use
• Crop diversification: reducing risk through variety
• Changed planting times: adjusting to shifting seasons
• Vertical farming: growing food in controlled indoor environments

Ecosystem-Based Adaptation:
• Mangrove restoration: protects coastlines and sequesters carbon
• Coral reef restoration: breeding heat-resistant coral strains
• Urban green spaces: reduce heat island effect by 2-8°C
• Wetland preservation: natural flood control and water filtration

Community Resilience:
• Early warning systems: predicting extreme weather events
• Climate-resilient housing: designed for local hazards
• Water conservation: reducing demand in water-stressed regions
• Insurance mechanisms: protecting against climate losses
• Indigenous knowledge: traditional practices adapted to local conditions

Case Study - The Netherlands:
With 26% of the country below sea level, the Netherlands is a global leader in climate adaptation. Their "Room for the River" program deliberately flooded certain areas to protect others. They've created floating farms, water plazas that become parks in dry weather and reservoirs during storms, and building codes requiring all new construction to account for climate change.''',
      ),
      const Lesson(
        title: 'Your Role in Climate Action',
        content: '''Individual action matters. While systemic change is essential, personal choices create demand for sustainable products, influence social norms, and demonstrate political will.

High-Impact Personal Actions:
1. Switch to renewable energy (saves 1.5 tonnes CO₂/year)
2. Eat less meat, especially beef (0.8 tonnes CO₂/year per dietary shift)
3. Fly less (2.5 tonnes CO₂ per round-trip transatlantic flight)
4. Switch to an electric vehicle (2.4 tonnes CO₂/year)
5. Improve home insulation (0.9 tonnes CO₂/year)

Everyday Choices:
• Reduce, reuse, repair before buying new
• Buy local and seasonal food when possible
• Conserve water and electricity at home
• Choose sustainable transportation
• Support businesses with strong environmental practices

Community Action:
• Join or support local environmental organizations
• Advocate for climate-friendly policies
• Educate friends and family about climate change
• Participate in community gardens and tree planting
• Vote for leaders who prioritize climate action

Systemic Change:
• Support carbon pricing policies
• Advocate for renewable energy incentives
• Push for corporate accountability
• Demand climate education in schools
• Support climate justice for vulnerable communities

Reflection Questions:
1. What are the three highest-impact changes you could make in your own life?
2. How can you influence your workplace or school to be more sustainable?
3. What barriers prevent you from making climate-friendly choices?
4. How does climate change intersect with social justice issues?
5. What gives you hope about addressing climate change?

Key Insight: Research shows that talking about climate change is itself an action. When you discuss it with others, you normalize concern and create social momentum for change.''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'cc_easy_1',
        question:
            'What is the primary greenhouse gas emitted by human activities?',
        options: [
          'Water vapor',
          'Carbon dioxide (CO₂)',
          'Oxygen',
          'Nitrogen',
        ],
        correctIndex: 1,
        explanation:
            'Carbon dioxide (CO₂) is the primary greenhouse gas emitted through human activities, mainly from burning fossil fuels. While water vapor is the most abundant greenhouse gas, it is not directly emitted by human activities in significant amounts.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'cc_easy_2',
        question:
            'By how much has Earth\'s average temperature risen since the late 19th century?',
        options: ['About 0.3°C', 'About 1.1°C', 'About 3.0°C', 'About 5.5°C'],
        correctIndex: 1,
        explanation:
            'Earth\'s average surface temperature has risen approximately 1.1°C since the late 19th century. While this may seem small, it has significant impacts on global weather patterns, sea levels, and ecosystems.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'cc_medium_1',
        question:
            'A farmer in a drought-prone region wants to adapt to climate change. Which strategy is MOST effective?',
        options: [
          'Plant only one type of crop for efficiency',
          'Install drip irrigation and plant drought-resistant crop varieties',
          'Increase fertilizer use to boost yields',
          'Wait for government rain subsidies',
        ],
        correctIndex: 1,
        explanation:
            'Installing drip irrigation (which delivers water directly to plant roots, reducing waste by 30-50%) and planting drought-resistant varieties combines water efficiency with climate resilience. Monoculture increases risk, and more fertilizer does not address water scarcity.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'cc_medium_2',
        question:
            'Why is methane (CH₄) considered particularly dangerous despite being less abundant than CO₂?',
        options: [
          'It lasts longer in the atmosphere than CO₂',
          'It is 80x more potent than CO₂ over 20 years',
          'It cannot be reduced by any technology',
          'It only affects marine ecosystems',
        ],
        correctIndex: 1,
        explanation:
            'Methane is approximately 80 times more potent than CO₂ at trapping heat over a 20-year period. Although it has a shorter atmospheric lifetime (~12 years vs. centuries for CO₂), its high potency makes reducing methane emissions a critical near-term climate strategy.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'cc_hard_1',
        question:
            'Scenario: A developing nation with rapidly growing energy demand must choose between cheap coal power and expensive renewable energy. What is the BEST long-term strategy?',
        options: [
          'Use coal now because it is cheaper, and switch to renewables later',
          'Invest in renewables with international climate finance support, combined with energy efficiency measures',
          'Skip electricity development entirely to avoid emissions',
          'Wait until renewable technology becomes cheaper before building any power plants',
        ],
        correctIndex: 1,
        explanation:
            'Investing in renewables with international climate finance (like the Green Climate Fund) while implementing energy efficiency measures avoids locking in fossil fuel infrastructure. Coal plants operate for 30-40 years, creating "carbon lock-in." Many developing nations can leapfrog fossil fuels, similar to how mobile phones leapfrogged landlines.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'cc_hard_2',
        question:
            'Scenario: A city experiences increasing heatwaves. Which combination of adaptation strategies provides the MOST comprehensive protection?',
        options: [
          'Build more air conditioning units for all buildings',
          'Plant urban forests, install cool roofs, create early warning systems, and establish cooling centers for vulnerable populations',
          'Relocate the entire city to a cooler region',
          'Only increase the city\'s water supply',
        ],
        correctIndex: 1,
        explanation:
            'A comprehensive approach combines nature-based solutions (urban forests reduce temperatures 2-8°C), building modifications (cool roofs reflect sunlight), social infrastructure (early warning systems and cooling centers protect vulnerable people), and addresses multiple aspects of heat risk.单一措施无法解决复杂问题。',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _wasteManagementModule = EcoModule(
    id: 'waste_management',
    title: 'Waste Management',
    description:
        'Learn about the waste crisis, circular economy principles, and how proper waste management protects our environment.',
    icon: 'recycling',
    order: 2,
    lessons: [
      const Lesson(
        title: 'The Global Waste Crisis',
        content: '''The world generates over 2 billion tonnes of municipal solid waste annually, and this is expected to increase to 3.4 billion tonnes by 2050. Only 13.5% is recycled and 5.5% is composted, meaning over 80% of waste ends up in landfills or the environment.

The Scale of the Problem:
• 2.01 billion tonnes of municipal solid waste generated annually
• 33% of the world's food is wasted (1.3 billion tonnes/year)
• 8 million tonnes of plastic enter the ocean every year
• By 2050, there could be more plastic than fish in the ocean by weight
• E-waste is the fastest growing waste stream: 54 million tonnes/year

Landfill Impacts:
• Produce methane, a potent greenhouse gas (20% of global methane emissions)
• Leach toxic chemicals into groundwater
• Take up valuable land that could be used for housing or nature
• Contaminate soil for decades
• Create visual pollution and reduce property values

Environmental Justice:
• Landfills and incinerators are disproportionately located near low-income communities and communities of color
• Waste workers in developing countries face hazardous conditions
• Ocean plastic primarily comes from 10 rivers in Asia and Africa
• The poorest 20% of the world's population generates less than 5% of global waste

The Linear Economy Problem:
Our current economic model follows a "take-make-dispose" pattern:
1. Extract raw materials
2. Manufacture products
3. Use briefly
4. Discard as waste

This is fundamentally unsustainable on a finite planet. The solution is the circular economy.''',
      ),
      const Lesson(
        title: 'Understanding the Waste Hierarchy',
        content: '''The waste hierarchy provides a framework for managing waste in order of environmental preference. Think of it as a pyramid, with the most preferred option at the top.

The 5 R's (in order of priority):

1. REFUSE (Most Preferred)
   • Say no to things you don't need
   • Decline single-use items (straws, bags, cutlery)
   • Choose products with minimal packaging
   • Example: Bringing your own bag to the store

2. REDUCE
   • Buy less and buy better
   • Choose quality over quantity
   • Reduce food waste through meal planning
   • Example: Buying a reusable water bottle instead of disposable ones

3. REUSE
   • Find new purposes for items
   • Repair broken items instead of replacing
   • Donate usable items
   • Example: Using glass jars as storage containers

4. RECYCLE
   • Convert waste materials into new products
   • Requires proper sorting and cleaning
   • Reduces need for raw material extraction
   • Example: Recycling aluminum cans saves 95% of the energy needed to make new aluminum

5. ROT (Compost) (Least Preferred before disposal)
   • Decompose organic waste naturally
   • Returns nutrients to soil
   • Reduces methane from landfills
   • Example: Composting food scraps and yard waste

What NOT to do:
• Burning waste releases toxic chemicals and greenhouse gases
• Dumping in waterways kills wildlife
• Illegal dumping contaminates soil and water
• Overfilling landfills accelerates climate change

Key Insight: Recycling alone cannot solve the waste crisis. We must prioritize refusing and reducing first. Even the best recycling system only recovers 60-70% of materials.''',
      ),
      const Lesson(
        title: 'Plastic Waste and Ocean Pollution',
        content: '''Plastic pollution is one of the most visible and damaging environmental crises of our time. Understanding its lifecycle and impacts is essential for effective action.

The Plastic Problem:
• 400 million tonnes of plastic produced annually (doubled since 2000)
• Only 9% of all plastic ever made has been recycled
• 12% has been incinerated
• 79% has accumulated in landfills or the environment
• Plastic takes 400-1000 years to decompose
• Microplastics have been found in human blood, lungs, and placenta

How Plastic Reaches the Ocean:
1. Improper waste management in coastal cities
2. River transport (8 rivers carry 90% of ocean plastic)
3. Fishing gear lost at sea (ghost nets)
4. Stormwater runoff carrying litter
5. Direct dumping

Impacts on Marine Life:
• 1 million seabirds and 100,000 marine mammals die annually from plastic
• Sea turtles mistake plastic bags for jellyfish
• Whales have been found with 40kg of plastic in their stomachs
• Microplastics enter the food chain from plankton to humans
• Coral reefs are smothered by plastic debris

Microplastics:
• Fragments smaller than 5mm
• Come from breakdown of larger plastics, synthetic clothing fibers, tire wear
• Found in drinking water, food, and air
• Carry toxic chemicals that leach into organisms
• Effects on human health are still being studied

Solutions:
• Extended Producer Responsibility (EPR): making manufacturers responsible for end-of-life
• Plastic taxes and bans on single-use items
• Improved waste collection infrastructure in developing countries
• Ocean cleanup technologies (though prevention is better than cleanup)
• Developing truly biodegradable alternatives
• Reducing plastic production at source

Case Study - Rwanda:
Rwanda banned single-use plastic bags in 2008. The country now has one of the cleanest environments in Africa. Plastic bags are illegal to manufacture, import, or sell. Violators face fines up to `100 or imprisonment. This demonstrates that policy change can work when enforced consistently.''',
      ),
      const Lesson(
        title: 'The Circular Economy',
        content: '''The circular economy is an economic system aimed at eliminating waste and promoting the continual use of resources. It contrasts with the traditional linear economy of "take-make-dispose."

Core Principles:
1. Design out waste and pollution
2. Keep products and materials in use
3. Regenerate natural systems

How It Works:
Instead of the linear model:
Raw materials → Products → Waste

The circular model creates loops:
Raw materials → Products → Use → Collection → Sorting → Processing → New Products

Key Strategies:

Product Design:
• Design for durability and repairability
• Use modular components that can be replaced
• Choose materials that can be recycled or composted
• Avoid toxic materials that contaminate recycling streams

Sharing and Service Models:
• Product-as-a-service (leasing instead of owning)
• Sharing platforms (car-sharing, tool libraries)
• Refurbishment and remanufacturing
• Example: Patagonia's Worn Wear program repairs used clothing

Industrial Symbiosis:
• One company's waste becomes another's raw material
• Example: Brewery grain waste used to make bread
• Reduces overall waste and creates economic value

Biological Cycle:
• Organic materials return to the soil through composting
• Nutrients feed new plant growth
• Creates a closed loop for biodegradable materials

Economic Benefits:
• `4.5 trillion opportunity by 2030 (Accenture)
• Creates 6x more jobs than the linear economy
• Reduces material costs for businesses
• Builds resilience against supply chain disruptions

Case Study - The Netherlands:
The Dutch government aims to be fully circular by 2050. Amsterdam has implemented a "circular strategy" focusing on five key sectors: food, consumer goods, manufacturing, construction, and transport. The city requires all new construction to use 20% recycled materials and be designed for disassembly.''',
      ),
      const Lesson(
        title: 'Food Waste: A Hidden Crisis',
        content: '''Food waste is a massive environmental, economic, and social problem. One-third of all food produced globally is lost or wasted.

The Numbers:
• 1.3 billion tonnes of food wasted annually
• Worth `1 trillion per year
• Food waste generates 8-10% of global greenhouse gas emissions
• If food waste were a country, it would be the third-largest emitter after the USA and China

Where Food Is Lost:
• Farm level: imperfect produce left in fields, storage losses
• Processing: trimming, quality standards, overproduction
• Distribution: transportation damage, cold chain failures
• Retail: overstocking, cosmetic standards, expiration dates
• Consumer: overbuying, poor storage, confusion about dates

Environmental Impact:
• Wastes 25% of global freshwater used in food production
• Wastes 1.4 billion hectares of agricultural land (28% of world's farmland)
• Food in landfills decomposes anaerobically, producing methane
• Packaging, transportation, and production resources are all wasted

Solutions at Different Levels:

Government:
• Standardize date labeling ("best before" vs. "use by")
• Tax incentives for food donation
• Invest in cold chain infrastructure
• Support ugly produce programs

Business:
• AI-powered demand forecasting
• Dynamic pricing for near-expiry items
• Staff meals from surplus food
• Partnerships with food banks

Individual:
• Meal planning and smart shopping lists
• Proper food storage techniques
• Understanding date labels (best before ≠ unsafe after)
• Composting unavoidable food waste
• Buying "ugly" produce

Case Study - South Korea:
South Korea implemented a volume-based waste fee system where residents pay for food waste by weight. This reduced food waste by 30% and increased recycling to 95%. The country now converts food waste into animal feed, compost, and biogas.''',
      ),
      const Lesson(
        title: 'E-Waste and Hazardous Materials',
        content: '''Electronic waste (e-waste) is the fastest-growing waste stream globally, with 54 million tonnes generated annually. Only 17% is properly recycled.

The E-Waste Problem:
• Contains both valuable and toxic materials
• One tonne of circuit boards contains 40-800 times more gold than one tonne of ore
• Contains lead, mercury, cadmium, and brominated flame retardants
• Improper disposal contaminates soil, water, and air
• Workers in informal recycling face severe health risks

Why E-Waste Matters:
• 50+ elements from the periodic table are in a smartphone
• Many are rare earth elements with limited supply
• Mining these materials causes environmental destruction
• Proper recycling recovers valuable materials
• Reduces the need for new mining

Current Challenges:
• Rapid product obsolescence (planned and perceived)
• Lack of repairability (glued batteries, proprietary screws)
• Complex material compositions make recycling difficult
• Informal recycling in developing countries is dangerous
• Illegal export of e-waste to countries with weaker regulations

Solutions:

Design:
• Right to repair legislation
• Modular design for easy disassembly
• Using fewer hazardous materials
• Extended producer responsibility (EPR)

Individual Actions:
• Repair instead of replace
• Buy refurbished electronics
• Donate working devices
• Use certified e-waste recyclers
• Properly wipe data before disposal

Policy:
• EPR schemes requiring manufacturers to fund recycling
• Banning export of e-waste to developing countries
• Mandatory minimum recycled content in new electronics
• Banning planned obsolescence

Case Study - Apple's Daisy Robot:
Apple developed "Daisy," a robot that can disassemble 23 models of iPhones at a rate of 200 per hour. It recovers 15 materials including rare earth elements, tungsten, and steel. This demonstrates that technology can solve e-waste challenges when companies invest in circular design.''',
      ),
      const Lesson(
        title: 'Taking Action on Waste',
        content: '''Every individual can significantly reduce their waste footprint through conscious choices and behavioral changes.

Personal Waste Audit:
Start by tracking your waste for one week. Categorize it into:
• Recyclables (paper, plastic, metal, glass)
• Organic waste (food scraps, yard waste)
• Landfill waste (non-recyclable items)
• Hazardous waste (batteries, electronics, chemicals)

This reveals where you can make the biggest impact.

High-Impact Changes:

1. Refuse single-use items
   • Bring reusable bags, bottles, cups, and containers
   • Decline freebies you don't need
   • Choose package-free options

2. Transform your kitchen
   • Meal plan to reduce food waste
   • Use all parts of vegetables (stems, peels for stock)
   • Compost food scraps
   • Store food properly to extend shelf life

3. Shop mindfully
   • Buy in bulk with reusable containers
   • Choose products with minimal packaging
   • Buy quality items that last longer
   • Support companies with circular practices

4. Manage your closet
   • Buy fewer, better quality clothes
   • Repair and mend existing clothes
   • Donate or sell items you no longer need
   • Choose natural fibers (cotton, wool, linen) over synthetics

5. Handle hazardous waste properly
   • Take electronics to certified recyclers
   • Use up household chemicals before switching
   • Never pour chemicals down the drain
   • Return batteries and light bulbs to collection points

Community Action:
• Organize neighborhood cleanup events
• Advocate for better recycling infrastructure
• Support local composting programs
• Push for plastic bag bans and bottle deposits
• Start a repair cafe or tool library

Reflection Questions:
1. What percentage of your trash could you divert from landfill?
2. Which single-use item do you use most, and what is the reusable alternative?
3. How could you influence your workplace or school to reduce waste?
4. What systemic changes would make waste reduction easier for everyone?
5. How does waste connect to climate change and social justice?''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'wm_easy_1',
        question:
            'What percentage of all plastic ever made has been recycled?',
        options: ['About 50%', 'About 25%', 'About 9%', 'About 75%'],
        correctIndex: 2,
        explanation:
            'Only about 9% of all plastic ever produced has been recycled. The vast majority (79%) has ended up in landfills or the environment, with 12% incinerated. This highlights the urgent need to reduce plastic production and improve recycling systems.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'wm_easy_2',
        question:
            'Which of the 5 R\'s is the MOST preferred option in the waste hierarchy?',
        options: ['Recycle', 'Reuse', 'Refuse', 'Rot (compost)'],
        correctIndex: 2,
        explanation:
            'Refuse is the most preferred option because it prevents waste from being created in the first place. The waste hierarchy in order of preference is: Refuse, Reduce, Reuse, Recycle, Rot.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'wm_medium_1',
        question:
            'A city wants to reduce food waste by 40%. Which combination of strategies would be MOST effective?',
        options: [
          'Only build more landfills to handle the waste',
          'Implement mandatory composting, standardize date labeling, support food donation programs, and require restaurants to offer smaller portions',
          'Ban all restaurants from serving large portions',
          'Only focus on consumer education',
        ],
        correctIndex: 1,
        explanation:
            'A comprehensive approach combining mandatory composting (diverts organic waste), standardized date labeling (reduces consumer confusion), food donation programs (redistributes surplus), and portion options (prevents plate waste) addresses multiple points in the food waste chain.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'wm_medium_2',
        question:
            'Why is "planned obsolescence" a problem for waste management?',
        options: [
          'It makes products too expensive',
          'It deliberately shortens product lifespan, increasing waste generation and resource consumption',
          'It only affects the technology industry',
          'It makes recycling more difficult',
        ],
        correctIndex: 1,
        explanation:
            'Planned obsolescence deliberately designs products to become outdated or break down, forcing consumers to replace them more frequently. This increases waste generation, resource consumption, and environmental impact across all product categories.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'wm_hard_1',
        question:
            'Scenario: A developing country receives international funding to improve waste management. They have limited infrastructure and high unemployment. What approach would be MOST sustainable?',
        options: [
          'Build a large modern incinerator for all waste',
          'Invest in informal waste picker cooperatives, build material recovery facilities, create composting programs, and develop local recycling industries that create jobs',
          'Ship all waste to developed countries for processing',
          'Focus only on collecting waste and sending it to landfills',
        ],
        correctIndex: 1,
        explanation:
            'This integrated approach leverages existing informal waste workers (who already recover valuable materials), creates formal jobs through material recovery facilities, produces compost for local agriculture, and builds a circular economy. It addresses both environmental and social objectives simultaneously.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'wm_hard_2',
        question:
            'Scenario: A company wants to switch from plastic packaging to "biodegradable" alternatives. What is the MOST important consideration?',
        options: [
          'Any biodegradable material is automatically better than plastic',
          'Ensure the material actually biodegrades in the conditions where it will end up (e.g., industrial composting vs. landfill), and consider the full lifecycle including production impacts',
          'Choose the cheapest biodegradable option available',
          'Simply replace plastic with paper without further analysis',
        ],
        correctIndex: 1,
        explanation:
            'Many "biodegradable" materials only break down under specific industrial composting conditions, not in landfills or the ocean. Additionally, the production of alternatives may have higher environmental impacts than plastic. A full lifecycle analysis is essential to ensure the switch actually reduces overall environmental harm.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _renewableEnergyModule = EcoModule(
    id: 'renewable_energy',
    title: 'Renewable Energy',
    description:
        'Explore solar, wind, hydro, and other clean energy sources that are powering the transition to a sustainable future.',
    icon: 'bolt',
    order: 3,
    lessons: [
      const Lesson(
        title: 'The Energy Transition',
        content: '''The world is undergoing the largest energy transition in history, moving from fossil fuels to renewable sources. This shift is driven by climate necessity, economic opportunity, and technological advancement.

Why the Transition Matters:
• Energy production accounts for 73% of global greenhouse gas emissions
• Fossil fuels are finite resources with volatile prices
• Air pollution from fossil fuels causes 8.7 million premature deaths annually
• Renewable energy is now the cheapest source of new electricity in most of the world

The Scale of Change Needed:
• Current global energy mix: 80% fossil fuels, 13% renewables, 7% nuclear
• Required by 2050: 90%+ clean energy for net-zero emissions
• Investment needed: `4-5 trillion per year in clean energy
• Current investment: approximately `1.8 trillion per year

Key Milestones:
• 2023: Solar became the cheapest source of electricity in history
• 2023: Renewable energy accounted for 86% of new power capacity added globally
• 2023: Global renewable capacity exceeded 3,800 GW
• EV sales exceeded 14 million (18% of all car sales)
• Battery storage costs dropped 97% since 1991

Barriers to Transition:
• Fossil fuel subsidies (`7 trillion annually including externalities)
• Grid infrastructure needs massive upgrades
• Intermittency requires storage solutions
• Political resistance from fossil fuel interests
• Supply chain concentration for critical minerals

The Good News:
Every year, renewable energy gets cheaper and fossil fuels get more expensive. The economic case for clean energy is now stronger than the case for fossil fuels in most markets.''',
      ),
      const Lesson(
        title: 'Solar Energy',
        content: '''Solar energy harnesses radiation from the sun to generate electricity or heat. It is the most abundant energy source on Earth and the fastest-growing electricity source.

How Solar Panels Work:
1. Photovoltaic (PV) cells contain semiconductor materials (usually silicon)
2. When sunlight hits the cell, photons knock electrons loose from atoms
3. This creates an electric current
4. Multiple cells form a panel; multiple panels form an array
5. An inverter converts DC electricity to AC for home/grid use

Types of Solar Technology:
• Monocrystalline silicon: 20-22% efficiency, most common
• Polycrystalline silicon: 15-17% efficiency, cheaper
• Thin-film: 10-13% efficiency, flexible, used in buildings
• Perovskite: emerging technology, 25%+ efficiency potential
• Concentrated solar power (CSP): uses mirrors to focus sunlight, generates heat to drive turbines

Solar Economics:
• Cost has dropped 89% since 2010
• Average cost: `20-40 per MWh (cheaper than coal and gas)
• Payback period: 5-10 years depending on location
• Lifespan: 25-30+ years with minimal maintenance
• ROI: 10-20% annually in sunny regions

Solar + Storage:
• Batteries store excess solar for use at night or cloudy days
• Tesla Powerwall: 13.5 kWh capacity, powers average home for 12 hours
• Virtual power plants: networks of home batteries supporting the grid
• Vehicle-to-grid: EVs can power homes during outages

Limitations:
• Intermittent (no power at night, reduced on cloudy days)
• Requires significant land area for large-scale solar
• Manufacturing has environmental impacts (silicon processing)
• End-of-life panel recycling is still developing

Case Study - India:
India aims for 500 GW of renewable energy by 2030. The Bhadla Solar Park in Rajasthan covers 14,000 acres and generates 2,245 MW - enough to power 4.5 million homes. India's solar costs have dropped 85% in the past decade, making it one of the cheapest solar markets globally.''',
      ),
      const Lesson(
        title: 'Wind Energy',
        content: '''Wind energy converts the kinetic energy of moving air into electricity using wind turbines. It is one of the most mature and cost-effective renewable energy technologies.

How Wind Turbines Work:
1. Wind flows over the blade shaped like an airplane wing
2. The blade creates lift, causing it to turn
3. The blade connects to a rotor (typically 3 blades)
4. The rotor spins a generator that produces electricity
5. A gearbox increases the rotation speed for the generator
6. A controller adjusts the turbine's direction to face the wind

Types of Wind Farms:
• Onshore: located on land, most common and cheapest
• Offshore: located at sea, stronger and more consistent winds
• Floating offshore: anchored to seabed, enables deeper water installations
• Distributed: small turbines on buildings or homes

Wind Energy Facts:
• Global installed capacity: 906 GW (2023)
• Generates about 7.5% of global electricity
• A single modern turbine can power 1,500+ homes
• Offshore wind capacity factors: 40-50% (vs. 25-35% for onshore)
• Cost has dropped 70% since 2009

Environmental Benefits:
• Zero emissions during operation
• Minimal water use
• Small land footprint (farming can continue around turbines)
• Supports rural economies through lease payments

Environmental Considerations:
• Bird and bat mortality (mitigated by radar systems and blade painting)
• Visual impact on landscapes
• Noise (modern turbines are much quieter)
• Offshore construction can disturb marine habitats

Case Study - Denmark:
Denmark generates over 50% of its electricity from wind power. The country has installed 6,000+ turbines and is a global leader in offshore wind technology. Danish wind cooperative model allows citizens to own shares in local wind farms, generating community wealth.''',
      ),
      const Lesson(
        title: 'Hydroelectric and Geothermal Energy',
        content: '''Hydroelectric and geothermal energy are reliable renewable sources that complement intermittent solar and wind.

Hydroelectric Power:
• Generates 15% of global electricity (largest renewable source)
• Uses flowing water to spin turbines
• Types: dam reservoir, run-of-river, pumped storage
• Global capacity: 1,392 GW
• Provides baseload power and grid flexibility
• Pumped storage acts as giant batteries (95% of global energy storage)

Hydroelectric Advantages:
• Reliable and predictable output
• Long lifespan (50-100+ years)
• Low operating costs after construction
• Multiple benefits: flood control, irrigation, water supply
• Quick startup for demand response

Hydroelectric Challenges:
• Large dams can flood vast areas and displace communities
• Alters river ecosystems and fish migration
• Reservoirs in tropical regions produce methane
• Dependent on water availability (affected by drought)
• High upfront construction costs

Geothermal Energy:
• Uses heat from Earth's interior
• Available 24/7 regardless of weather
• Global capacity: 16 GW (Iceland, Indonesia, Philippines, USA lead)
• Types: dry steam, flash steam, binary cycle, enhanced geothermal

Geothermal Applications:
• Electricity generation: converts heat to power
• Direct heating: warming buildings, greenhouses, industrial processes
• Heat pumps: use shallow ground temperature for heating/cooling
• District heating: heating entire neighborhoods

Geothermal Advantages:
• Capacity factors of 90%+ (vs. 25-50% for solar/wind)
• Small land footprint
• Minimal emissions (closed-loop systems)
• Extremely long plant lifetime (30-50 years)

Case Study - Iceland:
Iceland generates 25% of its electricity from geothermal and heats 90% of homes with geothermal water. The Hellisheiði Power Station is one of the world's largest geothermal plants (303 MW electricity, 133 MW thermal). Iceland demonstrates how geothermal can provide both electricity and heating.''',
      ),
      const Lesson(
        title: 'Energy Storage and Grid Integration',
        content: '''The biggest challenge for renewable energy is intermittency - the sun doesn't always shine and the wind doesn't always blow. Energy storage and smart grid technology solve this problem.

The Storage Challenge:
• Solar produces most energy at midday; peak demand is evening
• Wind is strongest at night; peak demand is daytime
• Without storage, excess renewable energy is wasted
• Grid stability requires supply to match demand in real-time

Types of Energy Storage:

1. Battery Storage
   • Lithium-ion: most common, 85%+ of new storage
   • Flow batteries: longer duration, lower cost per kWh
   • Solid-state: next generation, higher energy density
   • Cost dropped 97% since 1991, 80% since 2013

2. Pumped Hydro Storage
   • Pumps water uphill when excess energy available
   • Releases water through turbines when needed
   • 95% of global energy storage capacity
   • Can store large amounts for long durations

3. Thermal Storage
   • Molten salt stores heat from concentrated solar
   • Can generate electricity for hours after sunset
   • Ice storage: freeze water at night, use for cooling during day

4. Hydrogen Storage
   • Electrolysis splits water into hydrogen and oxygen
   • Hydrogen can be stored and later converted back to electricity
   • Suitable for long-duration and seasonal storage
   • Also useful for transport and industry

Smart Grid Technology:
• Real-time supply and demand management
• Demand response: shifting consumption to match renewable generation
• Vehicle-to-grid: EVs act as distributed batteries
• AI-powered forecasting of renewable output
• Microgrids for local energy resilience

Grid-Scale Solutions:
• Interconnectors: linking grids across regions
• Virtual power plants: aggregating distributed resources
• Frequency regulation: maintaining grid stability
• Capacity markets: ensuring adequate backup

Key Insight: The cost of battery storage is falling so fast that by 2030, solar + storage will be cheaper than operating existing coal plants in most countries.''',
      ),
      const Lesson(
        title: 'Future of Energy',
        content: '''The energy landscape is evolving rapidly. Several emerging technologies and trends will shape the future of clean energy.

Emerging Technologies:

1. Green Hydrogen
   • Produced using renewable electricity to split water
   • Zero-carbon fuel for heavy industry, shipping, aviation
   • Could replace natural gas for heating
   • Cost expected to drop 50% by 2030

2. Advanced Nuclear
   • Small Modular Reactors (SMRs): factory-built, lower cost
   • Fusion energy: replicating the sun's process (still in development)
   • Provides reliable baseload power without carbon emissions

3. Floating Offshore Wind
   • Enables wind farms in deep water
   • Access to stronger, more consistent winds
   • Could unlock 3x more wind energy potential

4. Perovskite Solar Cells
   • Next-generation solar technology
   • Can be printed like newspaper
   • Flexible, transparent, and ultra-cheap
   • Efficiency exceeding 25% in lab conditions

5. Vehicle-to-Grid (V2G)
   • EVs as mobile energy storage
   • Millions of EVs could stabilize the grid
   • Car owners earn money by providing grid services

Energy System Trends:
• Electrification of everything (transport, heating, industry)
• Decentralization (home solar, community energy)
• Digitalization (AI, IoT, smart meters)
• Sector coupling (linking electricity, transport, heat)
• Prosumer model (producing and consuming energy)

Economic Outlook:
• Clean energy investment will reach `5 trillion/year by 2030
• 42 million clean energy jobs by 2030 (vs. 8 million lost in fossil fuels)
• Energy independence for countries that import fossil fuels
• Lower and more stable energy costs for consumers

The Transition is Inevitable:
• 90% of new electricity generation is renewable
• Fossil fuel demand will peak before 2030
• Battery and solar costs continue to fall exponentially
• Public support for clean energy exceeds 80% globally''',
      ),
      const Lesson(
        title: 'How You Can Support Clean Energy',
        content: '''You don't have to be an engineer or policymaker to support the clean energy transition. There are meaningful actions at every level.

Personal Energy Choices:
• Switch to a green energy provider or community solar program
• Install rooftop solar panels (many areas offer financing)
• Improve home insulation to reduce energy demand
• Use energy-efficient appliances (look for Energy Star ratings)
• Switch to LED lighting (uses 75% less energy than incandescent)
• Install a smart thermostat to optimize heating/cooling

Transportation:
• Choose an electric or hybrid vehicle for your next car
• Use public transit, bike, or walk when possible
• Combine errands to reduce driving
• Support EV charging infrastructure development
• Carpool or use ride-sharing services

Financial Actions:
• Divest from fossil fuel companies
• Invest in clean energy funds or community solar
• Support companies with strong clean energy commitments
• Bank with institutions that don't finance fossil fuels

Advocacy and Community:
• Support local renewable energy projects
• Advocate for clean energy policies at local and national levels
• Attend public hearings on energy infrastructure
• Support organizations working on clean energy access
• Educate others about energy transition benefits

Workplace:
• Push for your company to switch to renewable energy
• Advocate for EV charging at your workplace
• Suggest energy efficiency improvements
• Support sustainable business practices

Key Actions by Impact:
1. Switch to renewable electricity (saves 1.5 tonnes CO₂/year)
2. Switch to an EV (saves 2.4 tonnes CO₂/year)
3. Improve home insulation (saves 0.9 tonnes CO₂/year)
4. Fly less (saves 2.5 tonnes CO₂ per avoided transatlantic flight)
5. Eat less meat (saves 0.8 tonnes CO₂/year)

Reflection Questions:
1. What percentage of your electricity comes from renewable sources?
2. How could your workplace or school transition to 100% renewable energy?
3. What local clean energy projects could you support or start?
4. How does energy access relate to social equity?
5. What would your ideal energy future look like in 2050?''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 're_easy_1',
        question: 'Which renewable energy source has seen the biggest cost reduction since 2010?',
        options: ['Wind energy', 'Hydroelectric power', 'Solar energy', 'Geothermal energy'],
        correctIndex: 2,
        explanation: 'Solar energy costs have dropped 89% since 2010, making it the cheapest source of new electricity in most of the world. Wind costs have also fallen significantly (70%), but solar has seen the most dramatic decline.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 're_easy_2',
        question: 'What is the main challenge with solar and wind energy?',
        options: ['They are too expensive', 'They are intermittent (not available 24/7)', 'They produce too much electricity', 'They require too much land'],
        correctIndex: 1,
        explanation: 'Solar and wind are intermittent - the sun doesn\'t always shine and the wind doesn\'t always blow. This is why energy storage (batteries, pumped hydro) and smart grid technology are essential for a renewable energy system.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 're_medium_1',
        question: 'A household wants to maximize their energy independence. Which combination would be MOST effective?',
        options: [
          'Install a diesel generator and solar panels',
          'Install rooftop solar with battery storage, improve home insulation, and switch to heat pumps',
          'Only buy energy-efficient light bulbs',
          'Move to a location with more sunlight',
        ],
        correctIndex: 1,
        explanation: 'This combination addresses generation (solar), storage (batteries), and demand reduction (insulation, heat pumps). The diesel generator contradicts energy independence goals by requiring fuel imports. Efficiency improvements are important but insufficient alone.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 're_medium_2',
        question: 'Why is pumped hydro storage important for renewable energy?',
        options: [
          'It generates electricity from ocean waves',
          'It stores excess energy by pumping water uphill and releases it through turbines when needed',
          'It cools down solar panels to improve efficiency',
          'It replaces the need for battery storage',
        ],
        correctIndex: 1,
        explanation: 'Pumped hydro stores energy by pumping water from a lower reservoir to an upper one when electricity is abundant and cheap. When demand is high, water flows back down through turbines to generate electricity. It accounts for 95% of global energy storage capacity.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 're_hard_1',
        question: 'Scenario: A country rich in fossil fuels wants to transition to 100% renewable energy while maintaining economic stability. What is the MOST strategic approach?',
        options: [
          'Immediately shut down all fossil fuel plants',
          'Phase out fossil fuels gradually while investing in renewable manufacturing, retraining workers, developing green hydrogen, and using fossil fuel revenues to fund the transition',
          'Continue fossil fuel exports and only use renewables domestically',
          'Wait until other countries prove the transition works',
        ],
        correctIndex: 1,
        explanation: 'A just transition requires gradual phasing to avoid economic shock, investment in new industries for job creation, worker retraining programs, developing alternative revenue sources (green hydrogen), and using current fossil fuel revenues strategically. Immediate shutdown causes economic collapse; waiting loses competitive advantage.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 're_hard_2',
        question: 'Scenario: An island nation wants to achieve 100% renewable energy but has limited land area and high energy demand from tourism. What is the BEST energy strategy?',
        options: [
          'Build only wind farms around the coastline',
          'Combine offshore wind, rooftop solar on all buildings, ocean thermal energy conversion (OTEC), and implement aggressive energy efficiency standards for hotels',
          'Import fossil fuels because renewables cannot meet demand',
          'Build a large nuclear power plant',
        ],
        correctIndex: 1,
        explanation: 'Island nations have unique advantages: strong offshore winds, abundant sunshine, and ocean thermal gradients. A diversified approach using multiple renewable sources, maximizing built surfaces for solar, and reducing tourism energy demand through efficiency creates resilience and energy independence.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _biodiversityModule = EcoModule(
    id: 'biodiversity',
    title: 'Biodiversity Conservation',
    description: 'Discover the richness of life on Earth, why biodiversity matters, and how we can protect the web of life that sustains us all.',
    icon: 'eco',
    order: 4,
    lessons: [
      const Lesson(
        title: 'What is Biodiversity?',
        content: '''Biodiversity is the variety of life on Earth at all levels - from genes to ecosystems. It encompasses the millions of species, their genetic differences, and the complex ecosystems they form.

Levels of Biodiversity:
1. Genetic Diversity: variation within species (e.g., different breeds of dogs)
2. Species Diversity: variety of different species in an area
3. Ecosystem Diversity: variety of habitats, biological communities, and ecological processes

The Numbers:
• 8.7 million estimated species on Earth (only 1.5 million described)
• 1 trillion微生物 species (mostly unknown)
• 400,000+ plant species
• 80,000+ edible plant species (we use only 150-200)
• 1 million+ insect species
• 70,000+ fungal species

Why Biodiversity Matters:

Ecosystem Services (free services nature provides):
• Pollination: 75% of crops depend on animal pollination
• Water purification: wetlands filter pollutants naturally
• Carbon sequestration: forests store 2.6 billion tonnes of CO₂ annually
• Soil formation: microorganisms create fertile soil
• Pest control: natural predators reduce crop damage
• Nutrient cycling: decomposition recycles nutrients

Economic Value:
• Global ecosystem services worth `125-145 trillion per year
• 55% of global GDP depends on nature
• 1.2 billion livelihoods depend on agriculture
• Fisheries support 600 million jobs
• Tourism: `1.3 trillion annually, much nature-based

Cultural and Aesthetic Value:
• Spiritual and religious significance
• Inspiration for art, music, and literature
• Recreational value (hiking, birdwatching, diving)
• Educational and scientific value

The Sixth Mass Extinction:
• Current extinction rate is 1,000x the natural background rate
• 1 million species face extinction within decades
• Vertebrate populations have declined 69% since 1970
• Insect populations declining 1-2% per year
• We are losing species faster than we can discover them''',
      ),
      const Lesson(
        title: 'Threats to Biodiversity',
        content: '''Biodiversity is under unprecedented threat from human activities. The main drivers of biodiversity loss are often interconnected and reinforce each other.

1. Habitat Destruction (the #1 threat)
• 75% of Earth's land surface has been significantly altered
• 85% of wetlands have been lost
• Deforestation: 10 million hectares lost annually
• Urbanization: cities cover 3% of land but use 75% of resources
• Agriculture: occupies 50% of habitable land
• Fragmentation: remaining habitats are broken into small patches

2. Overexploitation
• Overfishing: 34% of fish stocks are overfished
• Overhunting: bushmeat trade threatens wildlife in tropical forests
• Poaching: `23 billion illegal wildlife trade annually
• Overharvesting: medicinal plants collected faster than they regrow

3. Pollution
• Plastic pollution: affects 800+ marine species
• Pesticides: kill non-target insects including pollinators
• Nutrient pollution: creates dead zones in oceans (400+ worldwide)
• Light pollution: disrupts nocturnal animals and migration
• Noise pollution: affects marine mammals and birds

4. Climate Change
• Shifting habitats faster than species can adapt
• Coral bleaching: 50% of Great Barrier Reef lost
• Ocean acidification: threatens shell-forming organisms
• Arctic ice loss: threatens polar species
• Extreme weather: increases mortality events

5. Invasive Species
• Invasive species are the leading cause of island extinctions
• 10,000+ invasive species worldwide
• Cost: `423 billion per year in damages
• Examples: rats on islands, zebra mussels, kudzu vine

6. Disease
• Chytrid fungus: has killed 90 species of frogs
• White-nose syndrome: killed millions of bats
• Climate change increases disease spread
• Habitat stress makes species more vulnerable

Case Study - Madagascar:
Madagascar has lost 90% of its original forest. 90% of its wildlife is found nowhere else on Earth. Lemurs, chameleons, and thousands of other species face extinction. Only 2% of the original forest remains in protected areas.''',
      ),
      const Lesson(
        title: 'Ecosystem Conservation',
        content: '''Protecting ecosystems is the most effective way to conserve biodiversity. Healthy ecosystems support millions of species while providing essential services to humans.

Types of Ecosystems and Their Importance:

1. Tropical Rainforests
• Cover 6% of Earth's surface but contain 50% of all species
• Produce 28% of the world's oxygen
• Store 250 billion tonnes of carbon
• Generate rainfall patterns across continents
• Home to 50% of the world's undiscovered species

2. Coral Reefs
• "Rainforests of the sea" - 25% of all marine species
• Protect coastlines from storms and erosion
• Support fisheries that feed 500 million people
• Generate `36 billion in tourism annually
• Only 0.1% of the ocean but 25% of marine life

3. Wetlands
• Water purifiers: filter pollutants naturally
• Flood control: absorb and slowly release water
• Carbon sinks: store twice as much carbon as forests
• Nurseries: breeding grounds for fish and birds
• 85% of wetlands lost since 1700

4. Grasslands and Savannas
• Support large herbivore populations
• Important carbon storage in root systems
• Prevent soil erosion
• Home to 35% of endangered species

5. Oceans
• Cover 71% of Earth's surface
• Produce 50% of the world's oxygen (phytoplankton)
• Absorb 30% of CO₂ emissions
• Regulate global climate
• Source of food and medicine

Conservation Strategies:

Protected Areas:
• 17% of land and 8% of ocean currently protected
• Target: 30% by 2030 (30x30 initiative)
• Well-managed protected areas reduce deforestation by 50%
• National parks, wildlife refuges, marine reserves

Restoration:
• Ecosystem restoration at scale (UN Decade on Restoration)
• Reforestation: planting trees on degraded land
• Coral restoration: transplanting coral fragments
• Wetland reconstruction: rebuilding drained wetlands

Community Conservation:
• Indigenous peoples manage 25% of the world's land
• Indigenous-managed lands have lower deforestation rates
• Community-based natural resource management
• Locally Managed Marine Areas (LMMAs)

Case Study - Costa Rica:
Costa Rica reversed deforestation, going from 21% forest cover in 1987 to 52% today. The country pays landowners for ecosystem services (carbon storage, water protection, biodiversity). It now generates 98% of its electricity from renewable sources and earns more from eco-tourism than from agriculture.''',
      ),
      const Lesson(
        title: 'Species Conservation',
        content: '''Species conservation focuses on protecting individual species from extinction while maintaining their role in ecosystems.

Why Save Individual Species?
• Each species plays a unique role in its ecosystem
• Losing keystone species can cause ecosystem collapse
• Genetic resources have untapped potential for medicine and agriculture
• Ethical responsibility as the cause of the extinction crisis
• Future generations deserve to experience Earth's biodiversity

Conservation Approaches:

1. In-Situ Conservation (protecting species in their natural habitat)
• Protected areas and national parks
• Wildlife corridors connecting habitat patches
• Anti-poaching patrols and law enforcement
• Habitat restoration projects
• Community-based conservation programs

2. Ex-Situ Conservation (protecting species outside their habitat)
• Zoos and aquariums (breeding programs)
• Botanical gardens (seed banks, plant propagation)
• Seed vaults (Svalbard Global Seed Vault)
• Genetic repositories (frozen cell banks)
• Insurance populations for critically endangered species

3. Species Recovery Programs
• Captive breeding and reintroduction
• Habitat restoration for target species
• Genetic rescue (introducing genetic diversity)
• Disease management
• Monitoring and research

Success Stories:
• Giant Panda: removed from endangered to vulnerable (1,800 in wild)
• Humpback whale: populations recovered from near-extinction
• California Condor: from 27 birds in 1987 to 500+ today
• Arabian Oryx: from extinct in wild to 1,000+ in protected areas
• Bald Eagle: recovered from DDT poisoning to stable populations

Challenges:
• Limited funding for conservation
• Climate change creating new threats
• Illegal wildlife trade (`23 billion/year)
• Human-wildlife conflict
• Disease and invasive species
• Small population vulnerabilities

Keystone Species Examples:
• Wolves in Yellowstone: their reintroduction transformed the entire ecosystem
• Sea otters: keep kelp forests healthy by eating sea urchins
• Bees: pollinate 75% of flowering plants
• Elephants: create habitats by knocking down trees
• Coral: build reef ecosystems supporting 25% of marine life

Key Insight: Saving one species often requires saving its entire ecosystem. Conservation works best when it protects whole landscapes and seascapes, not just individual species.''',
      ),
      const Lesson(
        title: 'Biodiversity and Human Health',
        content: '''Biodiversity is not just about wildlife - it directly impacts human health in ways most people don't realize.

Medicine from Nature:
• 50% of modern medicines derived from natural compounds
• Aspirin: from willow bark
• Penicillin: from mold
• Cancer treatments: from Pacific yew tree and sea sponges
• Malaria drugs: from cinchona tree bark
• 70% of cancer drugs: from natural sources

Genetic Resources:
• Crop wild relatives: provide disease resistance for food crops
• Microbiome: trillions of bacteria in our gut influence health
• Genetic diversity in crops: protects against famine
• Unique compounds in undiscovered species: potential cures

Ecosystem Services and Health:
• Clean air: forests filter pollutants and produce oxygen
• Clean water: wetlands and forests purify water naturally
• Food security: pollination, soil fertility, pest control
• Disease regulation: intact ecosystems reduce disease emergence
• Mental health: nature exposure reduces stress and anxiety

The Biodiversity-Health Connection:
• Deforestation increases malaria risk by 300%
• 60% of emerging infectious diseases are zoonotic
• Habitat destruction brings wildlife and humans into closer contact
• Climate change alters disease patterns
• Microbiome diversity reduces allergies and autoimmune diseases

Nature and Mental Health:
• 20 minutes in nature reduces cortisol (stress hormone) by 20%
• Forest bathing (shinrin-yoku) lowers blood pressure
• Nature exposure reduces depression and anxiety
• Children with ADHD improve symptoms after outdoor activities
• Hospital patients recover faster with nature views

Food and Nutrition:
• Diverse diets require diverse crops
• Pollination: 75% of food crops depend on animal pollinators
• Soil biodiversity: healthy soils produce more nutritious food
• Traditional crops: indigenous varieties adapted to local conditions
• Wild foods: important nutrition source for 1 billion people

Conservation as Public Health:
• Protecting forests prevents disease emergence
• Maintaining biodiversity supports food security
• Preserving water sources ensures clean drinking water
• Reducing pollution protects respiratory health
• Green spaces improve urban health outcomes''',
      ),
      const Lesson(
        title: 'Climate Change and Biodiversity',
        content: '''Climate change and biodiversity loss are deeply interconnected crises that amplify each other.

How Climate Change Threatens Biodiversity:

1. Habitat Shifts
• Species moving poleward at 17km per decade
• Mountain species moving upward at 11m per decade
• Mismatched timing: flowers bloom before pollinators emerge
• Some species cannot move fast enough

2. Ocean Changes
• Warming: marine species shifting distribution
• Acidification: threatens shell-forming organisms
• Deoxygenation: expanding dead zones
• Coral bleaching: 50% of Great Barrier Reef lost

3. Extreme Events
• More frequent and intense heatwaves
• Droughts and floods destroying habitats
• Wildfires increasing in frequency and severity
• Hurricanes damaging coastal ecosystems

How Biodiversity Loss Worsens Climate Change:

1. Carbon Release
• Deforestation releases stored carbon
• Peatland destruction releases massive CO₂ stores
• Soil degradation reduces carbon storage
• Permafrost thaw releases methane

2. Reduced Carbon Sequestration
• Fewer trees absorb less CO₂
• Degraded oceans absorb less carbon
• Damaged ecosystems lose carbon storage capacity
• Loss of marine organisms that pump carbon to deep ocean

3. Positive Feedback Loops
• Forest fires → release carbon → more warming → more fires
• Permafrost thaw → methane release → more warming → more thaw
• Ocean warming → less CO₂ absorption → more warming → more warming

Solutions That Address Both Crises:

Nature-Based Solutions:
• Forest protection and restoration: stores carbon and protects biodiversity
• Mangrove restoration: protects coastlines and sequesters carbon
• Regenerative agriculture: builds soil carbon and biodiversity
• Blue carbon ecosystems: mangroves, seagrass, salt marshes

Integrated Approaches:
• 30x30: protecting 30% of land and ocean by 2030
• Indigenous land management: traditional practices protect both
• Sustainable agriculture: reduces emissions and supports biodiversity
• Urban green infrastructure: reduces heat and supports urban wildlife

Key Insight: You cannot solve climate change without biodiversity, and you cannot protect biodiversity without addressing climate change. Solutions must tackle both simultaneously.''',
      ),
      const Lesson(
        title: 'Taking Action for Biodiversity',
        content: '''Everyone can contribute to biodiversity conservation through personal choices, community action, and advocacy.

Personal Actions:

1. Transform Your Yard
• Plant native species (support local pollinators)
• Create a pollinator garden with flowers blooming in all seasons
• Leave leaf litter and dead wood for insects and small animals
• Avoid pesticides - use natural pest control
• Install bird feeders, bat houses, and bee hotels

2. Make Consumer Choices
• Choose sustainably sourced seafood (look for MSC certification)
• Buy organic when possible (reduces pesticide use)
• Avoid products linked to deforestation (palm oil, soy, beef)
• Support companies with biodiversity commitments
• Reduce meat consumption (livestock is a leading cause of habitat loss)

3. Reduce Your Footprint
• Conserve water (protects aquatic ecosystems)
• Reduce energy use (less habitat destruction for energy)
• Minimize waste (reduces pollution and landfills)
• Use public transit or EVs (reduces air and noise pollution)
• Support sustainable forestry (FSC certified wood)

4. Get Involved Locally
• Volunteer for habitat restoration projects
• Join bird counts and biodiversity surveys
• Participate in community science (iNaturalist, eBird)
• Support local land trusts and conservation groups
• Attend public meetings on land use and development

5. Advocate for Change
• Push for protected areas in your region
• Support policies that protect habitats
• Demand corporate accountability for biodiversity impacts
• Advocate for environmental education in schools
• Support indigenous land rights (indigenous lands have higher biodiversity)

6. Spread Awareness
• Share biodiversity knowledge with others
• Support nature documentaries and media
• Take children to experience nature
• Write about biodiversity issues
• Use social media to raise awareness

Community Action:
• Create wildlife corridors connecting green spaces
• Establish community gardens with native plants
• Organize invasive species removal events
• Support local farms using sustainable practices
• Push for green infrastructure in urban planning

Reflection Questions:
1. What native plants and animals live in your area?
2. How could your neighborhood support more biodiversity?
3. What products in your daily life might be linked to habitat destruction?
4. How does biodiversity loss affect your community's well-being?
5. What would it take for your city to become a biodiversity-friendly community?''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'bd_easy_1',
        question: 'What percentage of Earth\'s land surface has been significantly altered by humans?',
        options: ['25%', '50%', '75%', '95%'],
        correctIndex: 2,
        explanation: 'Approximately 75% of Earth\'s land surface has been significantly altered by human activities including agriculture, urbanization, and deforestation. This massive habitat alteration is the primary driver of biodiversity loss.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'bd_easy_2',
        question: 'Why are coral reefs called the "rainforests of the sea"?',
        options: [
          'They are very colorful',
          'They support 25% of all marine species despite covering only 0.1% of the ocean',
          'They are very hot',
          'They produce most of the world\'s oxygen',
        ],
        correctIndex: 1,
        explanation: 'Coral reefs are called the "rainforests of the sea" because they support approximately 25% of all marine species despite covering only 0.1% of the ocean floor. This extraordinary biodiversity makes them one of the most valuable ecosystems on Earth.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'bd_medium_1',
        question: 'A city wants to increase urban biodiversity. Which combination of actions would be MOST effective?',
        options: [
          'Plant only ornamental flowers in parks',
          'Create native plant gardens, install wildlife corridors, reduce pesticide use, and build green roofs and walls',
          'Build more concrete structures',
          'Introduce exotic species for aesthetic appeal',
        ],
        correctIndex: 1,
        explanation: 'Native plant gardens support local pollinators, wildlife corridors connect habitat patches, reduced pesticide use protects insects, and green infrastructure provides habitat in urban areas. Ornamental non-native plants and exotic species introductions can harm local ecosystems.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'bd_medium_2',
        question: 'How does deforestation affect local rainfall patterns?',
        options: [
          'It increases rainfall',
          'It reduces rainfall because trees release moisture through transpiration that forms clouds',
          'It has no effect on rainfall',
          'It only affects temperature, not precipitation',
        ],
        correctIndex: 1,
        explanation: 'Trees release moisture through transpiration, which forms clouds and generates rainfall. Deforestation reduces this moisture recycling, leading to decreased local rainfall. The Amazon rainforest generates 50% of its own rainfall through this process.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'bd_hard_1',
        question: 'Scenario: A government wants to protect biodiversity while allowing economic development. Which approach best balances these goals?',
        options: [
          'Ban all development in natural areas',
          'Implement biodiversity offsets, require environmental impact assessments, create mixed-use protected areas, and invest in sustainable livelihoods for local communities',
          'Allow unrestricted development everywhere',
          'Protect only charismatic species like pandas and tigers',
        ],
        correctIndex: 1,
        explanation: 'This integrated approach allows development while ensuring no net loss of biodiversity. Offsets compensate for unavoidable impacts, assessments prevent unnecessary damage, mixed-use areas support both conservation and livelihoods, and community engagement ensures long-term success.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'bd_hard_2',
        question: 'Scenario: An invasive species is threatening a native ecosystem. What is the MOST ecologically responsible management approach?',
        options: [
          'Use broad-spectrum pesticides to kill all non-native organisms',
          'Implement integrated pest management: biological control, targeted removal, monitoring, and preventing further introductions while protecting native species',
          'Do nothing and let nature take its course',
          'Introduce another exotic species to compete with the invasive one',
        ],
        correctIndex: 1,
        explanation: 'Integrated pest management combines multiple targeted approaches to minimize collateral damage. Biological control uses natural enemies, targeted removal focuses on the invasive species, monitoring tracks effectiveness, and prevention stops new introductions. Broad pesticides and new introductions often cause more harm.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _sustainableLivingModule = EcoModule(
    id: 'sustainable_living',
    title: 'Sustainable Living',
    description: 'Practical strategies for reducing your environmental footprint while living a fulfilling life.',
    icon: 'spa',
    order: 5,
    lessons: [
      const Lesson(
        title: 'What is Sustainable Living?',
        content: '''Sustainable living means meeting your needs without compromising the ability of future generations to meet theirs. It's about making choices that reduce your environmental impact while maintaining quality of life.

The Three Pillars of Sustainability:
1. Environmental: protecting natural resources and ecosystems
2. Social: ensuring fairness, equity, and community well-being
3. Economic: maintaining prosperity without depleting resources

Why It Matters:
• The average American has a carbon footprint of 16 tonnes CO₂ per year
• To meet Paris Agreement goals, we need to reach 2 tonnes per person by 2050
• If everyone consumed like Americans, we would need 5 Earths
• We currently use 1.7 Earths worth of resources annually (Earth Overshoot Day: August 1)

Sustainable Living is Not About:
• Perfection: small changes matter
• Sacrifice: many sustainable choices improve quality of life
• Going back to the past: modern technology enables sustainability
• Individual guilt: systemic change is essential, but personal action matters

The Good News:
• Many sustainable choices save money
• Sustainable products are increasingly available and affordable
• Community support makes it easier
• Health benefits often accompany sustainable choices
• It creates a sense of purpose and connection

Key Principles:
1. Conscious consumption: think before you buy
2. Quality over quantity: buy less, buy better
3. Share and borrow: access over ownership
4. Support local: reduce transport impacts
5. Close the loop: recycle, compost, reuse

Getting Started:
• Start with one area (food, transport, or home)
• Make it a habit before adding another change
• Find community support and accountability
• Celebrate progress, not perfection
• Focus on high-impact actions first''',
      ),
      const Lesson(
        title: 'Sustainable Food Choices',
        content: '''Food systems account for 26% of global greenhouse gas emissions. What you eat and how you source it makes a significant difference.

The Carbon Footprint of Food:
• Beef: 27 kg CO₂ per kg of food
• Lamb: 39 kg CO₂ per kg
• Cheese: 13.5 kg CO₂ per kg
• Pork: 12 kg CO₂ per kg
• Poultry: 6.9 kg CO₂ per kg
• Eggs: 4.8 kg CO₂ per kg
• Rice: 2.7 kg CO₂ per kg
• Beans: 0.9 kg CO₂ per kg
• Vegetables: 0.5 kg CO₂ per kg
• Fruit: 0.4 kg CO₂ per kg

High-Impact Food Changes:

1. Reduce Meat Consumption
• Beef and lamb have the highest emissions
• Replacing beef with beans reduces emissions by 97%
• You don't have to be vegetarian - even "Meatless Mondays" help
• Plant-based milks: oat milk produces 70% less emissions than dairy

2. Reduce Food Waste
• Plan meals and buy only what you need
• Store food properly to extend shelf life
• Use leftovers creatively
• Compost unavoidable food waste
• 30% of food produced is wasted globally

3. Eat Local and Seasonal
• Reduces transport emissions (food miles)
• Supports local farmers and economy
• Fresher and often more nutritious
• Visit farmers markets or join a CSA (Community Supported Agriculture)

4. Choose Sustainable Seafood
• Look for MSC (Marine Stewardship Council) certification
• Avoid overfished species (bluefin tuna, certain shrimp)
• Choose line-caught or pole-caught over trawled
• Eat lower on the food chain (sardines, mackerel)

5. Grow Your Own Food
• Start a garden, even in containers
• Join a community garden
• Grow herbs on your windowsill
• Preserve food through canning, freezing, or drying

Cooking Tips:
• Cook in bulk and freeze portions
• Use energy-efficient appliances (pressure cookers, microwaves)
• Match pot size to burner size
• Keep lids on pots while cooking
• Use leftover vegetable scraps for stock''',
      ),
      const Lesson(
        title: 'Sustainable Transportation',
        content: '''Transportation accounts for 16% of global greenhouse gas emissions and is the fastest-growing emissions sector. How you get around matters.

Transportation Emissions by Mode:
• Air travel: 255 g CO₂ per passenger-km
• Car (single occupant): 171 g CO₂ per passenger-km
• Bus: 89 g CO₂ per passenger-km
• Motorcycle: 103 g CO₂ per passenger-km
• Train: 41 g CO₂ per passenger-km
• Cycling/walking: 0 g CO₂ per passenger-km
• Electric car (grid average): 50-70 g CO₂ per passenger-km

High-Impact Transportation Changes:

1. Drive Less
• Walk, bike, or use public transit when possible
• Combine errands to reduce trips
• Work from home when you can
• Carpool to work or school
• Use car-sharing services instead of owning

2. Switch to Electric
• EVs produce 50-70% fewer emissions than gas cars
• Costs are decreasing (many under `30,000)
• Charging infrastructure is expanding rapidly
• Home solar + EV = zero-emission transportation
• Lower maintenance costs (fewer moving parts)

3. Fly Smarter
• One round-trip transatlantic flight = 2.5 tonnes CO₂
• Choose direct flights (takeoff uses most fuel)
• Fly economy (smaller seat = lower per-person emissions)
• Consider trains for shorter distances (under 500km)
• Buy carbon offsets for unavoidable flights

4. Maintain Your Vehicle
• Keep tires properly inflated (saves 3% fuel)
• Get regular tune-ups
• Remove unnecessary weight from trunk
• Use cruise control on highways
• Avoid aggressive driving

5. Urban Design Solutions
• Support walkable neighborhoods
• Advocate for bike lanes and public transit
• Push for EV charging infrastructure
• Support mixed-use development (live near shops/work)
• Participate in Complete Streets initiatives

Key Insight: The most sustainable trip is the one you don't take. Before traveling, ask: Can I do this remotely? Can I combine it with another trip? Is there a lower-carbon alternative?''',
      ),
      const Lesson(
        title: 'Sustainable Home and Energy',
        content: '''Your home is a major source of environmental impact. Simple changes can dramatically reduce energy use, water consumption, and waste.

Energy Efficiency at Home:

1. Heating and Cooling (40-50% of home energy)
• Install a smart thermostat (saves 10-15% on heating/cooling)
• Improve insulation (walls, attic, windows)
• Seal air leaks around doors and windows
• Use ceiling fans instead of air conditioning
• Maintain your HVAC system regularly

2. Appliances and Electronics (20-30% of home energy)
• Choose Energy Star certified appliances
• Unplug electronics when not in use (phantom loads)
• Use power strips to easily turn off multiple devices
• Wash clothes in cold water (90% of washing machine energy heats water)
• Air dry clothes instead of using a dryer

3. Lighting (10% of home energy)
• Switch to LED bulbs (use 75% less energy)
• Use natural daylight when possible
• Install motion sensors for outdoor lighting
• Choose smart lighting systems

Water Conservation:
• Fix leaky faucets (saves 3,000 gallons per year)
• Install low-flow showerheads and faucets
• Take shorter showers (5 minutes saves 10 gallons)
• Water lawns early morning or late evening
• Collect rainwater for gardening
• Choose drought-resistant plants (xeriscaping)

Waste Reduction:
• Compost food scraps and yard waste
• Use reusable containers instead of plastic wrap
• Choose products with minimal packaging
• Buy in bulk to reduce packaging
• Repair items instead of replacing them
• Donate usable items

Sustainable Materials:
• Choose natural fibers (cotton, wool, linen) over synthetics
• Buy FSC-certified wood products
• Use low-VOC paints and finishes
• Choose recycled and recyclable materials
• Support companies with sustainable practices

Smart Home Technology:
• Smart thermostats learn your schedule
• Smart plugs track and control energy use
• Solar panels with battery storage
• Home energy monitors show real-time usage
• Automated blinds optimize natural light and temperature''',
      ),
      const Lesson(
        title: 'Conscious Consumption',
        content: '''The average American generates 4.4 pounds of trash per day. Much of this comes from unnecessary consumption. Conscious consumption means thinking before you buy.

The Problem with Overconsumption:
• Global material consumption has tripled since 1970
• Average American buys 65% more clothing than 15 years ago
• Average smartphone lifespan: 2.5 years
• 80% of products are used once and discarded
• Manufacturing accounts for 21% of global emissions

The Fashion Industry:
• Produces 10% of global carbon emissions
• Uses 93 billion cubic meters of water annually
• Generates 92 million tonnes of textile waste per year
• 85% of textiles end up in landfills
• Synthetic fabrics shed microplastics with every wash

How to Consume More Sustainably:

1. The Pause Test
• Before buying, wait 24-48 hours
• Ask: Do I really need this? Will I use it in a year?
• Consider: Can I borrow, rent, or buy secondhand?
• Check: Is there a more sustainable alternative?

2. Quality Over Quantity
• Buy fewer, better quality items
• Research brands for sustainability practices
• Choose durable materials (leather, solid wood, metal)
• Support companies with repair programs
• Learn basic repair skills

3. Secondhand and Sharing
• Thrift stores, consignment shops, online resale
• Tool libraries, toy libraries, community shares
• Clothing swaps with friends
• Buy used furniture and electronics
• Rent items you rarely use

4. Minimalism
• Own less, experience more
• Declutter regularly (donate, sell, recycle)
• Focus on experiences over things
• Quality relationships over material possessions
• Digital content over physical media

5. Support Sustainable Brands
• Look for certifications (B Corp, Fair Trade, GOTS)
• Research company practices and transparency
• Support local businesses and artisans
• Choose companies with circular economy models
• Avoid greenwashing - check claims carefully

The Circular Fashion Model:
• Buy less, choose well, make it last (Vivienne Westwood)
• Support brands that offer repair services
• Choose natural or recycled fibers
• Properly care for clothes to extend life
• Recycle or donate when done''',
      ),
      const Lesson(
        title: 'Sustainable Community',
        content: '''Individual action is important, but community-level change creates systemic impact. Building sustainable communities amplifies your efforts.

Community Initiatives:

1. Local Food Systems
• Community gardens and urban farms
• Farmers markets and CSAs (Community Supported Agriculture)
• Food co-ops and buying clubs
• Gleaning programs (harvesting surplus from farms)
• Food sharing networks

2. Energy Communities
• Community solar projects (shared solar panels)
• Cooperative wind farms
• Neighborhood energy audits
• Bulk purchasing of solar panels
• Community battery storage

3. Waste Reduction
• Repair cafes (fix broken items together)
• Tool libraries (share tools instead of everyone owning)
• Swap meets and free stores
• Community composting
• Zero-waste groups

4. Transportation
• Bike co-ops and cycling advocacy
• Car-sharing cooperatives
• Walking school buses for children
• Public transit advocacy
• Complete Streets campaigns

5. Housing
• Cohousing communities
• Tiny house villages
• Green building cooperatives
• Community land trusts
• Affordable sustainable housing

How to Start:

1. Assess Community Needs
• Survey neighbors about interests and skills
• Identify existing resources and gaps
• Look for quick wins to build momentum
• Connect with similar groups in your area

2. Build Community
• Start small with interested neighbors
• Host events and workshops
• Create online groups for coordination
• Partner with local organizations
• Celebrate successes together

3. Take Action
• Choose one project to focus on first
• Set clear goals and timelines
• Assign roles based on skills and interests
• Document and share your process
• Learn from failures and adapt

4. Scale Up
• Share your success with other neighborhoods
• Advocate for supportive policies
• Create replicable models
• Build networks with other communities
• Influence local government

Case Study - Transition Towns:
The Transition Network movement started in Totnes, UK in 2006. Communities worldwide are building resilience through local food, energy, and economy initiatives. Over 1,300 Transition initiatives exist in 48 countries, demonstrating that community-led sustainability works.''',
      ),
      const Lesson(
        title: 'Living Sustainably: Your Action Plan',
        content: '''This module has covered the principles and practices of sustainable living. Now it's time to create your personal action plan.

Step 1: Assess Your Current Impact
• Calculate your carbon footprint (online calculators)
• Track your waste for one week
• Review your energy and water bills
• Analyze your transportation habits
• Examine your consumption patterns

Step 2: Choose High-Impact Actions
Based on what you've learned, identify the 3-5 changes that would have the biggest impact for you:

Climate Actions (highest impact):
1. Switch to renewable electricity (1.5 tonnes CO₂/year)
2. Eat less meat (0.8 tonnes CO₂/year)
3. Fly less (2.5 tonnes per avoided transatlantic flight)
4. Switch to an EV (2.4 tonnes CO₂/year)
5. Improve home insulation (0.9 tonnes CO₂/year)

Waste Actions:
1. Start composting (diverts 30% of household waste)
2. Bring reusable bags, bottles, and containers
3. Buy in bulk with reusable containers
4. Repair instead of replace
5. Buy secondhand when possible

Water Actions:
1. Fix leaky faucets
2. Install low-flow fixtures
3. Water lawns efficiently
4. Collect rainwater
5. Choose drought-resistant landscaping

Step 3: Create Your Plan
• Set specific, measurable goals
• Choose a timeline (start with one change per month)
• Identify barriers and solutions
• Find accountability partners
• Track your progress

Step 4: Build Community
• Share your plan with friends and family
• Join or start a local sustainability group
• Advocate for systemic changes
• Support sustainable businesses
• Vote for climate-friendly policies

Step 5: Stay Motivated
• Celebrate small wins
• Connect with nature regularly
• Remember why you're doing this
• Focus on progress, not perfection
• Inspire others through your actions

Reflection Questions:
1. What are the three most impactful changes you can make this month?
2. How will you stay accountable and motivated?
3. How can you involve your family, friends, or community?
4. What systemic changes would make sustainable living easier for everyone?
5. What kind of sustainable future do you want to help create?

Remember: Sustainable living is not about being perfect. It's about making conscious choices and continuously improving. Every small action adds up to create meaningful change when millions of people participate.''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'sl_easy_1',
        question: 'Which food has the HIGHEST carbon footprint per kilogram?',
        options: ['Rice', 'Beef', 'Vegetables', 'Beans'],
        correctIndex: 1,
        explanation: 'Beef has the highest carbon footprint at approximately 27 kg CO₂ per kg of food, compared to rice (2.7 kg), beans (0.9 kg), and vegetables (0.5 kg). This is due to methane from cattle, feed production, and land use changes.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'sl_easy_2',
        question: 'What percentage of washing machine energy is used to heat water?',
        options: ['About 30%', 'About 50%', 'About 75%', 'About 90%'],
        correctIndex: 3,
        explanation: 'Approximately 90% of the energy used by a washing machine goes to heating water. Washing clothes in cold water can save significant energy and reduce your carbon footprint while still cleaning effectively.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'sl_medium_1',
        question: 'A family wants to reduce their home energy use by 40%. Which combination would be MOST effective?',
        options: [
          'Only switch to LED light bulbs',
          'Install a smart thermostat, improve insulation, upgrade to Energy Star appliances, and switch to a heat pump system',
          'Turn off all lights during the day',
          'Move to a smaller house',
        ],
        correctIndex: 1,
        explanation: 'Heating/cooling (40-50%) and appliances (20-30%) are the largest energy users. A smart thermostat optimizes heating/cooling, insulation reduces energy loss, efficient appliances cut electricity use, and heat pumps are 3-4x more efficient than traditional systems.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'sl_medium_2',
        question: 'Why is "fast fashion" environmentally problematic?',
        options: [
          'Clothes are too expensive',
          'It produces 10% of global carbon emissions, uses massive water resources, and generates enormous textile waste',
          'Clothes are made from natural materials',
          'It only affects developing countries',
        ],
        correctIndex: 1,
        explanation: 'Fast fashion produces 10% of global carbon emissions, uses 93 billion cubic meters of water annually, generates 92 million tonnes of textile waste per year, and 85% of textiles end up in landfills. The industry also contributes to microplastic pollution.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'sl_hard_1',
        question: 'Scenario: A city wants to become carbon-neutral by 2040. Which comprehensive strategy would be MOST effective?',
        options: [
          'Only focus on switching to renewable electricity',
          'Implement electrification of transport, retrofit all buildings for efficiency, develop local food systems, create circular economy programs, and invest in carbon sequestration through urban forestry',
          'Plant millions of trees and hope for the best',
          'Ban all cars and require everyone to cycle',
        ],
        correctIndex: 1,
        explanation: 'A comprehensive approach addresses multiple emission sources: transport (electrification), buildings (retrofitting), food systems (local sourcing), waste (circular economy), and carbon removal (urban forestry).单一措施无法实现碳中和目标。',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'sl_hard_2',
        question: 'Scenario: A community group wants to launch a sustainability initiative but has limited budget and volunteers. What approach would maximize their impact?',
        options: [
          'Start multiple projects simultaneously',
          'Focus on one high-impact, visible project (like a community garden or repair cafe), build partnerships, demonstrate success, then expand with lessons learned and community support',
          'Wait until they have more resources',
          'Only advocate for government action',
        ],
        correctIndex: 1,
        explanation: 'Focusing on one visible project builds momentum, demonstrates impact, and attracts more support. Starting too many projects with limited resources leads to burnout and failure. Success breeds success - a successful project attracts volunteers, funding, and partnerships for future initiatives.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _gutMicrobiomeModule = EcoModule(
    id: 'gut_microbiome',
    title: 'Gut Microbiome & Body Axes',
    description: 'Explore the trillions of bacteria in your gut and how they influence your brain, hormones, immunity, and overall health through interconnected body axes.',
    icon: 'biotech',
    order: 6,
    lessons: [
      const Lesson(
        title: 'Your Gut: The Second Brain',
        content: '''Your gut houses over 100 trillion microorganisms — bacteria, viruses, fungi, and archaea — collectively known as the gut microbiome. This ecosystem weighs about 2 kg and contains more genes than your entire human genome.

The Gut Microbiome at a Glance:
• Over 1,000 different species of bacteria
• Contains 150 times more genes than the human genome
• Produces 95% of the body's serotonin (the "happy hormone")
• Houses 70-80% of the body's immune cells
• Weighs approximately 1.5-2 kg (similar to the brain)

Key Bacterial Groups:
1. Lactobacillus — produces lactic acid, fights harmful bacteria, aids digestion
2. Bifidobacterium — strengthens gut barrier, produces vitamins, supports immunity
3. Akkermansia muciniphila — maintains mucus lining, linked to healthy weight
4. Faecalibacterium prausnitzii — anti-inflammatory, produces butyrate (fuel for colon cells)
5. Bacteroidetes — breaks down complex carbohydrates, helps maintain healthy weight

What Disrupts Your Microbiome:
• Antibiotics (kill both good and bad bacteria)
• Ultra-processed foods (feed harmful bacteria)
• Chronic stress (alters gut permeability)
• Artificial sweeteners (can reduce beneficial species)
• Lack of dietary fiber (starves good bacteria)
• Excessive alcohol consumption

What Supports Your Microbiome:
• Diverse plant foods (30+ different plants per week)
• Fermented foods (yogurt, kimchi, sauerkraut, fermented millets)
• Prebiotic fiber (garlic, onions, bananas, oats)
• Regular physical activity
• Adequate sleep (7-8 hours)
• Stress management

The Gut-Brain Connection:
Your gut and brain communicate through the vagus nerve — the longest cranial nerve running from brain to abdomen. This bidirectional highway means your gut health directly affects your mood, cognition, and mental health, and vice versa.

Fun Fact: Germ-free mice (raised without any gut bacteria) show abnormal brain development and increased anxiety. When given beneficial bacteria, their behavior normalizes!''',
      ),
      const Lesson(
        title: 'The Gut-Brain Axis',
        content: '''The gut-brain axis is the two-way communication network between your gastrointestinal tract and your central nervous system. It's why we say "gut feeling" — your gut literally influences your thoughts and emotions.

How They Communicate:
1. Vagus Nerve — Direct physical connection; 80% of signals travel FROM gut TO brain
2. Neurotransmitters — Gut bacteria produce serotonin, dopamine, GABA directly
3. Immune System — Gut inflammation sends signals that affect brain function
4. Endocrine Pathway — Hormones produced in the gut influence brain chemistry
5. Metabolites — Short-chain fatty acids (butyrate, propionate) cross the blood-brain barrier

Evidence-Based Gut-Brain Connections:

Mental Health:
• Depression: 90% of serotonin is produced in the gut. People with depression often have reduced Lactobacillus and Bifidobacterium
• Anxiety: Gut dysbiosis increases cortisol (stress hormone) production
• PTSD: Combat veterans show distinct gut microbiome differences

Cognitive Function:
• Brain fog: Gut inflammation can impair memory and concentration
• Alzheimer's: Amyloid proteins from gut bacteria may contribute to plaques
• Learning: Mice with diverse microbiomes learn faster in maze tests

Neurological Conditions:
• Parkinson's: The disease may actually start in the gut (constipation precedes motor symptoms by years)
• Autism: Many autistic individuals have GI issues; microbiome interventions show promise
• Multiple Sclerosis: Gut bacteria influence immune cells that attack myelin

The Stress-Gut Cycle:
Stress → Increased cortisol → Gut permeability increases → Inflammation → Bad bacteria thrive → More inflammatory signals to brain → More stress

Breaking the Cycle:
• Probiotics (specific strains like L. rhamnosus reduce anxiety)
• Prebiotic fiber (feeds good bacteria that produce calming metabolites)
• Meditation and deep breathing (activates vagus nerve)
• Regular exercise (increases beneficial gut bacteria diversity)
• Adequate sleep (gut bacteria follow circadian rhythms)''',
      ),
      const Lesson(
        title: 'The Gut-Hormone Axes',
        content: '''Your gut microbiome influences virtually every hormonal system in your body through specialized communication axes.

Gut-Thyroid Axis:
• Gut bacteria convert inactive T4 hormone to active T3 (the form your cells use)
• Hypothyroidism is linked to low gut diversity
• Selenium and zinc (absorbed in the gut) are essential for thyroid function
• Gluten intolerance (common in Hashimoto's) damages gut lining
• Probiotics can improve thyroid medication absorption

Gut-Testis Axis (Male Reproductive Health):
• The gut microbiome influences testosterone production
• Gut bacteria help metabolize estrogen (estrobolome)
• Gut dysbiosis is linked to reduced sperm quality and count
• Butyrate-producing bacteria support Leydig cell function (testosterone production)
• Chronic gut inflammation increases cortisol, which suppresses testosterone
• Studies show men with diverse microbiomes have higher testosterone levels
• The gut-testis axis explains why gut health directly affects fertility, muscle mass, energy, and libido

Gut-Ovary Axis (Female Reproductive Health):
• Gut bacteria help regulate estrogen through the estrobolome
• PCOS (Polycystic Ovary Syndrome) is strongly linked to gut dysbiosis
• Endometriosis patients show distinct gut microbiome differences
• Gut health influences menstrual regularity and fertility
• The estrobolome determines how effectively estrogen is recycled or excreted

Gut-Adrenal Axis (Stress Response):
• Gut bacteria modulate the HPA (hypothalamic-pituitary-adrenal) axis
• Dysbiosis amplifies cortisol production
• Chronic gut inflammation leads to adrenal fatigue
• Short-chain fatty acids from gut bacteria help regulate stress response

Gut-Liver Axis:
• The portal vein directly connects gut to liver
• Gut bacteria produce metabolites that the liver must process
• "Leaky gut" sends bacterial toxins (LPS) to the liver, causing inflammation
• NAFLD (Non-Alcoholic Fatty Liver Disease) is linked to gut dysbiosis
• Healthy gut bacteria protect against liver fibrosis''',
      ),
      const Lesson(
        title: 'The Gut-Immune Axis',
        content: '''Your gut is the headquarters of your immune system. Understanding this axis is key to preventing disease and maintaining health.

The Immune-Gut Connection:
• 70-80% of immune cells reside in the gut (GALT — Gut-Associated Lymphoid Tissue)
• The gut lining is only ONE cell layer thick — thinner than a sheet of paper
• This single layer must decide what to absorb and what to reject
• Gut bacteria "train" immune cells to distinguish friend from foe

How Gut Bacteria Train Immunity:
1. Tolerance Training — Good bacteria teach immune cells NOT to overreact to harmless substances (preventing allergies)
2. Pathogen Defense — Beneficial bacteria produce antimicrobial compounds that fight invaders
3. Barrier Maintenance — Bacteria strengthen tight junctions between gut cells
4. Immune Memory — Gut exposure to diverse microbes builds a robust immune library

When the Gut-Immune Axis Fails:
• Autoimmune diseases: Type 1 diabetes, rheumatoid arthritis, lupus
• Allergies: Reduced microbial diversity in early life increases allergy risk
• Chronic inflammation: Linked to heart disease, cancer, neurodegenerative diseases
• Increased infections: Weakened immune response to pathogens

Supporting Your Gut-Immune Axis:
• Eat 30+ different plants per week (fiber diversity = microbiome diversity)
• Include fermented foods daily
• Avoid unnecessary antibiotics
• Spend time in nature (environmental microbes build immunity)
• Get adequate sleep (immune cells regenerate during sleep)
• Manage stress (cortisol suppresses immune function)

The Hygiene Hypothesis:
Our modern sanitized environments may actually weaken our immune systems by reducing exposure to diverse microbes. Studies show children raised on farms have fewer allergies and autoimmune diseases due to greater microbial exposure.''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'gm_easy_1',
        question: 'Where is 95% of the body\'s serotonin produced?',
        options: ['Brain', 'Gut', 'Heart', 'Liver'],
        correctIndex: 1,
        explanation: 'Approximately 95% of serotonin is produced in the gut by enterochromaffin cells and certain gut bacteria. This is why gut health directly impacts mood and mental well-being.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'gm_easy_2',
        question: 'How many microorganisms live in a healthy human gut?',
        options: ['1 million', '1 billion', '100 trillion', '1 quadrillion'],
        correctIndex: 2,
        explanation: 'A healthy human gut contains over 100 trillion microorganisms — that\'s more than the total number of cells in the human body. This ecosystem weighs about 2 kg.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'gm_medium_1',
        question: 'What is the "estrobolome"?',
        options: [
          'A type of gut bacteria',
          'The collection of gut bacteria that metabolize estrogen',
          'A hormone produced by the gut',
          'A part of the brain connected to the gut',
        ],
        correctIndex: 1,
        explanation: 'The estrobolome is the collection of gut bacteria capable of metabolizing estrogen. These bacteria produce beta-glucuronidase, an enzyme that helps recycle estrogen back into circulation. Dysbiosis of the estrobolome is linked to PCOS, endometriosis, and hormone-related cancers.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'gm_medium_2',
        question: 'How do gut bacteria communicate with the brain?',
        options: [
          'Only through blood sugar levels',
          'Through the vagus nerve, neurotransmitters, immune signals, and metabolites',
          'They don\'t communicate directly',
          'Only through hormone production',
        ],
        correctIndex: 1,
        explanation: 'The gut-brain axis uses multiple communication pathways: the vagus nerve (direct physical connection), neurotransmitters (serotonin, dopamine, GABA produced by gut bacteria), immune signals (inflammatory molecules), and metabolites (short-chain fatty acids that cross the blood-brain barrier).',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'gm_hard_1',
        question: 'Which gut bacteria group is specifically linked to healthy weight management by maintaining the gut mucus lining?',
        options: [
          'Lactobacillus',
          'Akkermansia muciniphila',
          'E. coli',
          'Clostridium',
        ],
        correctIndex: 1,
        explanation: 'Akkermansia muciniphila is a next-generation probiotic that lives in the mucus layer of the gut. It strengthens the gut barrier, reduces inflammation, and is consistently associated with healthy weight. Low levels are linked to obesity and metabolic disorders.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'gm_hard_2',
        question: 'In Parkinson\'s disease research, what groundbreaking discovery was made about the gut-brain axis?',
        options: [
          'Parkinson\'s only affects the brain',
          'The disease may actually start in the gut, with constipation appearing years before motor symptoms',
          'Gut bacteria have no connection to Parkinson\'s',
          'Only medication can affect Parkinson\'s progression',
        ],
        correctIndex: 1,
        explanation: 'Alpha-synuclein protein aggregates (the hallmark of Parkinson\'s) have been found in the gut years before brain symptoms appear. This "Braak hypothesis" suggests Parkinson\'s may start in the gut and travel to the brain via the vagus nerve, opening new avenues for early detection and prevention.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _microplasticsModule = EcoModule(
    id: 'microplastics',
    title: 'Microplastics & Your Body',
    description: 'Learn how microplastics infiltrate your body, form layers in your colon, block nutrient absorption, and what you can do to protect yourself.',
    icon: 'shield',
    order: 7,
    lessons: [
      const Lesson(
        title: 'What Are Microplastics?',
        content: '''Microplastics are tiny plastic particles less than 5mm in size — about the size of a sesame seed or smaller. They come from the breakdown of larger plastics, manufacturing processes, and synthetic textiles.

Types of Microplastics:
1. Primary Microplastics — manufactured small (microbeads in cosmetics, industrial abrasives)
2. Secondary Microplastics — breakdown of larger plastic items (bottles, bags, packaging)
3. Nanoplastics — even smaller than microplastics (< 1 micrometer), can cross cell membranes

How They Enter Your Body:
• Drinking bottled water (average bottle contains 325,000 nanoplastics)
• Eating seafood (shellfish accumulate microplastics from ocean)
• Consuming packaged/processed food
• Breathing airborne microplastic particles
• Using plastic containers for hot food (heat accelerates leaching)
• Microwaving food in plastic containers

Alarming Statistics:
• Average person ingests 5 grams of plastic per week (equivalent to a credit card)
• Microplastics found in human blood, lungs, liver, and placenta
• Bottled water contains 10-100x more microplastics than tap water
• Tea bags release 11.6 billion microplastic particles per cup
• Canned food linings contain BPA (a plastic-derived endocrine disruptor)

The Plastic Additives Problem:
Plastics contain chemical additives that leach into food and water:
• BPA (Bisphenol A) — mimics estrogen, linked to hormonal disorders
• Phthalates — disrupt testosterone production
• PFAS ("forever chemicals") — accumulate in the body, linked to cancer
• Antimony — toxic metal catalyst used in PET plastic production
• Styrene — possible carcinogen from polystyrene (styrofoam) containers''',
      ),
      const Lesson(
        title: 'Microplastics in Your Colon',
        content: '''When microplastics enter your digestive system, they can accumulate in the colon and create a physical barrier that disrupts normal gut function.

How Microplastics Form Layers in the Colon:
1. Ingestion — Microplastics enter through food, water, and packaging
2. Partial Digestion — The body cannot break down plastic polymers
3. Accumulation — Particles stick to the mucosal lining of the colon
4. Layer Formation — Over time, microplastics form a biofilm layer on the colon wall
5. Barrier Effect — This layer physically blocks nutrient absorption

The Nutrient Blockade:
When microplastics coat the colon lining:
• Vitamin absorption decreases (B12, D, K, folate)
• Mineral absorption is impaired (iron, calcium, zinc, magnesium)
• Short-chain fatty acid production drops (butyrate for colon health)
• Gut barrier integrity weakens ("leaky gut")
• Inflammatory response increases
• Beneficial bacteria lose their habitat

Symptoms of Microplastic Accumulation:
• Chronic fatigue (malnutrition despite eating well)
• Brain fog and poor concentration
• Weakened immune system
• Digestive issues (bloating, constipation, IBS-like symptoms)
• Hormonal imbalances
• Skin problems (eczema, acne)
• Joint pain and inflammation

Real-World Impact:
Studies show microplastic exposure in animals causes:
• Reduced nutrient absorption by 20-30%
• Increased intestinal inflammation
• Disruption of gut microbiome composition
• Impaired gut barrier function
• Altered immune response''',
      ),
      const Lesson(
        title: 'Why Reduce Plastic Use',
        content: '''Reducing plastic use isn't just an environmental imperative — it's a personal health necessity. Here's why and how.

Health Reasons to Reduce Plastic:
1. Endocrine Disruption — BPA and phthalates mimic hormones, disrupting reproductive health
2. Cancer Risk — Styrene and vinyl chloride are known carcinogens
3. Neurological Effects — Lead and cadmium in plastics affect brain development
4. Immune Suppression — PFAS chemicals weaken immune response
5. Gut Health — Microplastics disrupt the microbiome and nutrient absorption

Environmental Reasons:
• 8 million tons of plastic enter oceans annually
• Plastic takes 400-1000 years to decompose
• Only 9% of all plastic ever made has been recycled
• Marine animals ingest plastic, entering the food chain
• Microplastics found in Arctic ice, deep ocean trenches, and mountaintops

Practical Steps to Reduce Plastic:

At Home:
• Switch to glass or stainless steel food containers
• Use beeswax wraps instead of plastic wrap
• Buy in bulk using your own containers
• Choose bar soap and shampoo over bottled versions
• Use cloth bags for shopping

In the Kitchen:
• Never microwave food in plastic containers
• Use glass or ceramic for hot food storage
• Drink from stainless steel or glass bottles
• Avoid canned food (BPA linings) — choose glass jars instead
• Store food in glass containers

For Children:
• Use stainless steel lunchboxes
• Avoid plastic toys when wooden alternatives exist
• Choose cloth diapers or biodegradable options
• Use glass baby bottles (sterilize safely)

At Work/School:
• Bring lunch in glass/stainless containers
• Use a reusable coffee mug
• Avoid single-use water bottles
• Choose paper or cloth over plastic包装''',
      ),
      const Lesson(
        title: 'Protecting Yourself from Microplastics',
        content: '''Practical strategies to minimize microplastic exposure and help your body detoxify what it has already accumulated.

Immediate Actions:
1. Stop microwaving food in plastic — transfer to glass or ceramic
2. Replace plastic water bottles with glass or stainless steel
3. Avoid tea bags — loose leaf tea has 100x fewer microplastics
4. Don't use plastic cutting boards — use wood or bamboo
5. Replace non-stick cookware with cast iron or stainless steel

Detoxification Support:
• Increase fiber intake (binds microplastics for elimination)
• Eat cruciferous vegetables (support liver detoxification pathways)
• Consume activated charcoal (binds to toxins in the gut)
• Take chlorella supplements (shown to reduce heavy metals and plastics)
• Stay hydrated (supports kidney elimination)
• Exercise regularly (sweating helps eliminate toxins)

Gut Barrier Repair:
• L-Glutamine supplements (repair gut lining)
• Bone broth (rich in collagen and aminorients)
• Probiotics (rebuild healthy microbiome)
• Prebiotic fiber (feed beneficial bacteria)
• Zinc carnosine (protects stomach lining)

Reading Labels:
• Avoid products with recycling codes 3 (PVC), 6 (polystyrene), and 7 (may contain BPA)
• Choose "BPA-free" but note BPS (BPA substitute) may be equally harmful
• Look for glass or metal packaging when possible
• Check cosmetics for microbeads (polyethylene, polypropylene)

The Bigger Picture:
Individual action matters, but systemic change is essential:
• Support legislation banning single-use plastics
• Choose companies with sustainable packaging
• Advocate for extended producer responsibility
• Push for better recycling infrastructure''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'mp_easy_1',
        question: 'How much plastic does the average person ingest per week?',
        options: ['50 grams', '5 grams (a credit card)', '500 grams', '0.5 grams'],
        correctIndex: 1,
        explanation: 'Studies estimate the average person ingests about 5 grams of microplastics per week — roughly the weight of a credit card. This comes from water, food, air, and packaging.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'mp_easy_2',
        question: 'What happens when you microwave food in a plastic container?',
        options: [
          'Nothing — plastic is heat resistant',
          'Heat accelerates leaching of BPA, phthalates, and other chemicals into food',
          'The plastic becomes stronger',
          'It makes food healthier',
        ],
        correctIndex: 1,
        explanation: 'Heat significantly accelerates the leaching of plastic chemicals into food. BPA, phthalates, antimony, and styrene all migrate faster at higher temperatures. Always transfer food to glass or ceramic before microwaving.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'mp_medium_1',
        question: 'How do microplastics physically affect nutrient absorption in the colon?',
        options: [
          'They dissolve and block enzymes',
          'They form a biofilm layer on the colon wall, creating a physical barrier between nutrients and absorption sites',
          'They increase absorption',
          'They only affect the stomach, not the colon',
        ],
        correctIndex: 1,
        explanation: 'Microplastics accumulate on the mucosal lining of the colon and form a biofilm layer. This physical barrier prevents vitamins, minerals, and short-chain fatty acids from reaching the intestinal cells that absorb them, reducing nutrient uptake by 20-30%.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'mp_medium_2',
        question: 'Which plastic recycling code should you be MOST careful about due to BPA content?',
        options: [
          'Code 1 (PET)',
          'Code 2 (HDPE)',
          'Code 7 (Other — may contain BPA)',
          'Code 5 (PP)',
        ],
        correctIndex: 2,
        explanation: 'Recycling code 7 is a catch-all "Other" category that includes polycarbonate (which contains BPA) and other plastics. Code 3 (PVC) and Code 6 (polystyrene) are also concerning. Codes 1, 2, and 5 are generally considered safer.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'mp_hard_1',
        question: 'A patient drinks 2 liters of bottled water daily and eats mostly packaged food. After blood tests show deficiencies in B12, iron, and vitamin D despite adequate dietary intake. What is the most likely explanation?',
        options: [
          'The patient has a genetic absorption disorder',
          'Microplastic accumulation in the colon is forming a biofilm barrier, blocking nutrient absorption despite adequate intake',
          'The blood tests are inaccurate',
          'The patient is not eating enough food',
        ],
        correctIndex: 1,
        explanation: 'Bottled water is a major source of microplastics (325,000 nanoplastics per bottle). Combined with packaged food, chronic exposure leads to microplastic accumulation in the colon. The biofilm layer physically blocks nutrient absorption, explaining deficiencies despite adequate intake.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'mp_hard_2',
        question: 'Which of the following is the MOST effective strategy for reducing microplastic accumulation in the body?',
        options: [
          'Drinking only filtered water for one day',
          'A comprehensive approach: eliminate plastic food contact, increase fiber for elimination, support gut barrier repair, and reduce packaged food consumption',
          'Taking a single detox supplement',
          'Avoiding all food for a week',
        ],
        correctIndex: 1,
        explanation: 'Reducing microplastic accumulation requires a multi-pronged approach: eliminate sources (plastic food contact), increase fiber (binds microplastics for elimination), repair gut barrier (L-glutamine, probiotics), and reduce packaged food. Single interventions are insufficient against chronic exposure.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );

  static final _gutHealthImprovementModule = EcoModule(
    id: 'gut_health_improvement',
    title: 'Improve Your Gut Health',
    description: 'Learn Dr. Kadhar Valli\'s approach to gut health through fermented millets (siridhanyalu), traditional food wisdom, and practical dietary strategies.',
    icon: 'spa',
    order: 8,
    lessons: [
      const Lesson(
        title: 'Dr. Kadhar Valli: The Man Who Heals with Food',
        content: '''Dr. Kadhar Valli is a renowned health practitioner and researcher who has dedicated his life to reviving traditional Indian food wisdom for modern health problems. He is widely recognized for his work on gut health restoration through fermented millets (siridhanyalu).

Who is Dr. Kadhar Valli:
• A leading authority on traditional Indian nutrition and gut health restoration
• Has conducted extensive research on fermented millet-based diets and their impact on chronic diseases
• Advocates returning to our ancestral diet as the foundation for disease prevention
• Specializes in millet-based nutrition for gut microbiome restoration and gut-brain axis health
• Has helped thousands of patients reverse chronic conditions including diabetes, IBS, obesity, and autoimmune disorders through dietary changes
• Emphasizes fermented foods as the cornerstone of gut health and overall wellness

Core Philosophy:
1. Food is Medicine — The right diet can prevent and reverse chronic disease. Every meal is an opportunity to heal or harm.
2. Fermentation is Essential — Our ancestors fermented everything for gut health. This lost art is the key to modern wellness.
3. Millets Over Rice — Siridhanyalu (sweet millets) are superior to polished rice. Rice is a "destroyer" while millets are "healers."
4. Conservation Over Consumption — It's not just about what you eat, but how you relate to food. Conserve food, don't waste it. Eat what your body needs, not what your tongue desires.
5. Simplicity — Simple, traditional preparations are more effective than exotic superfoods. Grandmother's recipes beat modern nutrition trends.

Dr. Kadhar Valli's Key Message:
"The gut is the root of all disease. When the gut is healthy, the body heals itself. When the gut is damaged, no medicine in the world can help. We must return to fermented millets — they are not just food, they are medicine for the gut."

The Siridhanyalu (Sweet Millets):
"Siridhanyalu" literally means "sweet grains" — millets that are naturally sweet and alkaline-forming in the body. Unlike rice and wheat, these millets don't spike blood sugar and support gut bacteria. Dr. Kadhar Valli calls them "the grains that heal."

The 5 Millets for Amballi (Dr. Kadhar Valli's Specific Recommendation):
1. Korallu (Kodo Millet) — Anti-inflammatory, rich in antioxidants, supports liver detox
2. Andu Korallu (Barnyard Millet) — Highest fiber content, excellent for gut cleansing
3. Samalu (Foxtail Millet) — Low glycemic index, brain health, mood regulation
4. Udal (Kodo Millet variant) — Supports digestive enzyme production, gut lining repair
5. Arikelu (Browntop Millet) — Rarest millet, highest prebiotic fiber, complete gut restoration

Why Fermented Millets Work (Dr. Kadhar Valli's Explanation):
• Fermentation pre-digests the grain, making nutrients more bioavailable
• Produces beneficial organic acids (lactic acid, acetic acid) that kill bad bacteria
• Increases B-vitamin content including B12 analogs
• Creates natural probiotics (Lactobacillus plantarum) that colonize the gut
• Reduces anti-nutrients (phytic acid) that block mineral absorption
• Produces short-chain fatty acids (butyrate) that feed colon cells and reduce inflammation
• The gut microbiome thrives on diversity — mixing millets creates a complete probiotic ecosystem''',
      ),
      const Lesson(
        title: 'Making Amballi: Dr. Kadhar Valli\'s Signature Fermented Millet Drink',
        content: '''Amballi is Dr. Kadhar Valli's signature fermented millet drink — a traditional probiotic beverage made from siridhanyalu. It is the cornerstone of his gut health protocol. Here is the complete step-by-step process.

The 5 Millets for Amballi:
• Korallu (Kodo Millet) — 2 parts
• Andu Korallu (Barnyard Millet) — 2 parts
• Samalu (Foxtail Millet) — 2 parts
• Udal (Kodo variant) — 1 part
• Arikelu (Browntop Millet) — 1 part

Total: Mix all 5 millets in these proportions. You can prepare a batch of 500g-1kg.

Step-by-Step Amballi Preparation:

Step 1: Cleaning & Sorting (5 minutes)
• Take the mixed millets and spread on a clean cloth
• Remove any stones, husks, or damaged grains
• Dr. Kadhar Valli says: "Respect the grain. Clean it carefully. This is the first act of love toward your food."

Step 2: Washing (3-4 times)
• Wash the millets thoroughly in clean water
• Each wash removes dust, pesticides, and surface impurities
• The water should run clear after 3-4 washes

Step 3: Soaking (8-12 hours)
• Soak the washed millets in clean water for 8-12 hours (overnight)
• The water ratio: 1 cup millets to 3 cups water
• Soaking activates enzymes and begins the breakdown of anti-nutrients
• You'll notice the water turns slightly yellow — this is normal

Step 4: Sprouting (Optional but Recommended — 12-24 hours)
• Drain the water completely after soaking
• Tie the millets in a clean cotton cloth
• Hang in a warm, dark place for 12-24 hours
• Small white sprouts should appear
• Dr. Kadhar Valli: "Sprouting doubles the nutrition. The grain is trying to create life — we harness that energy."

Step 5: Grinding
• Grind the sprouted (or soaked) millets into a coarse paste
• Use a traditional stone grinder (sil batta) or mixer with minimal water
• The paste should be slightly coarse, not completely smooth
• Add just enough water to enable grinding

Step 6: Fermentation (The Most Critical Step)
• Transfer the paste to a clay pot (traditional) or glass container
• Add a starter culture: 2 tablespoons of previous batch's fermented batter
• If no starter: add 2 tablespoons of fresh yogurt or buttermilk
• Cover loosely with a clean cloth (allow gas to escape)
• Place in a warm spot (25-35°C) for 12-24 hours
• The batter will rise, become slightly sour, and develop air pockets
• Dr. Kadhar Valli: "The clay pot breathes. It releases minerals. The fermentation in clay is alive — in metal, it dies."

Step 7: Making the Amballi Drink
• Take 1 cup of fermented millet batter
• Mix with 2 cups of cool water (or buttermilk for extra probiotics)
• Add a pinch of salt (rock salt preferred)
• Stir well — the consistency should be like a thin porridge
• Optionally add: fresh curry leaves, grated ginger, or green chili

Step 8: Serving
• Serve immediately for maximum probiotic benefit
• Can be stored in the refrigerator for up to 24 hours (probiotics remain active)
• Best consumed on an empty stomach in the morning or as a mid-morning drink
• Pair with a simple meal for best gut healing results

Traditional Variations:
1. Sweet Amballi: Add jaggery or dates instead of salt
2. Savory Amballi: Add roasted cumin, curry leaves, and buttermilk
3. Spiced Amballi: Add grated ginger, green chili, and coriander leaves
4. Cool Amballi: Refrigerate for 2 hours before serving (summer drink)

Dr. Kadhar Valli's Tips:
• "Never boil amballi after fermentation — you kill the probiotics"
• "Drink it fresh. The living bacteria work best when active"
• "If it smells too sour, add a little fresh buttermilk to balance"
• "Start with small amounts (half cup) and increase gradually"
• "The best time is morning, before breakfast, on an empty stomach"''',
      ),
      const Lesson(
        title: 'The Science: How Amballi Heals Your Gut',
        content: '''Amballi isn't just a traditional drink — it's a scientifically proven gut-healing powerhouse. Here's what happens in your body when you consume fermented millet amballi daily.

Scientific Data on Fermented Millets:

1. Microbiome Restoration (Published in Journal of Functional Foods, 2021):
• Fermented millet consumption increases Lactobacillus count by 10x within 14 days
• Bifidobacterium levels increase by 8x within 21 days
• Pathogenic bacteria (E. coli, Salmonella) reduced by 60-70%
• Microbiome diversity score improved by 45% in 30 days

2. Short-Chain Fatty Acid (SCFA) Production:
• Butyrate production increases 3x with daily fermented millet intake
• Butyrate is the primary fuel for colonocytes (colon cells)
• Propionate reduces cholesterol synthesis in the liver
• Acetate regulates appetite through gut-brain signaling
• Study: 200ml daily amballi for 8 weeks showed 52% reduction in gut inflammation markers

3. Gut Barrier Function (Published in Gut Microbes, 2022):
• Fermented millet SCFAs strengthen tight junctions between gut cells
• Zonulin levels (leaky gut marker) decreased by 40% in 6 weeks
• Intestinal permeability normalized in 78% of participants
• Lactobacillus plantarum from fermentation produces antimicrobial peptides

4. Nutrient Bioavailability:
• Iron absorption: 5% (unfermented) → 20% (fermented) — 4x increase
• Zinc absorption: 15% → 35% — more than doubled
• Calcium bioavailability: 25% → 55% — doubled
• Phytic acid (anti-nutrient): reduced by 60-80% through fermentation
• Vitamin B12 analogs: produced by bacterial fermentation (0 → 0.5-2.0 mcg/100g)

5. Gut-Brain Axis Benefits:
• Fermented millet consumption reduces cortisol levels by 23%
• Serotonin production in the gut increases (90% of serotonin is made in the gut)
• Anxiety scores reduced by 35% in clinical trials with daily amballi consumption
• Sleep quality improved by 40% after 8 weeks of fermented millet diet
• Dr. Kadhar Valli: "The gut is the second brain. When it heals, the mind follows."

6. Anti-Inflammatory Effects:
• CRP (C-reactive protein) levels reduced by 30% in 8 weeks
• IL-6 (inflammatory cytokine) decreased by 45%
• TNF-alpha reduced by 38%
• These changes were comparable to low-dose anti-inflammatory medication

7. Metabolic Benefits:
• Fasting blood sugar: reduced by 15-20% in diabetic patients
• HbA1c: improved by 1.2% in 12 weeks
• Cholesterol: total cholesterol reduced by 12%, LDL by 18%
• Body weight: average 3-5kg reduction over 12 weeks without calorie restriction

Dr. Kadhar Valli's Scientific Explanation:
"Amballi works because it provides BOTH probiotics AND prebiotics together. The fermented bacteria (probiotics) colonize the gut, while the millet fiber (prebiotics) feeds them. This is called a synbiotic effect. Commercial probiotics are like planting seeds in desert soil — they don't survive. Amballi plants seeds AND waters the soil."

Clinical Evidence:
• Dr. Kadhar Valli's own clinical data shows 85% improvement in IBS symptoms within 8 weeks
• 70% of Type 2 diabetic patients reduced medication within 6 months
• 90% of patients reported improved energy and sleep within 3 weeks
• Gut transit time improved from average 58 hours to 32 hours in 4 weeks''',
      ),
      const Lesson(
        title: 'Conservation vs Consumption: Dr. Kadhar Valli\'s Wisdom',
        content: '''Dr. Kadhar Valli teaches that gut health isn't just about what you eat — it's about your entire relationship with food. His philosophy of "Conservation vs Consumption" is a radical shift from modern food culture.

Dr. Kadhar Valli's Words on Conservation:

"We have become a society of consumers, not conservers. We waste food, we overeat, we eat what we don't need. This is destroying our gut and our planet."

"Conservation means respecting food. Every grain of millet took 90 days of sunshine, rain, and soil nutrients to grow. When you waste it, you waste nature's gift."

"Consumption is the disease. We consume too much, too fast, too often. Our gut was designed for simple, fermented foods — not for the avalanche of processed junk we pour into it."

The Difference Between Conservation and Consumption:

CONSUMPTION (Modern Habit):
• Eating more than you need
• Wasting food thoughtlessly
• Eating for pleasure, not nutrition
• Constant snacking and overeating
• Choosing convenience over health
• Importing exotic superfoods while ignoring local wisdom
• Eating quickly, without attention

CONSERVATION (Dr. Kadhar Valli's Way):
• Eating only what your body needs
• Valuing every grain and every meal
• Eating for nourishment and healing
• Eating at regular intervals, allowing digestion
• Choosing traditional, local foods
• Using indigenous millets that grow without irrigation
• Eating slowly, chewing thoroughly, being grateful

Dr. Kadhar Valli's Practical Conservation Principles:

1. "Eat Less, But Eat Well"
• A handful of amballi is enough for a meal
• Don't fill the plate — fill the body's needs
• The gut works best when not overloaded
• "One handful of millet provides more nutrition than a plate of rice"

2. "Waste Nothing"
• Use every part of the millet — husk can be used for compost
• Leftover amballi becomes the starter for the next batch
• Vegetable peels become compost for the garden
• "Waste is a failure of imagination"

3. "Eat Local, Eat Seasonal"
• Siridhanyalu grow in Indian soil — they are designed for Indian bodies
• Imported quinoa from South America is not superior to local foxtail millet
• "Nature provides what you need, where you need it"
• Seasonal eating aligns your gut with natural rhythms

4. "Ferment Everything"
• Fermentation is nature's way of conserving food
• Fermented foods last longer and become MORE nutritious
• "Our grandmothers fermented everything — pickles, batter, buttermilk. We forgot this wisdom."

5. "Listen to Your Gut"
• Eat when hungry, stop when satisfied
• Don't eat because it's "meal time" — eat because your body needs fuel
• The gut knows what it needs — learn to listen
• "The tongue says 'more more more.' The gut says 'enough, I'm healing.'"

6. "Conservation Extends to the Planet"
• Millets grow with minimal water (300 liters vs 3000 liters for rice)
• Millets grow in poor soil without fertilizers
• Choosing millets conserves water and soil
• "When you eat millet, you conserve water. When you eat rice, you waste it."

Dr. Kadhar Valli's Message to the World:
"We don't need more food — we need better food. We don't need exotic superfoods — we need our own millets back. We don't need expensive probiotics — we need fermented amballi. The solution to gut health, diabetes, obesity, and inflammation was always in our grandmother's kitchen. We just stopped listening."

"The greatest medicine is already inside you — your gut microbiome. Feed it right, and it will heal you. Feed it wrong, and no medicine can save you. Choose conservation. Choose millets. Choose fermented food. Choose life."

Reflection:
1. How much food do you waste each day? What would Dr. Kadhar Valli say about that?
2. Are you eating for nourishment or for pleasure? Can you do both?
3. What local, traditional foods have you replaced with modern alternatives?
4. How would your life change if you adopted the conservation mindset?
5. What is one step you can take today to return to traditional eating?''',
      ),
    ],
    questions: [
      const QuizQuestion(
        id: 'gh_easy_1',
        question: 'Which 5 millets does Dr. Kadhar Valli specifically recommend for making amballi?',
        options: [
          'Ragi, Jowar, Bajra, Foxtail, Little millet',
          'Korallu, Andu Korallu, Samalu, Udal, Arikelu',
          'Rice, Wheat, Barley, Oats, Quinoa',
          'Ragi, Bajra, Jowar, Kodo, Proso',
        ],
        correctIndex: 1,
        explanation: 'Dr. Kadhar Valli specifically recommends Korallu (Kodo millet), Andu Korallu (Barnyard millet), Samalu (Foxtail millet), Udal (Kodo variant), and Arikelu (Browntop millet) for making amballi. These 5 millets together create a complete probiotic and prebiotic system.',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'gh_easy_2',
        question: 'What is amballi according to Dr. Kadhar Valli\'s teachings?',
        options: [
          'A type of rice dish',
          'A fermented millet drink that heals the gut',
          'A vegetable curry',
          'A type of bread',
        ],
        correctIndex: 1,
        explanation: 'Amballi is Dr. Kadhar Valli\'s signature fermented millet drink — a traditional probiotic beverage made from siridhanyalu. It is the cornerstone of his gut health protocol and provides both probiotics (live bacteria) and prebiotics (fiber to feed them).',
        difficulty: QuestionDifficulty.easy,
      ),
      const QuizQuestion(
        id: 'gh_medium_1',
        question: 'How does amballi improve iron absorption compared to unfermented millets?',
        options: [
          'Iron absorption stays the same',
          'Iron absorption increases by 2x',
          'Iron absorption increases by 4x (from 5% to 20%)',
          'Iron absorption decreases because fermentation removes iron',
        ],
        correctIndex: 2,
        explanation: 'Scientific studies show that fermentation reduces phytic acid (an anti-nutrient that blocks iron absorption) by 60-80%. This increases iron bioavailability from approximately 5% in unfermented millets to 20% in fermented millets — a 4x improvement. This is why Dr. Kadhar Valli emphasizes fermentation.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'gh_medium_2',
        question: 'According to Dr. Kadhar Valli, what is the difference between "consumption" and "conservation"?',
        options: [
          'Consumption is eating vegetables; conservation is eating meat',
          'Consumption is eating more than you need and wasting food; conservation is eating only what you need and valuing every grain',
          'Conservation means saving food for later; consumption means eating immediately',
          'There is no difference — both mean the same thing',
        ],
        correctIndex: 1,
        explanation: 'Dr. Kadhar Valli teaches that consumption is the modern disease — eating too much, too fast, wasting food, and choosing convenience over health. Conservation means respecting food, eating only what your body needs, valuing every grain, and returning to traditional, local foods like siridhanyalu.',
        difficulty: QuestionDifficulty.medium,
      ),
      const QuizQuestion(
        id: 'gh_hard_1',
        question: 'Why does Dr. Kadhar Valli say commercial probiotics are less effective than amballi?',
        options: [
          'Commercial probiotics are too expensive',
          'Commercial probiotics contain dead bacteria',
          'Amballi provides BOTH probiotics AND prebiotics (synbiotic effect), while commercial probiotics lack prebiotics to feed the bacteria',
          'Commercial probiotics have too many strains',
        ],
        correctIndex: 2,
        explanation: 'Dr. Kadhar Valli explains: "Commercial probiotics are like planting seeds in desert soil — they don\'t survive." Amballi is a synbiotic food containing both probiotics (Lactobacillus from fermentation) AND prebiotics (millet fiber that feeds them). This ensures the bacteria colonize and thrive in the gut.',
        difficulty: QuestionDifficulty.hard,
      ),
      const QuizQuestion(
        id: 'gh_hard_2',
        question: 'Dr. Kadhar Valli states that millets conserve water compared to rice. How much water does millet require versus rice?',
        options: [
          'Millets require 300 liters vs rice requires 3000 liters per kg',
          'Millets require 1000 liters vs rice requires 2000 liters per kg',
          'Millets require 500 liters vs rice requires 1000 liters per kg',
          'There is no significant difference in water usage',
        ],
        correctIndex: 0,
        explanation: 'Dr. Kadhar Valli emphasizes that millets are water-efficient crops requiring only about 300 liters per kg, while rice requires approximately 3000 liters per kg — 10 times more. By choosing millets over rice, you conserve water and protect the environment while improving your gut health.',
        difficulty: QuestionDifficulty.hard,
      ),
    ],
  );
}

class ModuleVerification {
  final String moduleId;
  final bool exists;
  final int lessonCount;
  final int expectedLessons;
  final int questionCount;
  final int expectedQuestions;
  final bool lessonsMatch;
  final bool questionsMatch;

  const ModuleVerification({
    required this.moduleId,
    required this.exists,
    required this.lessonCount,
    required this.expectedLessons,
    required this.questionCount,
    required this.expectedQuestions,
    required this.lessonsMatch,
    required this.questionsMatch,
  });

  bool get passed => exists && lessonsMatch && questionsMatch;

  @override
  String toString() {
    final status = passed ? 'PASS' : 'FAIL';
    return '[$status] $moduleId: '
        'lessons=$lessonCount/$expectedLessons, '
        'questions=$questionCount/$expectedQuestions';
  }
}

class ModuleVerificationResult {
  final Map<String, ModuleVerification> modules;
  final bool allPassed;

  const ModuleVerificationResult({
    required this.modules,
    required this.allPassed,
  });

  void printReport() {
    print('');
    print('========================================');
    print('  MODULE VERIFICATION REPORT');
    print('========================================');
    print('');
    for (final v in modules.values) {
      print(v.toString());
    }
    print('');
    print('----------------------------------------');
    if (allPassed) {
      print('  ALL MODULES VERIFIED SUCCESSFULLY');
    } else {
      print('  VERIFICATION FAILED');
      final failed = modules.values.where((v) => !v.passed).toList();
      for (final v in failed) {
        print('  - ${v.moduleId}');
      }
    }
    print('========================================');
    print('');
  }
}
