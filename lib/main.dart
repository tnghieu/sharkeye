import 'package:flutter/material.dart';
import 'package:pytorch_lite/native_wrapper.dart';
import 'package:sharkeye/screens/home.dart';

void main() async {
  await PytorchFfi.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D2633),
        ),
        useMaterial3: true,
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
