library web_detect;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _apiUrl = 'http://51.75.162.158:5000/';

Future<bool> _webDetect(WebDetect webDetect) async {
  bool success = false;
  try {
    var response = await http.post(
        '${_apiUrl}imageSend',
        headers: {
        },
        body: {
          // This is a server authorization grant type that doesn't require user login.
          'image': webDetect.base64
        }
    );

    if (response.statusCode == 200) {
      // Decode the json return into a dynamic map so we can access the elements programmatically.
      Map<String, dynamic> decoded = json.decode(response.body);
      webDetect.result = decoded['image'];
      // If we hit here everything worked so mark the success.
      webDetect.found = webDetect.result != 'None';
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

Future<WebDetect> webDetect(String base64) async {
  WebDetect webDetect = new WebDetect.withBase64(base64);
  await _webDetect(webDetect);

  return webDetect;
}

class WebDetect {
  WebDetect()
      : found = false,
        result = '';

  WebDetect.withBase64(String base64)
      : found = false,
        result = '',
        base64 = base64;

  bool found;
  String result, base64;

}

