import 'package:flutter/material.dart';
import 'links.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();

}

class Album {
  //artist name
  String artist;
  //title of album
  String title;
  //cover art (as a link)
  String art;
  //song link
  String song;
  //Song name
  String songName;
  //link to the spotify artist / album page
  String spotifyLink;

  Album({this.artist, this.title, this.art, this.song, this.songName, this.spotifyLink});
}

class _LibraryState extends State<Library> {

  List<Album> albums = [
    Album(artist: 'Tame Impala', title: 'Lonerism', art:'https://images-na.ssl-images-amazon.com/images/I/81J5ArW6voL._SL1200_.jpg', song: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/06/73/aa/0673aa28-3b94-6d16-de5f-e3de7d4c8fc3/mzaf_3097933090202335091.plus.aac.p.m4a', songName: 'Feels Like We Only Go Backwards', spotifyLink: 'https://open.spotify.com/album/3C2MFZ2iHotUQOSBzdSvM7'),
    Album(artist: 'Nouns', title: 'Still Bummed', art:'https://e.snmc.io/i/600/w/a11daacb49cd4a8ddfa6dd8ba830e1e4/7478084', song: 'https://luan.xyz/files/audio/ambient_c_motion.mp3', songName: 'Dogs', spotifyLink: 'https://open.spotify.com/album/0TmbsFrbOcvrBXLZkVGRru'),
    Album(artist: 'Jack Stauber', title: 'HiLo', art:'https://i.redd.it/58u56d6mkki21.jpg', song: 'test2.mp3', songName: 'Dead Weight', spotifyLink: 'https://open.spotify.com/album/4RsjXMHyCUigESP74GkNHB'),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      body: ListView.builder(
          itemCount: albums.length,
          itemBuilder: (context, index){
            return Padding(

              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                color: Colors.grey[850],
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Links(art: albums[index].art, title: albums[index].title, artist: albums[index].artist, song: albums[index].song, songName: albums[index].songName,  spotifyLink: albums[index].spotifyLink,),
                        )
                    );
                  },
                  title: Text(albums[index].title,
                      style: TextStyle(
                        color: Colors.white,
                      )

                  ),
                  subtitle: Text(albums[index].artist,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Image.network(albums[index].art),
                ),
              ),
            );
          }
      ),
    );
  }
}
