import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uipage/pages/confirm.dart';
import 'package:uipage/pages/home.dart';
import 'package:uipage/pages/loading.dart';
import 'package:uipage/pages/library.dart';
import 'package:uipage/pages/links.dart';

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
          '/confirm': (context) => Confirm(),
        },
      )
  );
}