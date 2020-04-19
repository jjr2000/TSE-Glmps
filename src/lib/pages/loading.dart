import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_detect/web_detect.dart';
import 'package:spotify_api/spotify_api.dart';

import '../dbProvider.dart';

import 'links.dart';

class WebRequestLoading extends StatefulWidget {
  final String base;

  const WebRequestLoading({Key key, @required this.base}) : super(key: key);

  @override
  _WebRequestLoadingState createState() => _WebRequestLoadingState();
}

class _WebRequestLoadingState extends State<WebRequestLoading> {
  String error = "";

  @override
  void initState() {
    print(widget.base);
    webDetect(widget.base).then((value) {
      if(value.found) {
        searchAlbum(value.result).then((value2) {
          if (value2.found) {
            //we got an album time to add it into our db
            DbProvider().insert(value2).then((value3) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Links(album: value3),
                  )
              );
            });

          } else {
            //Let User know we couldn't find the album
            error = "Album not found";
            Navigator.pop(context);
            _showDialog();
          }
        });
      } else {
        // Tell the user their image was shit and have them retake it.
        error = "Detection error please check lighting and ensure the record is fully visible.";
        Navigator.pop(context);
        _showDialog();
      }
    });
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(error),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Alrighty'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: error == "" ?
        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Text("Fetching the results my dude!",
                style: TextStyle(
                  fontSize: 20,
                    color: Colors.white
                )),
            ),

          ],
        )) :
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(error),
              FlatButton(
                child: Text("Back"),
                onPressed: () {

                },
              )
            ],
          ),
        )
    );
  }
}