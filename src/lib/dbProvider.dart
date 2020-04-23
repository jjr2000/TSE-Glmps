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
    db = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table album ( 
  dbId integer primary key autoincrement, 
  id text null,
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
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion == 1) {
            await db.execute('''
PRAGMA foreign_keys=off;

BEGIN TRANSACTION;

ALTER TABLE album RENAME TO _album_old;

create table album ( 
  dbId integer primary key autoincrement, 
  id text null,
  artists text not null,
  title text not null,
  imageUrl text not null,
  releaseDatePrecision text not null,
  releaseDate text not null)

INSERT INTO table1 ('id', 'artists', 'title', 'imageUrl', 'releaseDatePrecision', 'releaseDate', 'dbId')
  SELECT 'id', 'artists', 'title', 'imageUrl', 'releaseDatePrecision', 'releaseDate', 'dbId'
  FROM _album_old;

COMMIT;

PRAGMA foreign_keys=on;
''');
            oldVersion++;
          }
        }
        );
  }

  Future<SpotifyAlbum> insert(SpotifyAlbum album) async {
    await open();

    album.dbId = await db.insert('album', album.toMap());
    var batch = db.batch();
    for(SpotifyTrack track in album.tracks) {
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
      album.tracks = List<SpotifyTrack>();
      for (Map track in tracks) {
        album.tracks.add(SpotifyTrack.fromMap(track));
      }
      db.close();
      return album;
    }
    db.close();
    return null;
  }

  Future<List<SpotifyAlbum>> getAlbums() async {
    await open();
    List<SpotifyAlbum> albums = List<SpotifyAlbum>();

    List<Map> dbAlbums = await db.query('album',
        columns: ['id', 'artists', 'title', 'imageUrl', 'releaseDatePrecision', 'releaseDate', 'dbId']);
      for (Map dbAlbum in dbAlbums) {
        albums.add(SpotifyAlbum.fromMap(dbAlbum));
      }
      db.close();

      return albums;
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