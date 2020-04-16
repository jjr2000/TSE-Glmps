import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class About extends StatefulWidget {


  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {

  void _launchUrl(String Url) async {
    if (await canLaunch(Url)) {
      await launch(Url);
    }
    else {
      throw 'could not open';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Text('testingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtestingtesting',
                style: TextStyle(color: Colors.white),),
              ),
            ),
            Container(
              child: FlatButton(
                child: Text('web',
                  style: (TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline)),),
                onPressed: () {
                  _launchUrl('http://51.75.162.158:5000/');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
