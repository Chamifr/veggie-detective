import 'package:flutter/material.dart';
import 'screens/veggie_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veggie Detective',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MySplashPage(),  // 👈 Show splash first
      debugShowCheckedModeBanner: false,
    );
  }
}

class MySplashPage extends StatefulWidget {
  const MySplashPage({super.key});

  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..addListener(() {
        if (_controller.isCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VeggieHomePage()), // 👈 redirect to your home page
          );
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F8D7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/avocado_load.gif',  // 👈 make sure this is in your pubspec.yaml
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFF98FB98), Color(0xFFD2691E)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
