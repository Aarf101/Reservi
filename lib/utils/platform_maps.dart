// Conditional export: use web implementation when compiled to web, otherwise stub.
export 'platform_maps_stub.dart'
    if (dart.library.html) 'platform_maps_web.dart';
