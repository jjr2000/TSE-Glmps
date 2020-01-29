library spotify_api;

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => SpotifyAPI()._GetClientCredentials();

/// Spotify integration.
class SpotifyAPI {

  String _accounts_api_url = 'https://accounts.spotify.com/api/',
      _acess_token,
      _client_id = '78a66d01fd95418a889fc7357bfed056',
      _client_secret = '0a24f2c53a68463985038c7570a633d5';
  ///Gets an auth token for all communication with Spotify.
  void _GetClientCredentials() async
  {
    try {
      var response = await http.post(
          _accounts_api_url + 'token',
          headers: {
            'Authorization': 'Basic ' +
                base64.encode(utf8.encode(_client_id + ':' + _client_secret))
          },
          body: {
            'grant_type': 'client_credentials'
          }
      );

      if (response.statusCode == 200) {
        print('I Got A 200');
        print('The response body was:');
        print(response.body);
      }else{
        print('something went wrong, status code: ' + response.statusCode.toString());
      }
    }
    catch(error){

    }
  }
}
