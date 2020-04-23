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

  void _doSearch(String base) async {
    WebDetect term = await webDetect(widget.base);
    if (term.found) {
      print(term.result);
      bool retry = true;
      while (retry) {
        SpotifyAlbum album = await searchAlbum(term.result);
        print(album);
        if (album.found) {
          retry = false;
          //we got an album time to add it into our db
          album = await DbProvider().insert(album);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Links(album: album),
              ));
        } else {
          if (term.result.contains('vinyl') ||
              term.result.contains('record') ||
              term.result.contains('cd') ||
              term.result.contains('lp') ||
              term.result.contains('ep') ||
              term.result.contains('poster') ||
              term.result.contains('album') ||
              term.result.contains('cover') ||
              term.result.contains('itunes') ||
              term.result.contains('spotify') ||
              term.result.contains('amazon') ||
              term.result.contains('outfit')) {
            term.result = term.result
                .replaceAll('vinyl', '')
                .replaceAll('record', '')
                .replaceAll('cd', '')
                .replaceAll('lp', '')
                .replaceAll('ep', '')
                .replaceAll('poster', '')
                .replaceAll('album', '')
                .replaceAll('cover', '')
                .replaceAll('itunes', '')
                .replaceAll('spotify', '')
                .replaceAll('amazon', '')
                .replaceAll('outfit', '');
          } else {
            retry = false;
            //Let User know we couldn't find the album
            error = "Album not found";
            Navigator.pop(context);
            _showDialog();
          }
        }
      }
    } else {
      // Tell the user their image was shit and have them retake it.
      error =
          "Detection error please check lighting and ensure the record is fully visible.";
      Navigator.pop(context);
      _showDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    _doSearch(widget.base);
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Oops!',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  error,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
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
        body: error == ""
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Text("Fetching the results my dude!",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ],
              ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(error),
                    FlatButton(
                      child: Text("Back"),
                      onPressed: () {},
                    )
                  ],
                ),
              ));
  }
}
