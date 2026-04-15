import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../viewmodel/map_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context/provider 접근은 첫 프레임 이후가 안전하다.
      unawaited(context.read<MapViewModel>().ensureInitialized());
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _moveToJongno() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        context.read<MapViewModel>().initialCameraPosition,
      ),
    );
  }

  Future<void> _zoomIn() async {
    await _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    await _controller?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MapHeader(),
            const _FilterBar(),
            Expanded(
              child: _MapContent(
                onMapCreated: (controller) => _controller = controller,
                onMoveToJongno: () => unawaited(_moveToJongno()),
                onZoomIn: () => unawaited(_zoomIn()),
                onZoomOut: () => unawaited(_zoomOut()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '지도',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Selector<MapViewModel, bool>(
            selector: (_, viewModel) => viewModel.isLoading,
            builder: (context, isLoading, _) {
              return IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                        unawaited(context.read<MapViewModel>().refresh());
                      },
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '새로고침',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Selector<MapViewModel, String>(
      selector: (_, viewModel) => viewModel.selectedTypeId,
      builder: (context, selectedTypeId, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in MapViewModel.typeOptions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option.label),
                      avatar: Icon(option.icon, size: 18),
                      selected: selectedTypeId == option.id,
                      onSelected: (_) {
                        context.read<MapViewModel>().selectType(option.id);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent({
    required this.onMapCreated,
    required this.onMoveToJongno,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final ValueChanged<GoogleMapController> onMapCreated;
  final VoidCallback onMoveToJongno;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _GoogleMapLayer(onMapCreated: onMapCreated),
        const _LoadingOverlay(),
        Positioned(
          right: 16,
          bottom: 124,
          child: _MapFloatingMenu(
            onMoveToJongno: onMoveToJongno,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 20, child: _MapSummary()),
      ],
    );
  }
}

class _GoogleMapLayer extends StatelessWidget {
  const _GoogleMapLayer({required this.onMapCreated});

  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MapViewModel>();

    return Selector<MapViewModel, Set<Marker>>(
      selector: (_, viewModel) => viewModel.markers,
      builder: (_, markers, _) {
        return RepaintBoundary(
          child: GoogleMap(
            initialCameraPosition: viewModel.initialCameraPosition,
            // 지도를 종로구 주변 범위 안에서만 움직이도록 제한한다.
            cameraTargetBounds: viewModel.cameraTargetBounds,
            minMaxZoomPreference: const MinMaxZoomPreference(13.4, 17.8),
            markers: markers,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: onMapCreated,
          ),
        );
      },
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Selector<MapViewModel, bool>(
      selector: (_, viewModel) => viewModel.isLoading,
      builder: (_, isLoading, _) {
        if (!isLoading) {
          return const SizedBox.shrink();
        }
        return const Positioned.fill(
          child: ColoredBox(
            color: Color(0x33000000),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class _MapFloatingMenu extends StatefulWidget {
  const _MapFloatingMenu({
    required this.onMoveToJongno,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onMoveToJongno;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  State<_MapFloatingMenu> createState() => _MapFloatingMenuState();
}

class _MapFloatingMenuState extends State<_MapFloatingMenu> {
  bool _isOpen = false;

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
  }

  void _runAndClose(VoidCallback action) {
    action();
    setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MapViewModel, bool>(
      selector: (_, viewModel) => viewModel.isLoading,
      builder: (context, isLoading, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isOpen
                  ? Column(
                      key: const ValueKey('map-menu-open'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FloatingMenuAction(
                          icon: Icons.refresh_rounded,
                          label: '새로고침',
                          onPressed: isLoading
                              ? null
                              : () {
                                  _runAndClose(() {
                                    unawaited(
                                      context.read<MapViewModel>().refresh(),
                                    );
                                  });
                                },
                        ),
                        const SizedBox(height: 8),
                        _FloatingMenuAction(
                          icon: Icons.center_focus_strong_rounded,
                          label: '종로로 이동',
                          onPressed: () => _runAndClose(widget.onMoveToJongno),
                        ),
                        const SizedBox(height: 8),
                        _FloatingMenuAction(
                          icon: Icons.add_rounded,
                          label: '확대',
                          onPressed: () => _runAndClose(widget.onZoomIn),
                        ),
                        const SizedBox(height: 8),
                        _FloatingMenuAction(
                          icon: Icons.remove_rounded,
                          label: '축소',
                          onPressed: () => _runAndClose(widget.onZoomOut),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            FloatingActionButton.small(
              heroTag: 'map-floating-menu',
              onPressed: _toggle,
              tooltip: '지도 메뉴',
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(_isOpen ? Icons.close_rounded : Icons.menu_rounded),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingMenuAction extends StatelessWidget {
  const _FloatingMenuAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'map-floating-menu-$label',
      onPressed: onPressed,
      tooltip: label,
      child: Icon(icon),
    );
  }
}

// 지도 요약
class _MapSummary extends StatelessWidget {
  const _MapSummary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<MapViewModel, String>(
      selector: (_, viewModel) => viewModel.summaryMessage,
      builder: (_, summaryMessage, _) {
        return Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종로구 시설 지도',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summaryMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
