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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '지도',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: viewModel.isLoading ? null : viewModel.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: '새로고침',
                  ),
                ],
              ),
            ),
            _FilterBar(viewModel: viewModel),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: viewModel.initialCameraPosition,
                    // 지도를 종로구 주변 범위 안에서만 움직이도록 제한한다.
                    cameraTargetBounds: viewModel.cameraTargetBounds,
                    minMaxZoomPreference: const MinMaxZoomPreference(
                      13.4,
                      17.8,
                    ),
                    markers: viewModel.markers,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _controller = controller,
                  ),
                  if (viewModel.isLoading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x33000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _MapSummary(viewModel: viewModel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.viewModel});

  final MapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
                  selected: viewModel.selectedTypeId == option.id,
                  onSelected: (_) => viewModel.selectType(option.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapSummary extends StatelessWidget {
  const _MapSummary({required this.viewModel});

  final MapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              viewModel.errorMessage ??
                  '${viewModel.filteredFacilities.length}개 시설이 표시되고 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
