import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants.dart';

/// Android/iOS용 카카오 지도 뷰. webview_flutter로 HTML을 로드합니다.
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
  WebViewController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) {
                setState(() {
                  _loading = true;
                  _error = null;
                });
              }
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (e) {
              if (mounted) {
                setState(() => _error = '${e.errorCode}: ${e.description}');
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (msg) {
            if (mounted) setState(() => _error = msg.message);
          },
        )
        ..loadHtmlString(_html(), baseUrl: 'http://localhost');
    } catch (e) {
      _error = 'WebView init failed: $e';
    }
  }

  String _html() {
    final lat = widget.lat;
    final lng = widget.lng;
    final key = widget.appKey;
    final label = widget.label;
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <style>html, body, #map { margin: 0; padding: 0; width: 100%; height: 100%; }</style>
</head>
<body>
  <div id="map"></div>
  <script>
    function reportError(msg) {
      if (window.FlutterChannel && window.FlutterChannel.postMessage) {
        window.FlutterChannel.postMessage(msg);
      }
    }
    window.onerror = function(msg, src) {
      reportError('JS Error: ' + msg + (src ? ' @ ' + src : ''));
    };
  </script>
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$key&autoload=false"
          onerror="reportError('Kakao SDK script load failed (check JS key / Web domain).');"></script>
  <script>
    try {
      if (typeof kakao === 'undefined' || !kakao.maps) {
        reportError('kakao is undefined. SDK not loaded.');
      } else {
        kakao.maps.load(function() {
          try {
            var center = new kakao.maps.LatLng($lat, $lng);
            var map = new kakao.maps.Map(document.getElementById('map'), {
              center: center, level: 3
            });
            var marker = new kakao.maps.Marker({ position: center, map: map });
            ${label.isEmpty ? '' : '''
            var info = new kakao.maps.InfoWindow({
              content: '<div style="padding:6px 10px;font-size:13px;font-weight:600;">$label</div>'
            });
            info.open(map, marker);
            '''}
            map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);
          } catch (e) { reportError('Map init error: ' + e.message); }
        });
      }
    } catch (e) { reportError('Bootstrap error: ' + e.message); }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _errorView(_error ?? 'WebView is not available on this platform.');
    }
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_loading && _error == null)
          const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF991B1B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.subText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
