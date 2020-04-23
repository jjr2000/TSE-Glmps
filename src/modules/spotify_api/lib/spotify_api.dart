library spotify_api;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Spotify access token after gathering.
String _accessToken,
    _clientId = '78a66d01fd95418a889fc7357bfed056',
    _clientSecret = '0a24f2c53a68463985038c7570a633d5',
    _accountsApiUrl = 'https://accounts.spotify.com/api/',
    _apiUrl = 'https://api.spotify.com/v1/',
    _market = 'GB',
    _itunesUrl = 'https://itunes.apple.com';
DateTime _accessTokenExpires;

/// Gets an auth token for all communication with Spotify.
/// Full authorization spec can be found here: https://developer.spotify.com/documentation/general/guides/authorization-guide/
Future<bool> _getClientCredentials() async {
  bool success = false;
  try {
    var response = await http.post(
        '${_accountsApiUrl}token',
        headers: {
          // Encode the Basic Authorization Header
          'Authorization': 'Basic ${base64.encode(utf8.encode(_clientId + ':' + _clientSecret))}'
        },
        body: {
          // This is a server authorization grant type that doesn't require user login.
          'grant_type': 'client_credentials'
        }
    );

    if (response.statusCode == 200) {
      // Decode the json return into a dynamic map so we can access the elements programmatically.
      Map<String, dynamic> decoded = json.decode(response.body);
      _accessToken = decoded['access_token'];
      // Convert the expire time into a real date and time.
      _accessTokenExpires = DateTime.now().add(new Duration(seconds: decoded['expires_in']));
      // If we hit here everything worked so mark the success.
      success = true;
    } else {
      print('something went wrong, status code: ${response.statusCode.toString()}');
    }
  } catch (error) {
    print('An error occured 1');
    print(error.toString());
  }
  return success;
}

Future<bool> _searchForAlbumId(SpotifyAlbum album) async {
  bool success = false;
  try {
    if (
      // Check if we have an access token.
      (_accessToken != null ? _accessToken.isEmpty : true)
          // if we do have one check it hasn't expired.
          || (_accessTokenExpires != null ? DateTime.now().isAfter(_accessTokenExpires) : true)
    )
      // if we don't have a usable token get a new one and make sure the query returns success
      if (!await _getClientCredentials())
        throw Stream.error("Failed to get cradentials");

    print(_accessToken);
    String term = Uri.encodeComponent(album.searchTerm);
    print(term);
    Uri uri = Uri.parse(_apiUrl
        + 'search?'
        + 'q=$term'
        + '&type=album'
        + '&market=$_market'
    );
    print(uri);
    var response = await http.get(
      // unlike with a post, the get function doesn't allow us to send parameters, to get around this we have to build a uri encoded query string.
        uri,
        headers: {
          // the access token we get from spotify is already encoded so no extra work needs to be done.
          'Authorization': 'Bearer $_accessToken'
        }
    );

    if (response.statusCode == 200) {
      // Decode the json return into a dynamic map so we can access the elements programmatically.
      Map<String, dynamic> decoded = json.decode(response.body);
      // Decode the album separately so that if it doesn't exist we can avoid errors
      if(decoded['albums']['items'].length > 0) {
        success = true;
        Map<String, dynamic> decodedAlbum = decoded['albums']['items'][0];
        if (decodedAlbum != null) {
          album.found = true;
          album.id = decodedAlbum['id'];
        }
      }else{
        //Lets give apple a shot
        Uri appleUri = Uri.parse(_itunesUrl
            + '/search?'
            + 'term=$term'
            + '&entity=album'
            + '&media=music'
            + '&limit=1'
            + '&country=$_market'
        );
        var appleResponse = await http.get(appleUri);
        if (appleResponse.statusCode == 200) {
          decoded = json.decode(appleResponse.body);
          if(decoded['resultCount'] > 0) {
            Map<String, dynamic> decodedAlbum = decoded['results'][0];
            success = true;
            album.found = true;
            album._appleTrackCount = decodedAlbum['trackCount'];
            album.artists = decodedAlbum['artistName'];
            album.title = decodedAlbum['collectionName'];
            // The first image is the high resolution one so that's what we'll use
            album.imageUrl = decodedAlbum['artworkUrl100'];
            album.releaseDatePrecision = 'day';
            album.releaseDate = DateFormat('yyyy-MM-dd').parse(decodedAlbum['releaseDate'].toString().substring(0,10));
          }
        }
      }
    } else {
      print('something went wrong, status code: ${response.statusCode.toString()}');
    }
  } catch (error) {
    print('An error occured 2');
    print(error.toString());
  }
  return success;
}

