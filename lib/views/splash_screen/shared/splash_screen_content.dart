import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/auth_session.dart';

class SplashScreenPageContent extends StatefulWidget {
  const SplashScreenPageContent({super.key});

  @override
  State<SplashScreenPageContent> createState() =>
      _SplashScreenPageContentState();
}

class _SplashScreenPageContentState extends State<SplashScreenPageContent>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_animationController);

    _controller =
        VideoPlayerController.asset(
            'assets/splash-.mp4',
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..setLooping(false)
          ..setVolume(1.0);

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      if (!mounted) return;

      setState(() {});
      await _controller.play();
      _animationController.forward();
      _controller.addListener(_handleVideoState);
    } catch (_) {
      _navigateToLogin();
    }
  }

  void _handleVideoState() {
    if (!mounted || !_controller.value.isInitialized || _hasNavigated) return;

    final duration = _controller.value.duration;
    final position = _controller.value.position;

    if (duration > Duration.zero && position >= duration) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (!mounted) return;
    final session = Get.find<AuthSession>();
    if (session.isAuthenticated) {
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {'token': session.token.value},
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoState);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = (size.width < size.height)
        ? size.width * 0.82
        : size.height * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  Color(0xFF04070D),
                  Color(0xFF0A1322),
                  Color(0xFF0C1A35),
                  Color(0xFF0A234E),
                  Color(0xFF02060B),
                ],
                stops: [0.0, 0.28, 0.58, 0.8, 1.0],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0C213F),
                          const Color(0xFF0A1C35),
                          const Color(0xFF050B14),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2A6BFF,
                          ).withValues(alpha: 0.22),
                          blurRadius: 80,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: ClipOval(
                        child: Container(
                          color: Colors.black,
                          child: _controller.value.isInitialized
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controller.value.size.width,
                                    height: _controller.value.size.height,
                                    child: VideoPlayer(_controller),
                                  ),
                                )
                              : const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
