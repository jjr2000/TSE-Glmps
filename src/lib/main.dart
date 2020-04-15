import 'package:flutter/material.dart';
import 'package:uipage/pages/home.dart';
import 'package:uipage/pages/loading.dart';
import 'package:uipage/pages/library.dart';
import 'package:uipage/pages/links.dart';


void main() => runApp(MaterialApp(
  initialRoute: '/loading',
  routes: {
    '/loading': (context) => Loading(),
    '/home': (context) => Home(),
    '/library': (context) => Library(),
    '/links': (context) => Links(),
  },
));