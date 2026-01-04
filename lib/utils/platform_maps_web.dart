// Web implementation: detect whether the Google Maps JS API is present on the page.
// The file intentionally imports web-only libraries; silence analyzer warnings
// when analyzing non-web targets.
// ignore_for_file: uri_does_not_exist, avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js_util' as js_util;

bool mapsJsAvailable() {
  try {
    if (!js_util.hasProperty(html.window, 'google')) return false;
    final google = js_util.getProperty(html.window, 'google');
    return js_util.hasProperty(google, 'maps');
  } catch (e) {
    return false;
  }
}
