import 'package:flutter_test/flutter_test.dart';

import 'package:spotify_api/spotify_api.dart';

void main() {
  test('Search for smells like teen spirit', () async {
    final spotifyApi = SpotifyAPI();
    expect((await spotifyApi.search('smells like teen spirit')).found, true);
  });
}
