import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinaka_pos/Screens/Auth/store_id_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay to show splash screen for a few seconds and then navigate to LoginScreen
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const StoreIdScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.2, 0.0); // Start from the right (off-screen)
            const end = Offset.zero; // End at the center
            const curve = Curves.easeInOut; // Smooth transition curve
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(seconds: 1), // Duration of the slide animation
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2745), // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0), // Opacity animation
              duration: const Duration(seconds: 2),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity, // Fade in the logo
                  child: SvgPicture.asset(
                    'assets/svg/app_logo.svg', // Path to your SVG logo
                    height: 150, // Adjust the size of the logo
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}