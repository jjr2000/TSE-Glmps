library spotify_api;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async{
  SpotifyAlbum album = new SpotifyAlbum.withSearchTerm('Everywhere is somewhere');
  print(await SpotifyAPI()._searchForAlbumId(album));

  if(album.found)
    await SpotifyAPI()._searchForAlbum(album);

  print(album);
}

/// Spotify integration.
class SpotifyAPI {
  /// Spotify endpoints and keys.
  String _accountsApiUrl = 'https://accounts.spotify.com/api/',
      _apiUrl = 'https://api.spotify.com/v1/',
      _accessToken,
      _clientId = '78a66d01fd95418a889fc7357bfed056',
      _clientSecret = '0a24f2c53a68463985038c7570a633d5';

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
        print('I Got A 200');
        print('The response body was:');
        print(response.body);
        Map<String, dynamic> decoded = json.decode(response.body);
        _accessToken = decoded['access_token'];
        print(_accessToken);
        _accessTokenExpires = DateTime.now().add(new Duration(seconds: decoded['expires_in']));
        print(_accessTokenExpires);
        success = true;
      } else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    } catch(error){
      print('An error occured');
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
        print('I Got A 200');
        print('The response body was:');
        print(response.body);
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
      print('An error occured');
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
        print('I Got A 200');
        print('The response body was:');
        print(response.body);
        Map<String, dynamic> decoded = json.decode(response.body);
        success = true;
        album.artist = '';
        for(int i = 0; i < decoded['artists']; )
          album.artist += '${decoded['artists'][i]['name']}${++i < decoded['artists']?', ':''}';

        album.title = decoded['name'];
      } else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    } catch(error){
      print('An error occured');
      print(error.toString());
    }
    return success;
  }

  String getReadableReleaseDate(SpotifyAlbum album)
  {
    String output;
    if(album.found)
    {
      switch(album.releaseDatePrecision){
        case('day'):
          output = "${album.releaseDate.day}-${album.releaseDate.month}-${album.releaseDate.year}";
          break;
        case('month'):
          output = "${album.releaseDate.month}-${album.releaseDate.year}";
          break;
        case('year'):
          output = "${album.releaseDate.year}";
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
        found = false;

  SpotifyAlbum.withSearchTerm(String searchTerm):
        found = false,
        searchTerm = searchTerm;

  String searchTerm;
  bool found;
  String id;
  String artist, title;
  String imageUrl;
  DateTime releaseDate;
  String releaseDatePrecision;
  List<SpotifyTrack> tracks;

}

class SpotifyTrack
{
  String title;
  Duration length;
  String previewUrl;
}
