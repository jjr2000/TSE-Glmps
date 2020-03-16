library spotify_api;

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

void main()
{}

class SpotifyApi {

  YamlMap _config = loadYaml(File('config.yaml').readAsStringSync());
  /// Spotify access token after gathering.
  String _accessToken;
  DateTime _accessTokenExpires;

  ///Gets an auth token for all communication with Spotify.
  Future<bool> _getClientCredentials() async
  {
    bool success = false;
    try {
      var response = await http.post(
          _config['accountsApiUrl'] + 'token',
          headers: {
            'Authorization': 'Basic ' +
                base64.encode(
                    utf8.encode(_config['clientId'] + ':' + _config['clientSecret']))
          },
          body: {
            'grant_type': 'client_credentials'
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        _accessToken = decoded['access_token'];
        _accessTokenExpires =
            DateTime.now().add(new Duration(seconds: decoded['expires_in']));
        success = true;
      } else {
        print('something went wrong, status code: ' +
            response.statusCode.toString());
      }
    } catch (error) {
      print('An error occured 1');
      print(error.toString());
    }
    return success;
  }

  Future<bool> _searchForAlbumId(SpotifyAlbum album) async
  {
    bool success = false;
    try {
      if ((_accessToken != null ? _accessToken.isEmpty : true) ||
          (_accessTokenExpires != null ? _accessTokenExpires.isAfter(
              DateTime.now()) : true))
        if (!await _getClientCredentials())
          throw Stream.error("Failed to get cradentials");

      var response = await http.get(Uri.parse(
          _config['apiUrl']
              + 'search?q=' + Uri.encodeComponent(album.searchTerm)
              + "&type=album&market=GB")
          ,
          headers: {
            'Authorization': 'Bearer ' + _accessToken
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        success = true;
        Map<String, dynamic> decodedAlbum = decoded['albums']['items'][0];
        if (decodedAlbum != null) {
          album.found = true;
          album.id = decodedAlbum['id'];
        }
      } else {
        print('something went wrong, status code: ' +
            response.statusCode.toString());
      }
    } catch (error) {
      print('An error occured 2');
      print(error.toString());
    }
    return success;
  }

  Future<bool> _searchForAlbum(SpotifyAlbum album) async
  {
    bool success = false;
    try {
      if ((_accessToken != null ? _accessToken.isEmpty : true) ||
          (_accessTokenExpires != null ? _accessTokenExpires.isAfter(
              DateTime.now()) : true))
        if (!await _getClientCredentials())
          throw Stream.error("Failed to get cradentials");

      var response = await http.get(Uri.encodeFull(
          _config['apiUrl']
              + 'albums/' + album.id
              + "?market=GB")
          ,
          headers: {
            'Authorization': 'Bearer ' + _accessToken
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        success = true;

        album.artists = '';
        List<dynamic> artists = decoded['artists'];
        for (int i = 0; i < artists.length;)
          album.artists +=
          '${artists[i]['name']}${++i < artists.length ? ', ' : ''}';

        album.title = decoded['name'];
        album.imageUrl = decoded['images'][0]['url'];
        album.releaseDatePrecision = decoded['release_date_precision'];
        switch (album.releaseDatePrecision) {
          case('day'):
            album.releaseDate =
                DateFormat('yyyy-MM-dd').parse(decoded['release_date']);
            break;
          case('month'):
            album.releaseDate =
                DateFormat('yyyy-MM').parse(decoded['release_date']);
            break;
          case('year'):
            album.releaseDate =
                DateFormat('yyyy').parse(decoded['release_date']);
            break;
          default:
            album.releaseDate = null;
            break;
        }
        album.tracks.clear();
        List<dynamic> tracks = decoded['tracks']['items'];
        for (int i = 0; i < tracks.length; i++) {
          String previewUrl = tracks[i]['preview_url'];
          if(previewUrl?.isEmpty ?? true)
          {
            Uri itunesUri = Uri.parse(
                _config['itunesUrl']
                    + '/search?term=' + Uri.encodeComponent(tracks[i]['name'] + ', ' + album.artists)
                    + "&limit=1&country=GB&entity=song");
            var itunesResponse = await http.get(itunesUri);

            if (itunesResponse.statusCode == 200) {
              Map<String, dynamic> itunesDecoded = json.decode(itunesResponse.body);
              if(itunesDecoded['resultCount'] == 1)
                previewUrl = itunesDecoded['results'][0]['previewUrl'];
            }
          }
          album.tracks.add(new SpotifyTrack(
              tracks[i]['name'], previewUrl,
              Duration(milliseconds: tracks[i]['duration_ms'])));
        }
      } else {
        print('something went wrong, status code: ' +
            response.statusCode.toString());
      }
    } catch (error) {
      print('An error occured 3');
      print(error.toString());
    }
    return success;
  }

  Future<SpotifyAlbum> search(String searchTerm) async
  {
    SpotifyAlbum album = new SpotifyAlbum.withSearchTerm(searchTerm);
    await _searchForAlbumId(album);
    if (album.found) {
      await _searchForAlbum(album);
    }
    return album;
  }
}

class SpotifyAlbum
{
  SpotifyAlbum():
        found = false,
        tracks = new List<SpotifyTrack>();

  SpotifyAlbum.withSearchTerm(String searchTerm):
        found = false,
        searchTerm = searchTerm,
        tracks = new List<SpotifyTrack>();

  String getReadableReleaseDate()
  {
    String output;
    if(this.found)
    {
      switch(this.releaseDatePrecision){
        case('day'):
          output = DateFormat.yMMMMd().format(this.releaseDate);
          break;
        case('month'):
          output = DateFormat.yMMMM().format(this.releaseDate);
          break;
        case('year'):
          output = DateFormat.y().format(this.releaseDate);
          break;
        default:
          output = 'Unknown Date Format';
          break;
      }
    }

    return output;
  }

  bool found;
  String searchTerm,
      id,
      artists,
      title,
      imageUrl,
      releaseDatePrecision;
  DateTime releaseDate;
  List<SpotifyTrack> tracks;
}

class SpotifyTrack
{
  SpotifyTrack(String title, String previewUrl, Duration length):
      title = title,
      previewUrl = previewUrl,
      length = length;

  String title,
        previewUrl;
  Duration length;
}
