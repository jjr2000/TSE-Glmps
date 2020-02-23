import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: Text("Glymps"),
      centerTitle: true,
      backgroundColor: Colors.blueGrey[900],
    ),
    body: Center(
      child: Text("Camera stuff goes here")
    ),
    floatingActionButton: Ink(
      padding: EdgeInsets.all(10.0),
      decoration: const ShapeDecoration(
          shape: CircleBorder(),
          color: Colors.blueGrey

      ),
      child: IconButton(
        onPressed: () {

        },
        icon: Icon(Icons.search),
        color: Colors.white,
      ),
    ),


  ),
  title: "Glymps"
));