Future<bool> _searchForAlbum(SpotifyAlbum album) async {
  bool success = false;
  try {
    if(album._appleTrackCount != null)
    {
      var itunesResponse = await http.get(
        // unlike with a post, the get function doesn't allow us to send parameters, to get around this we have to build a uri encoded query string.
          Uri.parse(
              '$_itunesUrl/search'
                  + '?term=${Uri.encodeComponent(album.title)}'
                  + '&limit=${album._appleTrackCount}'
                  + '&country=$_market'
                  + '&entity=musicTrack'
                  + '&media=music'
          )
      );

      if (itunesResponse.statusCode == 200) {
        // Decode the json return into a dynamic map so we can access the elements programmatically.
        Map<String, dynamic> decoded = json.decode(itunesResponse.body);
        success = true;
        album.tracks = List<SpotifyTrack>(decoded['resultCount']);

        for(Map<String, dynamic> track in decoded['results'])
        {
          int trackNum = track['trackNumber'] - 1;
          print(trackNum);
          if(album.tracks[trackNum] != null)
            throw Exception('Duplicate Track Parse Failed');

          album.tracks[trackNum] = new SpotifyTrack(track['trackCensoredName'], track['previewUrl'],
              Duration(milliseconds: track['trackTimeMillis']));
        }

      } else {
      print('something went wrong, status code: ${itunesResponse.statusCode
          .toString()}');
    }

    }
    else {
      if (
      // Check if we have an access token.
      (_accessToken != null ? _accessToken.isEmpty : true)
          // if we do have one check it hasn't expired.
          || (_accessTokenExpires != null ? _accessTokenExpires.isAfter(
          DateTime.now()) : true)
      )
        // if we don't have a usable token get a new one and make sure the query returns success
        if (!await _getClientCredentials())
          throw Stream.error("Failed to get cradentials");

      var response = await http.get(
        // unlike with a post, the get function doesn't allow us to send parameters, to get around this we have to build a uri encoded query string.
          Uri.encodeFull(_apiUrl + 'albums/${album.id}'
              + '?market=$_market'
          ),
          headers: {
            // the access token we get from spotify is already encoded so no extra work needs to be done.
            'Authorization': 'Bearer $_accessToken'
          }
      );

      if (response.statusCode == 200) {
        // Decode the json return into a dynamic map so we can access the elements programmatically.
        Map<String, dynamic> decoded = json.decode(response.body);
        success = true;

        //Making sure artists is blank before we loop
        album.artists = '';
        // loop through the artists list
        for (Map<String, dynamic> artist in decoded['artists'])
          // Add the artist name to the string and if it's not the last one also a comma and a space
          album.artists +=
          '${artist['name']}${artist != decoded['artists'].last ? ', ' : ''}';

        album.title = decoded['name'];
        // The first image is the high resolution one so that's what we'll use
        album.imageUrl = decoded['images'][0]['url'];
        album.releaseDatePrecision = decoded['release_date_precision'];
        // Correctly parse the release date into a Date element depending on its precision.
        switch (album.releaseDatePrecision) {
          case ('day'):
            album.releaseDate =
                DateFormat('yyyy-MM-dd').parse(decoded['release_date']);
            break;
          case ('month'):
            album.releaseDate =
                DateFormat('yyyy-MM').parse(decoded['release_date']);
            break;
          case ('year'):
            album.releaseDate =
                DateFormat('yyyy').parse(decoded['release_date']);
            break;
          default:
            album.releaseDate = null;
            break;
        }
        // Make sure the list of tracks is empty before we loop through the returned ones.
        album.tracks.clear();
        for (Map<String, dynamic> track in decoded['tracks']['items']) {
          String previewUrl = track['preview_url'];
          // Spotify isn't great at giving us preview Url's so if it hasn't returned one we'll search apples itunes library of previews instead.
          if (previewUrl?.isEmpty ?? true) {
            var itunesResponse = await http.get(
              // unlike with a post, the get function doesn't allow us to send parameters, to get around this we have to build a uri encoded query string.
                Uri.parse(
                    '$_itunesUrl/search'
                        + '?term=${Uri.encodeComponent(
                        track['name'] + ', ' + album.artists)}'
                        + '&limit=1'
                        + '&country=$_market'
                        + '&entity=musicTrack'
                        + '&media=music'
                )
            );

            if (itunesResponse.statusCode == 200) {
              Map<String, dynamic> itunesDecoded =
              json.decode(itunesResponse.body);
              if (itunesDecoded['resultCount'] == 1)
                previewUrl = itunesDecoded['results'][0]['previewUrl'];
            }
          }
          album.tracks.add(new SpotifyTrack(track['name'], previewUrl,
              Duration(milliseconds: track['duration_ms'])));
        }
      } else {
        print('something went wrong, status code: ${response.statusCode
            .toString()}');
      }
    }
  } catch (error) {
    print('An error occured 3');
    print(error.toString());
  }
  return success;
}

