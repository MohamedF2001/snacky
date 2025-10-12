import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:provider/provider.dart';

class Scene {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final bool isNetwork;
  final List<SceneHotspot> hotspots;
  final Color themeColor;
  final IconData icon;

  Scene({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.isNetwork = false,
    this.hotspots = const [],
    this.themeColor = Colors.blue,
    this.icon = Icons.home,
  });
}

class SceneHotspot {
  final double latitude;
  final double longitude;
  final String targetSceneId;
  final String label;
  final IconData icon;
  final Color color;

  SceneHotspot({
    required this.latitude,
    required this.longitude,
    required this.targetSceneId,
    required this.label,
    this.icon = Icons.arrow_forward,
    this.color = Colors.blue,
  });
}

class SceneModel extends ChangeNotifier {
  String _currentId;
  final Map<String, Scene> scenes;
  bool _isLoading = false;

  SceneModel({required String startId, required this.scenes})
    : _currentId = startId;

  Scene get current => scenes[_currentId]!;
  bool get isLoading => _isLoading;

  Future<void> goTo(String sceneId) async {
    if (scenes.containsKey(sceneId) && sceneId != _currentId) {
      _isLoading = true;
      notifyListeners();

      // Simule un temps de chargement pour l'effet
      await Future.delayed(const Duration(milliseconds: 300));

      _currentId = sceneId;
      _isLoading = false;
      notifyListeners();
    }
  }
}

class Virtual extends StatelessWidget {
  const Virtual({super.key});

  @override
  Widget build(BuildContext context) {
    final scenes = {
      'living': Scene(
        id: 'living',
        title: 'Salon',
        description: 'Salon spacieux avec lumière naturelle et vue panoramique',
        imageAsset: 'assets/images/living_room_360.jpg',
        //imageAsset: 'assets/images/rab.jpeg',
        isNetwork: false,
        themeColor: const Color(0xFF4A90E2),
        icon: Icons.weekend,
        hotspots: [
          SceneHotspot(
            latitude: 0.0,
            longitude: 100.0,
            targetSceneId: 'kitchen',
            label: 'Cuisine',
            icon: Icons.kitchen,
            color: const Color(0xFF7ED321),
          ),
          SceneHotspot(
            latitude: -5.0,
            longitude: -40.0,
            targetSceneId: 'bedroom',
            label: 'Chambre',
            icon: Icons.bed,
            color: const Color(0xFFBD10E0),
          ),
        ],
      ),
      'kitchen': Scene(
        id: 'kitchen',
        title: 'Cuisine',
        description:
            'Cuisine moderne avec îlot central et équipements haut de gamme',
        imageAsset: 'https://example.com/panoramas/kitchen_360.jpg',
        isNetwork: true,
        themeColor: const Color(0xFF7ED321),
        icon: Icons.kitchen,
        hotspots: [
          SceneHotspot(
            latitude: 10.0,
            longitude: -120.0,
            targetSceneId: 'living',
            label: 'Salon',
            icon: Icons.weekend,
            color: const Color(0xFF4A90E2),
          ),
          SceneHotspot(
            latitude: 0.0,
            longitude: 60.0,
            targetSceneId: 'bedroom',
            label: 'Chambre',
            icon: Icons.bed,
            color: const Color(0xFFBD10E0),
          ),
        ],
      ),
      'bedroom': Scene(
        id: 'bedroom',
        title: 'Chambre',
        description:
            'Chambre cosy avec dressing intégré et salle de bain attenante',
        imageAsset: 'assets/images/bedroom_360.jpg',
        isNetwork: false,
        themeColor: const Color(0xFFBD10E0),
        icon: Icons.bed,
        hotspots: [
          SceneHotspot(
            latitude: 2.0,
            longitude: 60.0,
            targetSceneId: 'living',
            label: 'Salon',
            icon: Icons.weekend,
            color: const Color(0xFF4A90E2),
          ),
          SceneHotspot(
            latitude: -10.0,
            longitude: -80.0,
            targetSceneId: 'kitchen',
            label: 'Cuisine',
            icon: Icons.kitchen,
            color: const Color(0xFF7ED321),
          ),
        ],
      ),
    };

    return ChangeNotifierProvider(
      create: (_) => SceneModel(startId: 'living', scenes: scenes),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Visite Virtuelle 360°',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _showUI = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<SceneModel>(
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: _showUI
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      Icon(model.current.icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Visite Virtuelle 360°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => _showFloorplan(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          body: Stack(
            children: [
              const SceneView(),

              // Toggle UI Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showUI ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: () => setState(() => _showUI = !_showUI),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        _showUI ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading overlay
              if (model.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            model.current.themeColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFloorplan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const FloorplanSheet(),
    );
  }
}

class SceneView extends StatefulWidget {
  const SceneView({super.key});

  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeController.value = 1.0;
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _changeScene(SceneModel model, String id) async {
    await _fadeController.reverse(from: 1.0);
    await model.goTo(id);
    await _fadeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SceneModel>(
      builder: (context, model, _) {
        final scene = model.current;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scene.themeColor.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Panorama background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeController.value,
                      child: child,
                    );
                  },
                  child: scene.isNetwork
                      ? _buildNetworkPanorama(scene)
                      : _buildAssetPanorama(scene),
                ),
              ),

              // Scene info card
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 100,
                child: AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fadeController.value,
                      child: _buildSceneInfoCard(scene),
                    );
                  },
                ),
              ),

