import 'package:flutter/material.dart';
import 'package:qr_scanner/ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // tunggu 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      //perpindahan aplikasi
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.indigo, // background splash screen warna indigo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // menyusun widget di tengah
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_rounded, // logo
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 10), // jarak antara ikon dan teks
            Text(
              'Q-NER', // judul aplikasi
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}