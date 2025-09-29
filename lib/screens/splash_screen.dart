import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation after delay
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();

    // Start particle animation
    _particleController.repeat();

    // Navigate after animations complete
    await Future.delayed(const Duration(milliseconds: 4000));
    if (mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.completeFirstLaunch();

      if (appProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF4CAF50),
              Color(0xFF00BCD4),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            _buildParticlesBackground(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with advanced animation
                  _buildAnimatedLogo(),

                  const SizedBox(height: 40),

                  // App title with typewriter effect
                  _buildAnimatedTitle(),

                  const SizedBox(height: 16),

                  // Subtitle with fade in
                  _buildAnimatedSubtitle(),

                  const SizedBox(height: 60),

                  // Progress indicator with custom animation
                  _buildAnimatedProgress(),

                  const SizedBox(height: 20),

                  // Loading text
                  _buildLoadingText(),
                ],
              ),
            ),

            // Floating elements
            _buildFloatingElements(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticlesBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final offset = Offset(
              (index * 50.0) % MediaQuery.of(context).size.width,
              (index * 80.0 + _particleController.value * 200) %
                  MediaQuery.of(context).size.height,
            );

            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Container(
                width: 4 + (index % 3) * 2,
                height: 4 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_logoController.value * 0.5),
          child: Transform.rotate(
            angle: _logoController.value * 0.5,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF0F0F0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heart icon with pulse animation
                    const Icon(
                      Icons.favorite,
                      size: 40,
                      color: AppTheme.primaryColor,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: 1000.ms,
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: 1000.ms,
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(0.8, 0.8),
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 8),

                    // Fitness icon
                    const Icon(
                      Icons.fitness_center,
                      size: 24,
                      color: AppTheme.secondaryColor,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 1000.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _textController.value)),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
              ).createShader(bounds),
              child: const Text(
                'MoFit',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Text(
          appProvider.getString('app_subtitle'),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
        )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 1000.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildAnimatedProgress() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 200 * _progressController.value,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFE3F2FD)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progressController.value * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Text(
          appProvider.getString('loading'),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 16,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1000.ms)
            .then()
            .fadeOut(duration: 1000.ms);
      },
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Top left floating element
        Positioned(
          top: 100,
          left: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 3000.ms,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 3000.ms,
                begin: const Offset(1.2, 1.2),
                end: const Offset(0.8, 0.8),
                curve: Curves.easeInOut,
              ),
        ),

        // Top right floating element
        Positioned(
          top: 150,
          right: 50,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 2500.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.3, 1.3),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 2500.ms,
                begin: const Offset(1.3, 1.3),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeInOut,
              ),
        ),

        // Bottom left floating element
        Positioned(
          bottom: 200,
          left: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(40),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 4000.ms,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 4000.ms,
                begin: const Offset(1.1, 1.1),
                end: const Offset(0.9, 0.9),
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }
}
