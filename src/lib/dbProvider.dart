import 'package:path/path.dart';
import 'package:spotify_api/spotify_api.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbProvider {
  Database db;

  Future<String> _getPath() async
  {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'glmps.db');
    return path;
  }

  Future open() async {
    String path = await _getPath();
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table album ( 
  dbId integer primary key autoincrement, 
  id text not null,
  artists text not null,
  title text not null,
  imageUrl text not null,
  releaseDatePrecision text not null,
  releaseDate text not null)
''');
          await db.execute('''
create table track ( 
  title text not null,
  previewUrl text null,
  length int not null,
  dbAlbumId int not null)
''');
        });
  }

  Future<SpotifyAlbum> insert(SpotifyAlbum album) async {
    await open();

    album.dbId = await db.insert('album', album.toMap());
    var batch = db.batch();
    for(int i = 0; i < album.tracks.length; i++) {
      SpotifyTrack track = album.tracks[i];
      track.dbAlbumId = album.dbId;
      batch.insert('track', track.toMap());
    }
    await batch.commit();

    db.close();

    return album;
  }

  Future<SpotifyAlbum> getAlbum(int dbId) async {
    await open();

    List<Map> albums = await db.query('album',
        columns: ['id', 'artists', 'title', 'imageUrl', 'releaseDatePrecision', 'releaseDate', 'dbId'],
        where: 'dbId = ?',
        whereArgs: [dbId]);
    if (albums.length > 0) {
      SpotifyAlbum album = SpotifyAlbum.fromMap(albums.first);
      List<Map> tracks = await db.query('track',
          columns: ['title', 'previewUrl', 'length', 'dbAlbumId'],
          where: 'dbAlbumId = ?',
          whereArgs: [album.dbId]);
      for (int i = 0; i < tracks.length; i++) {
        album.tracks.add(SpotifyTrack.fromMap(tracks[i]));
      }
      db.close();
      return album;
    }
    db.close();
    return null;
  }

  Future<int> delete(int dbId) async {
    await open();
    int recordsDeleted = 0;
    recordsDeleted += await db.delete('album', where: 'dbId = ?', whereArgs: [dbId]);
    recordsDeleted += await db.delete('track', where: 'dbAlbumId = ?', whereArgs: [dbId]);
    db.close();
    return recordsDeleted;
  }

}