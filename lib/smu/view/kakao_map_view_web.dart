// Web (Chrome/Edge)용 카카오 지도 뷰.
// 같은 origin의 web/kakao_map.html을 iframe으로 로드하여 Kakao SDK의
// origin 검증을 통과합니다. (Kakao Developers > 플랫폼 > Web 사이트 도메인에
// 실행 중인 Flutter web의 origin을 등록해야 합니다. 예: http://localhost:5000)
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'kakao_marker.dart';

class KakaoMapPlatformView extends StatefulWidget {
  final double lat;
  final double lng;
  final String appKey;
  final String label;
  final List<KakaoBuildingMarker>? markers;
  final KakaoMarkerTap? onMarkerTap;

  const KakaoMapPlatformView({
    super.key,
    required this.lat,
    required this.lng,
    required this.appKey,
    this.label = '',
    this.markers,
    this.onMarkerTap,
  });

  @override
  State<KakaoMapPlatformView> createState() => _KakaoMapPlatformViewState();
}

class _KakaoMapPlatformViewState extends State<KakaoMapPlatformView> {
  late final String _viewType;
  JSFunction? _messageListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'kakao-map-${DateTime.now().microsecondsSinceEpoch}';

    final markers = widget.markers ?? const <KakaoBuildingMarker>[];
    final buildingsJson = jsonEncode(
      markers
          .map((m) => {
                'id': m.id,
                'label': m.label,
                'lat': m.lat,
                'lng': m.lng,
                'color': m.color,
              })
          .toList(),
    );

    final src = StringBuffer('kakao_map.html')
      ..write('?lat=${widget.lat}')
      ..write('&lng=${widget.lng}')
      ..write('&key=${Uri.encodeQueryComponent(widget.appKey)}')
      ..write('&label=${Uri.encodeQueryComponent(widget.label)}');
    if (markers.isNotEmpty) {
      src.write('&buildings=${Uri.encodeQueryComponent(buildingsJson)}');
    }

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = web.HTMLIFrameElement()
        ..src = src.toString()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation';
      return iframe;
    });

    if (widget.onMarkerTap != null) {
      _messageListener = ((web.Event event) {
        final me = event as web.MessageEvent;
        if (me.origin != web.window.location.origin) return;
        final data = me.data;
        if (data == null) return;
        try {
          final raw = data.toString();
          final decoded = jsonDecode(raw);
          if (decoded is! Map) return;
          if (decoded['type'] == 'markerClick') {
            final id = decoded['id'];
            if (id is String) widget.onMarkerTap?.call(id);
          }
        } catch (_) {
          // 무시
        }
      }).toJS;
      web.window.addEventListener('message', _messageListener);
    }
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      web.window.removeEventListener('message', _messageListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
