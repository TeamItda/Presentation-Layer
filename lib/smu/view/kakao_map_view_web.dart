// Web (Chrome/Edge)용 카카오 지도 뷰.
// 같은 origin의 web/kakao_map.html을 iframe으로 로드하여 Kakao SDK의
// origin 검증을 통과합니다. (Kakao Developers > 플랫폼 > Web 사이트 도메인에
// 실행 중인 Flutter web의 origin을 등록해야 합니다. 예: http://localhost:5000)
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class KakaoMapPlatformView extends StatefulWidget {
  final double lat;
  final double lng;
  final String appKey;
  final String label;

  const KakaoMapPlatformView({
    super.key,
    required this.lat,
    required this.lng,
    required this.appKey,
    this.label = '',
  });

  @override
  State<KakaoMapPlatformView> createState() => _KakaoMapPlatformViewState();
}

class _KakaoMapPlatformViewState extends State<KakaoMapPlatformView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'kakao-map-${DateTime.now().microsecondsSinceEpoch}';

    final src = 'kakao_map.html'
        '?lat=${widget.lat}'
        '&lng=${widget.lng}'
        '&key=${Uri.encodeQueryComponent(widget.appKey)}'
        '&label=${Uri.encodeQueryComponent(widget.label)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = web.HTMLIFrameElement()
        ..src = src
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
