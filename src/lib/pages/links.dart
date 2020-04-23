import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_api/spotify_api.dart';

class Links extends StatefulWidget {


  final SpotifyAlbum album;

  Links({Key key, @required this.album}) : super(key: key);

  @override
  _LinksState createState() => _LinksState();
}

RandomColor _randomColor = RandomColor();
Color _color = _randomColor.randomColor();



class _LinksState extends State<Links> {

  Duration _duration = Duration();
  Duration _position = Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  String _playerSongName = '--';
  String _url;

  @override
  void initState() {
    super.initState();
    _color = _randomColor.randomColor(colorBrightness: ColorBrightness.light);
    if(widget.album.tracks.length > 0) {
      _playerSongName = widget.album.tracks[0].title;
      _url = widget.album.tracks[0].previewUrl;
    }
    initPlayer();
  }


  void initPlayer(){
    advancedPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    advancedPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });
  }

  String localFilePath;

  Widget _tab (List<Widget>children){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(1),
          child: Column(
              children: children
                  .map((w) => Container(child: w,padding: EdgeInsets.all(1))).toList()
          ),
        ),
      ],
    );
  }

  Widget slider(){
    return Slider(
      activeColor: Colors.white,
      inactiveColor: Colors.black,
      value: _position.inSeconds.toDouble(),
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      onChanged: (double value){
        setState(() {
          seekToSecond(value.toInt());
          value = value;
        });
      },
    );
  }

  int _widgetIndex = 0;


  Widget localAudio(){
    return _tab([
      Center(
        child: Column(
          children: <Widget>[
            IndexedStack(
              index: _widgetIndex,
              children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: (){
                    advancedPlayer.play(_url);
                    setState(
                            () => _widgetIndex = 1);
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: (){
                    advancedPlayer.pause();
                    setState(
                            () => _widgetIndex = 0);
                  },
                ),
              ],
            ),
            slider(),
            SizedBox(height: 10,),
            Text(_playerSongName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
          ],
        ),
      ),

    ]);
  }

  void seekToSecond(int second){
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
  }

  final player = AudioCache();

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
    else {
      throw 'could not open';
    }
  }

  Future<bool> _onBackPressed() async
  => await advancedPlayer.stop() == 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: TabBarView(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: _color,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.network(widget.album.imageUrl,
                                width: 400,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: FittedBox(
                                child: Center(
                                  child: Text(widget.album.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                ),
                              ),
                            ),

                            SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(widget.album.artists,
                                textAlign: TextAlign.center,
                                style: TextStyle(

                                  fontSize: 15,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),),
                            ),
                            SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: widget.album.id == null,
                      child: FlatButton(
                        onPressed: () {
                          _launchUrl('https://open.spotify.com/album/${widget.album.id}');
                        },
                        color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20,0,20,0),
                          child: Text('Open In Spotify',
                            style: TextStyle(color: Colors.white),),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18),
                          side: BorderSide(color: Colors.green[600]),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: _url == null,
                      child: localAudio()
                    ),
                    Offstage(
                        offstage: _url != null,
                        child: Text('No preview available.',
                            style: TextStyle(color: Colors.white,
                            )
                        )
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(
                        height: 5,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 350,
                      child: ListView.builder(
                        itemCount: widget.album.tracks.length,
                        itemBuilder: (context, index){
                          SpotifyTrack track = widget.album.tracks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: .0),
                            child: Card(
                              color: Colors.grey[850],
                              child: ListTile(
                                onTap: () {
                                  advancedPlayer.stop();
                                  setState(() => _playerSongName = track.title);
                                  if(track.previewUrl != null)
                                    advancedPlayer.play(track.previewUrl);
                                  setState(() => _widgetIndex = 1);
                                  setState(() => _url = track.previewUrl);
                                },
                                title: Text(track.title,
                                style: TextStyle(color: Colors.white,
                                ),),
                                leading: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('${index+1}:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}