              // VR and controls
              Positioned(
                right: 16,
                bottom: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildVRButton(scene),
                    const SizedBox(height: 12),
                    _buildControlsButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSceneInfoCard(Scene scene) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scene.themeColor.withOpacity(0.9),
            scene.themeColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(scene.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  scene.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scene.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVRButton(Scene scene) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scene.themeColor, scene.themeColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scene.themeColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'vr_btn',
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => _openCardboard(scene),
        child: const Icon(Icons.vrpano, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildControlsButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: const Icon(Icons.touch_app, color: Colors.white, size: 20),
    );
  }

  Widget _buildAssetPanorama(Scene scene) {
    return Panorama(
      animSpeed: 1.0,
      hotspots: scene.hotspots.map((h) => _hotspotWidget(h)).toList(),
      child: Image.asset(scene.imageAsset, fit: BoxFit.cover),
    );
  }

  Widget _buildNetworkPanorama(Scene scene) {
    return Panorama(
      animSpeed: 1.0,
      hotspots: scene.hotspots.map((h) => _hotspotWidget(h)).toList(),
      child: Image(
        image: CachedNetworkImageProvider(scene.imageAsset),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(scene.themeColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.error, color: Colors.white, size: 50),
            ),
          );
        },
      ),
    );
  }

  Hotspot _hotspotWidget(SceneHotspot h) {
    return Hotspot(
      latitude: h.latitude,
      longitude: h.longitude,
      width: 100,
      height: 100,
      widget: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final pulseValue = 0.8 + (_pulseController.value * 0.4);

          return Transform.scale(
            scale: pulseValue,
            child: GestureDetector(
              onTap: () {
                final model = Provider.of<SceneModel>(context, listen: false);
                _changeScene(model, h.targetSceneId);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      h.color.withOpacity(0.8),
                      h.color.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: h.color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(h.icon, size: 24, color: h.color),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        h.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCardboard(Scene scene) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CardboardView(scene: scene)));
  }
}

class CardboardView extends StatelessWidget {
  final Scene scene;
  const CardboardView({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: scene.themeColor,
        title: Row(
          children: [
            Icon(Icons.vrpano, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mode VR - ${scene.title}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          Expanded(child: _buildEyeView()),
          Container(width: 2, color: Colors.white),
          Expanded(child: _buildEyeView()),
        ],
      ),
    );
  }

  Widget _buildEyeView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scene.themeColor.withOpacity(0.3), Colors.black],
        ),
      ),
      child: scene.isNetwork
          ? Image(
              image: CachedNetworkImageProvider(scene.imageAsset),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                );
              },
            )
          : Image.asset(scene.imageAsset, fit: BoxFit.cover),
    );
  }
}

class FloorplanSheet extends StatelessWidget {
  const FloorplanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SceneModel>(
      builder: (context, model, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.map, color: model.current.themeColor, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Plan de la maison',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: model.current.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            model.current.icon,
                            size: 16,
                            color: model.current.themeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            model.current.title,
                            style: TextStyle(
                              color: model.current.themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floorplan
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: CustomPaint(painter: FloorplanPainter()),
                      ),

                      // Room markers
                      _buildRoomMarker(context, 'living', 0.3, 0.4),
                      _buildRoomMarker(context, 'kitchen', 0.7, 0.3),
                      _buildRoomMarker(context, 'bedroom', 0.5, 0.7),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomMarker(
    BuildContext context,
    String sceneId,
    double xFactor,
    double yFactor,
  ) {
    return Consumer<SceneModel>(
      builder: (context, model, _) {
        final scene = model.scenes[sceneId]!;
        final isCurrent = model.current.id == sceneId;

        return Positioned(
          left: MediaQuery.of(context).size.width * xFactor - 30,
          top: 200 * yFactor - 30,
          child: GestureDetector(
            onTap: () {
              model.goTo(sceneId);
              Navigator.of(context).pop();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? scene.themeColor : Colors.white,
                border: Border.all(
                  color: scene.themeColor,
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scene.themeColor.withOpacity(0.3),
                    blurRadius: isCurrent ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                scene.icon,
                color: isCurrent ? Colors.white : scene.themeColor,
                size: isCurrent ? 28 : 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloorplanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid
    for (int i = 0; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 0; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw rooms outline
    paint.strokeWidth = 2;
    paint.color = Colors.grey[400]!;

    // Living room
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.4,
        size.height * 0.4,
      ),
      paint,
    );

    // Kitchen
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.55,
        size.height * 0.1,
        size.width * 0.35,
        size.height * 0.4,
      ),
      paint,
    );

    // Bedroom
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.55,
        size.width * 0.6,
        size.height * 0.35,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