Future<SpotifyAlbum> searchAlbum(String searchTerm) async {
  SpotifyAlbum album = new SpotifyAlbum.withSearchTerm(searchTerm);
  await _searchForAlbumId(album);
  if (album.found) {
    await _searchForAlbum(album);
  }
  return album;
}

class SpotifyAlbum {
  SpotifyAlbum()
      : found = false,
        tracks = new List<SpotifyTrack>(),
        _appleTrackCount = null;

  SpotifyAlbum.withSearchTerm(String searchTerm)
      : found = false,
        searchTerm = searchTerm,
        tracks = new List<SpotifyTrack>(),
        _appleTrackCount = null;

  /// Formats release date into an easy to use string using precision to get the relevant parts.
  String getReadableReleaseDate() {
    String output;
    if (this.found) {
      switch (this.releaseDatePrecision) {
        case ('day'):
          output = DateFormat.yMMMMd().format(this.releaseDate);
          break;
        case ('month'):
          output = DateFormat.yMMMM().format(this.releaseDate);
          break;
        case ('year'):
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
  String searchTerm, id, artists, title, imageUrl, releaseDatePrecision;
  DateTime releaseDate;
  List<SpotifyTrack> tracks;
  int _appleTrackCount;

  int dbId;

  Map<String, dynamic> toMap()
    => <String, dynamic>{
      'id': id,
      'artists': artists,
      'title': title,
      'imageUrl': imageUrl,
      'releaseDatePrecision': releaseDatePrecision,
      'releaseDate': releaseDate.toIso8601String()
    };
  
  SpotifyAlbum.fromMap(Map<String, dynamic>map) {
    id = map['id'];
    artists = map['artists'];
    title = map['title'];
    imageUrl = map['imageUrl'];
    releaseDatePrecision = map['releaseDatePrecision'];
    releaseDate = DateTime.parse(map['releaseDate']);
    dbId = map['dbId'];
  }
}

class SpotifyTrack {
  SpotifyTrack(String title, String previewUrl, Duration length)
      : title = title,
        previewUrl = previewUrl,
        length = length;

  String title, previewUrl;
  /// Length stored using duration to make using elements to display the time easy.
  Duration length;

  int dbAlbumId;

  Map<String, dynamic> toMap()
  => <String, dynamic>{
    'title': title,
    'previewUrl': previewUrl,
    'length': length.inMilliseconds,
    'dbAlbumId': dbAlbumId,
  };

  SpotifyTrack.fromMap(Map<String, dynamic>map) {
    title = map['title'];
    previewUrl = map['previewUrl'];
    length = Duration(milliseconds: map['length']);
    dbAlbumId = map['dbAlbumId'];
  }
}
