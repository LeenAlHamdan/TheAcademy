import 'package:flutter/material.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  //final animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Scaffold(
      body: SafeArea(
        child: CustomPaint(
          painter: ScreenBackgoundPainter(),
          child: Center(
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/images/logo_background.png',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
