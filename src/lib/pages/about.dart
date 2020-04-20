import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {


  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
    else {
      throw 'could not open';
    }
  }

  String _description = (
      "GLMPS helps you find new music, you can take a picture of an album cover and quickly preview and find the details of the album. So the next time you go record shopping you'll have the ultimate companion for exploring new music in a blink of an eye.GLMPS uses advanced object detection coupled with Google's cloud vision to find information on the album you want to search, and then allows you to preview the tracks off the album for your convenience. Search results are saved automatically so you will never forget an album! To see developer information please visit us with the link bellow!"
  );

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
                padding: const EdgeInsets.fromLTRB(150,40,150,20),
                child: Image.asset('assets/GLMPS.png'),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(_description,
                style: TextStyle(color: Colors.white),),
              ),
            ),
            Container(
              child: FlatButton(
                child: Text('GLMPS Website',
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
