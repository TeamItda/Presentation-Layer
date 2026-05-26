// Public API for the Kakao map widget. Imports the correct platform impl
// at compile time (web vs mobile). Consumers only import this file.
export 'kakao_map_view_io.dart' if (dart.library.html) 'kakao_map_view_web.dart';
