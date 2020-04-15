import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';

class Links extends StatefulWidget {

  final String art;
  final String title;
  final String artist;
  Links({Key key, @required this.art, this.title, this.artist}) : super(key: key);

  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 50, 50, 10),
                child: Image.network(widget.art),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(widget.artist,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              FlatButton(
                onPressed: () {

                },
                color: Colors.green,
                child: Text('Open In Spotify'),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.green[600]),
                ),
              ),

            ],
          ),
        ),
      )
      );
  }
}
