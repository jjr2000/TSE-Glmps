import 'package:flutter/material.dart';
import 'package:spotify_api/spotify_api.dart';
import 'links.dart';
import '../dbProvider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class Library extends StatefulWidget {
  final List<SpotifyAlbum> albums;

  Library({Key key, @required this.albums}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();

}

class _LibraryState extends State<Library> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      body: ListView.builder(
          itemCount: widget.albums.length,
          itemBuilder: (context, index){
            SpotifyAlbum album = widget.albums[index];
            return Padding(

              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                color: Colors.grey[850],
                child: ListTile(
                  onTap: () {
                    DbProvider().getAlbum(album.dbId).then((value){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Links(album: value),
                          )
                      );
                    });
                  },
                  title: Text(album.title,
                      style: TextStyle(
                        color: Colors.white,
                      )

                  ),
                  subtitle: Text(album.artists,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Image.network(album.imageUrl),
                ),
              ),
            );
          }
      ),
    );
  }
}
