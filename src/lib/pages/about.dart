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

  String _description = (
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Cras adipiscing enim eu turpis egestas. Malesuada fames ac turpis egestas. Ullamcorper eget nulla facilisi etiam dignissim. Et malesuada fames ac turpis egestas maecenas. Metus dictum at tempor commodo ullamcorper a lacus. Laoreet id donec ultrices tincidunt arcu non sodales. A cras semper auctor neque vitae. Libero enim sed faucibus turpis in eu mi. Dictum sit amet justo donec enim diam. Donec massa sapien faucibus et molestie ac. Faucibus purus in massa tempor nec feugiat. Odio morbi quis commodo odio aenean sed adipiscing. Diam vel quam elementum pulvinar etiam non quam lacus. Risus quis varius quam quisque id diam vel quam elementum.Maecenas sed enim ut sem. Commodo quis imperdiet massa tincidunt nunc. Magna ac placerat vestibulum lectus mauris. Tellus rutrum tellus pellentesque eu tincidunt tortor aliquam. Laoreet id donec ultrices tincidunt arcu non sodales neque sodales. Aliquet enim tortor at auctor urna nunc. Sed blandit libero volutpat sed cras ornare arcu dui. Vel orci porta non pulvinar. Viverra adipiscing at in tellus integer. Pellentesque massa placerat duis ultricies lacus. Egestas purus viverra accumsan in nisl nisi scelerisque eu. Est placerat in egestas erat imperdiet sed. Sit amet tellus cras adipiscing enim eu. Suspendisse sed nisi lacus sed. Lacinia quis vel eros donec ac odio tempor orci. In massa tempor nec feugiat nisl pretium fusce. Consectetur lorem donec massa sapien faucibus et. Sodales ut etiam sit amet nisl purus in mollis nunc.'

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
