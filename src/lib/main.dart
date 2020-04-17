import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
        initialRoute: '/loading',
        routes: {
          '/loading': (context) => Loading(),
          '/home': (context) => Home(cameras: cameras),
          '/library': (context) => Library(),
          '/links': (context) => Links(),
          '/about': (context) => About(),
          '/confirm': (context) => Confirm(),
        },
      )
  );
}