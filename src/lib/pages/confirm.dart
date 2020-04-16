import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_detect/web_detect.dart';
import 'package:spotify_api/spotify_api.dart';

import 'library.dart';

class Confirm extends StatefulWidget {
  final File image;

  const Confirm({Key key, @required this.image}) : super(key: key);

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  @override
  void initState() {
    print(widget.image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                    child: Image.file(
                      widget.image,
                      fit: BoxFit.fitWidth,
                    )
                ),
              ],
            ),
            Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30.0, left: 10.0),
                  child: IconButton(
                    iconSize: 30.0,
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.check),
        onPressed: () {
          List<int> imageBytes = widget.image.readAsBytesSync();
          // Decode data for processing
          img.Image image = img.decodeImage(imageBytes);
          // Rescale image
          img.Image resized = img.copyResize(image, width: 381);
          // Encode image data into jpg represented as a base65 url safe string
          String base = base64Encode(img.encodeJpg(resized));

          // THE WEB CALLS!!! Show some loading screen while these are running
          webDetect(base).then((value) {
            if(value.found) {
              searchAlbum(value.result).then((value2) {
                if (value2.found) {
                  //we got an album BOIS do what you want with the data from here
                  // Pass on to next widget here
                  Navigator.pushNamed(context, '/library');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Library(),
                      )
                  );
                } else {
                  //Let User know we couldn't find the album
                }
              });
            } else {
              // Tell the user their image was shit and have them retake it.
            }
          });

        },
      ),
    );
  }
}
