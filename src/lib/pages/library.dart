import 'package:flutter/material.dart';
import  'Albums.dart';
import 'links.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'links.dart';

class Library extends StatefulWidget {

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {

  List<Album> albums = [
    Album(artist: 'mr myehlla', title: 'crashing', art:'https://buffer.com/library/wp-content/uploads/2016/06/giphy.gif'),
    Album(artist: 'mr carz', title: 'sadd', art:'https://cdn.pastemagazine.com/www/articles/2019/11/25/acidrapp.jpg'),
    Album(artist: 'yrtu', title: 'imfill', art:'https://images.complex.com/images/fl_lossy,q_auto/hkcs9pgcxaubh9e9sc4c/tyler-the-creator-igor-cover'),
    Album(artist: 'mr myehlla', title: 'crashing', art:'https://i.pinimg.com/originals/b4/75/00/b4750046d94fed05d00dd849aa5f0ab7.jpg'),
    Album(artist: 'mr carz', title: 'sadd', art:'https://cdn.pastemagazine.com/www/articles/2019/11/25/acidrapp.jpg'),
    Album(artist: 'yrtu', title: 'imfill', art:'https://images.complex.com/images/fl_lossy,q_auto/hkcs9pgcxaubh9e9sc4c/tyler-the-creator-igor-cover'),
    Album(artist: 'mr myehlla', title: 'crashing', art:'https://i.pinimg.com/originals/b4/75/00/b4750046d94fed05d00dd849aa5f0ab7.jpg'),
    Album(artist: 'mr carz', title: 'sadd', art:'https://cdn.pastemagazine.com/www/articles/2019/11/25/acidrapp.jpg'),
    Album(artist: 'yrtu', title: 'imfill', art:'https://images.complex.com/images/fl_lossy,q_auto/hkcs9pgcxaubh9e9sc4c/tyler-the-creator-igor-cover'),
    Album(artist: 'mr myehlla', title: 'crashing', art:'https://i.pinimg.com/originals/b4/75/00/b4750046d94fed05d00dd849aa5f0ab7.jpg'),
    Album(artist: 'mr carz', title: 'sadd', art:'https://cdn.pastemagazine.com/www/articles/2019/11/25/acidrapp.jpg'),
    Album(artist: 'yrtu', title: 'imfill', art:'https://images.complex.com/images/fl_lossy,q_auto/hkcs9pgcxaubh9e9sc4c/tyler-the-creator-igor-cover'),
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
                    Navigator.pushNamed(context, '/links');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Links(art: albums[index].art, title: albums[index].title, artist: albums[index].artist),
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
