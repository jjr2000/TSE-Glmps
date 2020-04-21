import 'package:flutter_test/flutter_test.dart';
import 'package:web_detect/web_detect.dart';

void main() {
  test('Bad Base', () async {
    WebDetect webDetectRes = await webDetect('badBase');
    expect(webDetectRes.found, false);
  });
}
