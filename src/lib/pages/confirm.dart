import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'library.dart';

class Confirm extends StatefulWidget {
  final File image;

  const Confirm({Key key, this.image}) : super(key: key);
  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Stack(
        children: <Widget>[
          Expanded(
            child: Image.file(widget.image),
          ),
          Flex(
            children: <Widget>[

            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<int> imageBytes = widget.image.readAsBytesSync();
          // Decode data for processing
          img.Image image = img.decodeImage(imageBytes);
          // Rescale image
          img.Image resized = img.copyResize(image, width: 381);
          // Encode image data into jpg represented as a base65 url safe string
          String base = base64UrlEncode(img.encodeJpg(resized));
          // Pass on to next widget here
          Navigator.pushNamed(context, '/library');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Library(),
              )
          );
        },
      ),
    );
  }
}
