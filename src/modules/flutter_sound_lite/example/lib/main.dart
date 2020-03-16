import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  String _playerTxt = '00:00:00';

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setVolume(1);
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startPlayer() async{
    try {
      String path = 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/06/73/aa/0673aa28-3b94-6d16-de5f-e3de7d4c8fc3/mzaf_3097933090202335091.plus.aac.p.m4a';
      path = await flutterSound.startPlayer(path); // From file
       print('startPlayer: $path');

      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          sliderCurrentPosition = e.currentPosition;
          maxDuration = e.duration;


          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
          this.setState(() {
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
    setState(() {} );
  }

  void stopPlayer() async{
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
      } catch (err) {
      print('error: $err');
    }
    this.setState(() {
      //this._isPlaying = false;
    });

  }

  onStartPlayerPressed() {
        return  flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED ? startPlayer : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sound'),
        ),
        body: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 12.0, bottom:16.0),
                  child: Text(
                    this._playerTxt,
                    style: TextStyle(
                      fontSize: 35.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 50.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: onStartPlayerPressed(),
                      disabledColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage(onStartPlayerPressed() != null ? 'res/icons/ic_play.png' : 'res/icons/ic_stop.png'),
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Container(
              height: 30.0,
              child: Slider(
                value: sliderCurrentPosition,
                min: 0.0,
                max: maxDuration,
//                onChanged: (double value) async{
//                  await flutterSound.seekToPlayer(value.toInt());
//                },
                divisions: maxDuration.toInt()
              )
            ),
           ],
        ),
      ),
    );
  }
}
