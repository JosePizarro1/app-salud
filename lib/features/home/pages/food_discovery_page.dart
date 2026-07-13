import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import '../../../app/services/sfx_manager.dart';
import '../widgets/module_header.dart';

class FoodDiscoveryConfig {
  final String title;
  final String subtitle;
  final String mascotGif;
  final String mascotStatic;
  final double mascotHeight;
  final Color accentColor;
  final String bannerTitle;
  final String bannerText;
  final List<Map<String, String>> foods;

  const FoodDiscoveryConfig({
    required this.title,
    required this.subtitle,
    required this.mascotGif,
    required this.mascotStatic,
    this.mascotHeight = 160.0,
    required this.accentColor,
    required this.bannerTitle,
    required this.bannerText,
    required this.foods,
  });
}

class FoodDiscoveryPage extends StatefulWidget {
  final String categoryId;

  const FoodDiscoveryPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<FoodDiscoveryPage> createState() => _FoodDiscoveryPageState();
}

class _FoodDiscoveryPageState extends State<FoodDiscoveryPage> {
  final Set<int> _discoveredIndices = {};
  bool _showFloatingTip = false;
  bool _tipDismissed = false;
  // Touch feedback scales for items
  late List<double> _nodeScales;

  // Global static configs map
  static const Map<String, FoodDiscoveryConfig> _configs = {
    'energy': FoodDiscoveryConfig(
      title: 'Alimentos que dan Energía ⚡',
      subtitle: 'Son la principal fuente de energía. ¡Descúbrelos tocando los platos misteriosos!',
      mascotGif: 'assets/images/healthy_eating/gifs/titi pensativo (1).webp',
      mascotStatic: 'assets/images/healthy_eating/gifs/titi_pensativo_static.webp',
      accentColor: Colors.orange,
      bannerTitle: '¿POR QUÉ ELEGIRLOS?',
      bannerText: 'Una energía estable te ayuda a estudiar mejor, mantenerte activo y rendir todo el día.',
      foods: [
        {
          'name': 'Arroz integral',
          'desc': 'Es rico en fibra y carbohidratos complejos, aportando glucosa de forma lenta y sostenida para mantener tu concentración.',
          'image': 'assets/alimentos/1 arroz.webp',
          'emoji': '🌾',
        },
        {
          'name': 'Papa',
          'desc': 'Excelente fuente de energía limpia y potasio, ideal para mantener tus músculos activos y rendir durante el día.',
          'image': 'assets/alimentos/1 papa.webp',
          'emoji': '🥔',
        },
        {
          'name': 'Maíz',
          'desc': 'Aporta carbohidratos saludables y antioxidantes, esenciales para sostener el ritmo de tus actividades diarias.',
          'image': 'assets/alimentos/1 maiz.webp',
          'emoji': '🌽',
        },
        {
          'name': 'Avena',
          'desc': 'Contiene avenina y fibra que ayudan a liberar energía poco a poco, evitando los picos de azúcar y el cansancio.',
          'image': 'assets/alimentos/1 avena.webp',
          'emoji': '🥣',
        },
        {
          'name': 'Quinua',
          'desc': 'Un superalimento rico en proteínas y carbohidratos de bajo índice glucémico. Da energía duradera y cuida tu cuerpo.',
          'image': 'assets/alimentos/1 quinoa.webp',
          'emoji': '🌾',
        },
        {
          'name': 'Fideos',
          'desc': 'Aportan carbohidratos de fácil digestión que recargan el glucógeno de tus músculos y te mantienen listo para el ejercicio físico.',
          'image': 'assets/alimentos/1 fideos.webp',
          'emoji': '🍝',
        },
      ],
    ),
    'strength': FoodDiscoveryConfig(
      title: 'Alimentos que Fortalecen 💪',
      subtitle: 'Las proteínas ayudan al crecimiento, reparación y mantenimiento de músculos, órganos y tejidos.',
      mascotGif: 'assets/images/healthy_eating/gifs/titi pensativo (1).webp',
      mascotStatic: 'assets/images/healthy_eating/gifs/titi_pensativo_static.webp',
      accentColor: Colors.green,
      bannerTitle: '¿POR QUÉ ELEGIRLOS?',
      bannerText: 'Las proteínas son los ladrillos de tu cuerpo, indispensables para crecer fuertes y sanos.',
      foods: [
        {
          'name': 'Pescado',
          'desc': 'Excelente fuente de omega-3 y proteínas de alta calidad que ayudan a desarrollar músculos y a proteger el corazón.',
          'image': 'assets/alimentos/2 pescado.webp',
          'emoji': '🐟',
        },
        {
          'name': 'Pollo',
          'desc': 'Aporta proteínas magras y zinc, fundamentales para el crecimiento y el buen funcionamiento del sistema de defensas.',
          'image': 'assets/alimentos/2 pollo.webp',
          'emoji': '🍗',
        },
        {
          'name': 'Carne magra',
          'desc': 'Rica en hierro de fácil absorción y vitamina B12, clave para prevenir la anemia y tener glóbulos rojos saludables.',
          'image': 'assets/alimentos/2 carne.webp',
          'emoji': '🥩',
        },
        {
          'name': 'Huevo',
          'desc': 'Contiene proteínas de la más alta calidad y colina, un nutriente esencial para el desarrollo y salud de tu cerebro.',
          'image': 'assets/alimentos/2 huevo.webp',
          'emoji': '🥚',
        },
        {
          'name': 'Queso',
          'desc': 'Aporta proteínas y abundante calcio, indispensable para que tus dientes y huesos crezcan fuertes.',
          'image': 'assets/alimentos/2 queso.webp',
          'emoji': '🧀',
        },
        {
          'name': 'Lentejas',
          'desc': 'Fuente de proteínas de origen vegetal, fibra y hierro, ideales para brindarte fuerza y combatir el cansancio.',
          'image': 'assets/alimentos/2 lentejas.webp',
          'emoji': '🍲',
        },
      ],
    ),
    'brain': FoodDiscoveryConfig(
      title: 'Alimentos para el Cerebro 🧠',
      subtitle: 'Las grasas saludables forman parte de las células cerebrales, favoreciendo la memoria y el aprendizaje.',
      mascotGif: 'assets/images/healthy_eating/gifs/titi pensativo (1).webp',
      mascotStatic: 'assets/images/healthy_eating/gifs/titi_pensativo_static.webp',
      accentColor: Colors.red,
      bannerTitle: '¿POR QUÉ ELEGIRLOS?',
      bannerText: 'El cerebro está compuesto en gran parte por grasas. Las grasas saludables lo protegen y aceleran tu mente.',
      foods: [
        {
          'name': 'Palta',
          'desc': 'Rica en ácidos grasos monoinsaturados y vitamina E. Favorece la circulación sanguínea hacia el cerebro y mejora la concentración.',
          'image': 'assets/alimentos/3 palta.webp',
          'emoji': '🥑',
        },
        {
          'name': 'Maní',
          'desc': 'Aporta grasas saludables, vitamina E y antioxidantes. Ayuda a proteger las neuronas y mantener activa la memoria.',
          'image': 'assets/alimentos/3 mani.webp',
          'emoji': '🥜',
        },
        {
          'name': 'Nueces',
          'desc': 'Tienen forma de cerebro y son ricas en Omega-3. Ayudan a mejorar el rendimiento intelectual y el estado de ánimo.',
          'image': 'assets/alimentos/3 nueces.webp',
          'emoji': '🌰',
        },
        {
          'name': 'Semillas',
          'desc': 'Semillas de chía, linaza y girasol que aportan Omega-3, fibra y minerales para proteger tus células nerviosas.',
          'image': 'assets/alimentos/3 semillas.webp',
          'emoji': '🌻',
        },
        {
          'name': 'Aceite de oliva',
          'desc': 'Contiene potentes antioxidantes que combaten el envejecimiento celular y grasas saludables que lubrican tus neuronas.',
          'image': 'assets/alimentos/3 aceite de oliva.webp',
          'emoji': '🫒',
        },
        {
          'name': 'Pescados grasos',
          'desc': 'Caballa, sardina y atún aportan abundante Omega-3 (DHA/EPA), el alimento principal para una mente brillante y rápida.',
          'image': 'assets/alimentos/3 pescados.webp',
          'emoji': '🐟',
        },
      ],
    ),
    'stress': FoodDiscoveryConfig(
      title: 'Fortalece tus Defensas 🛡️',
      subtitle: 'Las frutas y verduras aportan vitaminas, minerales y fibra que ayudan a tu sistema inmunológico.',
      mascotGif: 'assets/images/healthy_eating/gifs/titi pensativo (1).webp',
      mascotStatic: 'assets/images/healthy_eating/gifs/titi_pensativo_static.webp',
      accentColor: Colors.purple,
      bannerTitle: '¿POR QUÉ ELEGIRLOS?',
      bannerText: 'Consumir frutas y verduras de varios colores asegura que obtengas todas las vitaminas para no enfermarte.',
      foods: [
        {
          'name': 'Naranja',
          'desc': 'Super fuente de vitamina C, un potente antioxidante que estimula tus defensas contra gripes y resfriados.',
          'image': 'assets/alimentos/4 naranja.webp',
          'emoji': '🍊',
        },
        {
          'name': 'Fresa',
          'desc': 'Aporta vitamina C, fibra y antocianinas que protegen tus células y te dan energía para jugar y estudiar.',
          'image': 'assets/alimentos/4 fresa.webp',
          'emoji': '🍓',
        },
        {
          'name': 'Kiwi',
          'desc': 'Tiene incluso más vitamina C que la naranja, además de fibra que cuida tu digestión y fortalece tu inmunidad.',
          'image': 'assets/alimentos/4 kiwi.webp',
          'emoji': '🥝',
        },
        {
          'name': 'Zanahoria',
          'desc': 'Rica en beta-caroteno (vitamina A), esencial para cuidar tu visión y mantener la piel sana como primera barrera de defensa.',
          'image': 'assets/alimentos/4 zanahoria.webp',
          'emoji': '🥕',
        },
        {
          'name': 'Brócoli',
          'desc': 'Aporta vitaminas A, C, E, hierro y antioxidantes que actúan como un escudo protector para tu sistema inmune.',
          'image': 'assets/alimentos/4 brocoli.webp',
          'emoji': '🥦',
        },
        {
          'name': 'Espinaca',
          'desc': 'Rica en ácido fólico, hierro y vitamina C. Ayuda a producir nuevas células de defensa y a llenarte de vitalidad.',
          'image': 'assets/alimentos/4 espinaca.webp',
          'emoji': '🥬',
        },
      ],
    ),
    'water': FoodDiscoveryConfig(
      title: 'El Nutriente Principal 💧',
      subtitle: 'El agua permite transportar nutrientes, regular la temperatura y asegurar que tu cerebro rinda al máximo.',
      mascotGif: 'assets/images/healthy_eating/gifs/titi pensativo (1).webp',
      mascotStatic: 'assets/images/healthy_eating/gifs/titi_pensativo_static.webp',
      accentColor: Colors.blue,
      bannerTitle: 'CONSEJOS DE HIDRATACIÓN',
      bannerText: '¡Recuerda tomar agua antes de tener sed! Tu cuerpo y tu mente te lo agradecerán durante el día escolar.',
      foods: [
        {
          'name': 'Botella de agua',
          'desc': '¡Lleva siempre tu botella de agua cuando salgas a estudiar o hacer deporte! Así te mantienes hidratado en cualquier momento.',
          'image': 'assets/alimentos/5 botella de agua.webp',
          'emoji': '🍼',
        },
        {
          'name': 'Jarra de agua',
          'desc': 'Mantén una jarra de agua limpia en la mesa de estudio. Tomar sorbos de agua frecuentemente ayuda a que tu cerebro trabaje mejor.',
          'image': 'assets/alimentos/5 jarra de agua.webp',
          'emoji': '🍶',
        },
        {
          'name': 'Tomatodo',
          'desc': 'Usa un tomatodo en tus clases. Hidratarte durante el día escolar previene los dolores de cabeza y mejora tu nivel de atención.',
          'image': 'assets/alimentos/5 tomatodo de agua.webp',
          'emoji': '🥤',
        },
        {
          'name': 'Vaso de agua',
          'desc': 'Toma un vaso de agua al despertar para activar tu cuerpo, y otro antes de dormir para mantenerte bien hidratado toda la noche.',
          'image': 'assets/alimentos/5 vaso de agua.webp',
          'emoji': '🥛',
        },
      ],
    ),
  };

