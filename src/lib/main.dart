import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'pages/landing.dart';
import 'pages/about.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(
      MaterialApp(
        initialRoute: '/landing',
        routes: {
          '/landing': (context) => Landing(),
          '/home': (context) => Home(initCameras: cameras),
          '/about': (context) => About()
        },
      )
  );
}