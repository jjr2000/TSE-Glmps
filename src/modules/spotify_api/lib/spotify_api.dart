library spotify_api;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() async{
  SpotifyAlbum album = await SpotifyAPI().search('Everywhere is somewhere');
  if(album.found) {
    print(SpotifyAPI().getReadableReleaseDate(album));
  }else{
    print('${album.searchTerm} not found');
  }
  album = await SpotifyAPI().search('Everlong');
  if(album.found) {
    print(SpotifyAPI().getReadableReleaseDate(album));
  }else{
    print('${album.searchTerm} not found');
  }
  album = await SpotifyAPI().search('Invaders Must Die');
  if(album.found) {
    print(SpotifyAPI().getReadableReleaseDate(album));
  }else{
    print('${album.searchTerm} not found');
  }
  album = await SpotifyAPI().search('Nevermind');
  if(album.found) {
    print(SpotifyAPI().getReadableReleaseDate(album));
  }else{
    print('${album.searchTerm} not found');
  }
}

/// Spotify integration.
class SpotifyAPI {
  /// Spotify endpoints and keys.
  String _accountsApiUrl = 'https://accounts.spotify.com/api/',
      _apiUrl = 'https://api.spotify.com/v1/',
      _accessToken,
      _clientId = '78a66d01fd95418a889fc7357bfed056',
      _clientSecret = '0a24f2c53a68463985038c7570a633d5';
// ToDo: Place into config file

  DateTime _accessTokenExpires;

  ///Gets an auth token for all communication with Spotify.
  Future<bool> _getClientCredentials() async
  {
    bool success = false;
    try {
      var response = await http.post(
          _accountsApiUrl + 'token',
          headers: {
            'Authorization': 'Basic ' +
                base64.encode(utf8.encode(_clientId + ':' + _clientSecret))
          },
          body: {
            'grant_type': 'client_credentials'
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        _accessToken = decoded['access_token'];
        _accessTokenExpires = DateTime.now().add(new Duration(seconds: decoded['expires_in']));
        success = true;
      } else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    } catch(error){
      print('An error occured 1');
      print(error.toString());
    }
    return success;
  }

  Future<bool> _searchForAlbumId(SpotifyAlbum album) async
  {
    bool success = false;
    try{
      if((_accessToken != null ? _accessToken.isEmpty : true) || (_accessTokenExpires != null ? _accessTokenExpires.isAfter(DateTime.now()) : true))
        if(!await _getClientCredentials())
          throw Stream.error("Failed to get cradentials");

      var response = await http.get(Uri.encodeFull(
          _apiUrl
              + 'search?q=' + album.searchTerm
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
        if(decodedAlbum != null)
        {
          album.found = true;
          album.id = decodedAlbum['id'];
        }
      } else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    } catch(error){
      print('An error occured 2');
      print(error.toString());
    }
    return success;
  }

  Future<bool> _searchForAlbum(SpotifyAlbum album) async
  {
    bool success = false;
    try{
      if((_accessToken != null ? _accessToken.isEmpty : true) || (_accessTokenExpires != null ? _accessTokenExpires.isAfter(DateTime.now()) : true))
        if(!await _getClientCredentials())
          throw Stream.error("Failed to get cradentials");

      var response = await http.get(Uri.encodeFull(
          _apiUrl
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
        for(int i = 0; i < artists.length; )
          album.artists += '${artists[i]['name']}${++i < artists.length?', ':''}';

        album.title = decoded['name'];
        album.imageUrl = decoded['images'][0]['url'];
        album.releaseDatePrecision = decoded['release_date_precision'];
        switch(album.releaseDatePrecision){
          case('day'):
            album.releaseDate = DateFormat('yyyy-MM-dd').parse(decoded['release_date']);
            break;
          case('month'):
            album.releaseDate = DateFormat('yyyy-MM').parse(decoded['release_date']);
            break;
          case('year'):
            album.releaseDate = DateFormat('yyyy').parse(decoded['release_date']);
            break;
          default:
            album.releaseDate = null;
            break;
        }
        album.tracks.clear();
        List<dynamic> tracks = decoded['tracks']['items'];
        for(int i = 0; i < tracks.length; i++)
          album.tracks.add(new SpotifyTrack(tracks[i]['name'], tracks[i]['preview_url'], Duration(milliseconds: tracks[i]['duration_ms'])));


      } else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    } catch(error){
      print('An error occured 3');
      print(error.toString());
    }
    return success;
  }

  Future<SpotifyAlbum> search(String searchTerm) async
  {
      SpotifyAlbum album = new SpotifyAlbum.withSearchTerm(searchTerm);
      await SpotifyAPI()._searchForAlbumId(album);
      if(album.found) {
        await SpotifyAPI()._searchForAlbum(album);
      }
      return album;
  }

  String getReadableReleaseDate(SpotifyAlbum album)
  {
    String output;
    if(album.found)
    {
      switch(album.releaseDatePrecision){
        case('day'):
          output = DateFormat.yMMMMd().format(album.releaseDate);
          break;
        case('month'):
          output = DateFormat.yMMMM().format(album.releaseDate);
          break;
        case('year'):
          output = DateFormat.y().format(album.releaseDate);
          break;
        default:
          output = 'Unknown Date Format';
          break;
      }
    }

    return output;
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