  FoodDiscoveryConfig get _currentConfig => _configs[widget.categoryId] ?? _configs['energy']!;

  @override
  void initState() {
    super.initState();
    final config = _currentConfig;
    _nodeScales = List.generate(config.foods.length, (index) => 1.0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = _currentConfig;
    // Pre-cache assets
    if (config.mascotGif.isNotEmpty) {
      precacheImage(AssetImage(config.mascotGif), context);
    }
    precacheImage(AssetImage(config.mascotStatic), context);
    precacheImage(const AssetImage('assets/images/healthy_eating/images/boton check.webp'), context);
    for (var food in config.foods) {
      precacheImage(AssetImage(food['image']!), context);
    }
  }

  void _onTapFoodNode(int index) {
    if (_discoveredIndices.contains(index)) {
      _showDetailsDialog(index);
      return;
    }

    SfxManager().playClick();
    HapticFeedback.mediumImpact();
    setState(() {
      _nodeScales[index] = 0.92;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _nodeScales[index] = 1.0;
        });
        _showDetailsDialog(index);
      }
    });
  }

  void _showDetailsDialog(int index) {
    final config = _currentConfig;
    final food = config.foods[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ZoomIn(
          duration: const Duration(milliseconds: 300),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFD5CC),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(food['emoji']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          food['name']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD5CC), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      food['image']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE4D7)),
                    ),
                    child: Text(
                      food['desc']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      SfxManager().playClick();
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();

                      if (!_discoveredIndices.contains(index)) {
                        setState(() {
                          _discoveredIndices.add(index);
                        });

                        if (_discoveredIndices.length == config.foods.length) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) {
                              setState(() {
                                _showFloatingTip = true;
                              });
                              SfxManager().playNotiSound();
                            }
                          });
                        }
                      }
                    },
                    child: Bounce(
                      from: 10,
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton check.webp',
                        width: 58,
                        height: 58,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _currentConfig;

    final List<Widget> leftNodes = [];
    final List<Widget> rightNodes = [];

    if (config.foods.length == 4) {
      leftNodes.add(_buildFoodNode(0));
      leftNodes.add(const SizedBox(height: 20));
      leftNodes.add(_buildFoodNode(1));

      rightNodes.add(_buildFoodNode(2));
      rightNodes.add(const SizedBox(height: 20));
      rightNodes.add(_buildFoodNode(3));
    } else {
      leftNodes.add(_buildFoodNode(0));
      leftNodes.add(const SizedBox(height: 16));
      leftNodes.add(_buildFoodNode(1));
      leftNodes.add(const SizedBox(height: 16));
      leftNodes.add(_buildFoodNode(2));

      rightNodes.add(_buildFoodNode(3));
      rightNodes.add(const SizedBox(height: 16));
      rightNodes.add(_buildFoodNode(4));
      rightNodes.add(const SizedBox(height: 16));
      rightNodes.add(_buildFoodNode(5));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D7),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(15 / 360),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 150,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-20 / 360),
                child: Icon(
                  Icons.apple_rounded,
                  size: 140,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.emoji_food_beverage_rounded,
                  size: 110,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            const ModuleHeader(showHome: true, showBack: true),

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 140),
                child: Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          config.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          config.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: leftNodes,
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Center(
                                child: config.mascotGif.isNotEmpty
                                    ? Image.asset(
                                        config.mascotGif,
                                        height: config.mascotHeight,
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.pets_rounded,
                                          size: 80,
                                          color: Color(0xFFFF8A71),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.pets_rounded,
                                        size: 80,
                                        color: Color(0xFFFF8A71),
                                      ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: rightNodes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            if (_showFloatingTip && !_tipDismissed)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: GestureDetector(
                    onTap: () {
                      SfxManager().playClick();
                      HapticFeedback.lightImpact();
                      setState(() {
                        _tipDismissed = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFADCCFF),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.bannerTitle,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1A56B8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.bannerText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF1A56B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodNode(int index) {
    final config = _currentConfig;
    final food = config.foods[index];
    final isDiscovered = _discoveredIndices.contains(index);

    return AnimatedScale(
      scale: _nodeScales[index],
      duration: const Duration(milliseconds: 100),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _onTapFoodNode(index),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDiscovered ? const Color(0xFF4CAF50) : const Color(0xFFFFD5CC),
                      width: isDiscovered ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    food['image']!,
                    fit: BoxFit.contain,
                    color: isDiscovered ? null : Colors.black26,
                  ),
                ),

                if (isDiscovered)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton check.webp',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            width: 86,
            decoration: BoxDecoration(
              color: isDiscovered ? const Color(0xFFEDF7ED) : const Color(0xFFFFF2ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDiscovered ? const Color(0xFFCEEAD6) : const Color(0xFFFFD5CC),
                width: 1.2,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: isDiscovered
                  ? Text(
                      food['name']!,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E4620),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: Color(0xFFC2410C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '?',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFC2410C),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
