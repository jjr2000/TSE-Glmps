import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uipage/pages/landing.dart';
import 'pages/confirm.dart';
import 'pages/about.dart';
import 'pages/home.dart';
import 'pages/loading.dart';
import 'pages/library.dart';
import 'pages/links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(
      MaterialApp(
        initialRoute: '/landing',
        routes: {
          '/landing': (context) => Landing(),
          '/home': (context) => Home(cameras: cameras),
          '/library': (context) => Library(),
          '/links': (context) => Links(),
          '/about': (context) => About()
        },
      )
  );
}