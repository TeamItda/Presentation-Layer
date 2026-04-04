import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../viewmodel/facility_list_viewmodel.dart';

class FacilityListView extends StatefulWidget {
  final String categoryId;
  const FacilityListView({super.key, required this.categoryId});

  @override
  State<FacilityListView> createState() => _FacilityListViewState();
}

class _FacilityListViewState extends State<FacilityListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityListViewModel>().loadFacilities(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FacilityListViewModel>();
    final cat = getCategoryById(widget.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cat, vm.facilities.length),
            _buildToggle(vm, cat),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.hasError
                  ? _buildError(vm.errorMessage)
                  : vm.facilities.isEmpty
                  ? _buildEmpty(cat)
                  : vm.viewMode == 'list'
                  ? _buildListView(context, vm, cat)
                  : _buildMapView(vm, cat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Category cat, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: cat.bgColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, size: 22),
          ),
          const SizedBox(width: 10),
          Text(cat.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                '📍 종로구 · $count개',
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(FacilityListViewModel vm, Category cat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _toggleButton('📋 리스트', vm.viewMode == 'list', cat.color, () {
            if (vm.viewMode != 'list') vm.toggleViewMode();
          }),
          const SizedBox(width: 6),
          _toggleButton('🗺 지도', vm.viewMode == 'map', cat.color, () {
            if (vm.viewMode != 'map') vm.toggleViewMode();
          }),
        ],
      ),
    );
  }

  Widget _toggleButton(
    String label,
    bool active,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.subText,
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😥', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: AppColors.subText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context
                .read<FacilityListViewModel>()
                .loadFacilities(widget.categoryId),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(Category cat) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(cat.icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            '등록된 시설이 없습니다',
            style: TextStyle(fontSize: 13, color: AppColors.subText),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    FacilityListViewModel vm,
    Category cat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: vm.facilities.length,
      itemBuilder: (context, index) {
        final f = vm.facilities[index];
        return GestureDetector(
          onTap: () => context.push(
            '/facility/${f['id']}?category=${widget.categoryId}',
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        f['addr'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.subText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (f['tel'] != null && f['tel'].toString().isNotEmpty)
                        Text(
                          '📞 ${f['tel']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      if (f['type'] != null && f['type'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: cat.bgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              f['type'].toString(),
                              style: TextStyle(
                                fontSize: 9,
                                color: cat.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.subText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(FacilityListViewModel vm, Category cat) {
    final facilities = vm.mappableFacilities;
    final initialTarget = facilities.isNotEmpty
        ? LatLng(
            (facilities.first['lat'] as num).toDouble(),
            (facilities.first['lng'] as num).toDouble(),
          )
        : const LatLng(
            AppConstants.jongnoCenterLat,
            AppConstants.jongnoCenterLng,
          );

    final markers = facilities.map((facility) {
      return Marker(
        markerId: MarkerId('${widget.categoryId}:${facility['id']}'),
        position: LatLng(
          (facility['lat'] as num).toDouble(),
          (facility['lng'] as num).toDouble(),
        ),
        infoWindow: InfoWindow(
          title: facility['name']?.toString() ?? '',
          snippet: facility['addr']?.toString(),
        ),
      );
    }).toSet();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: 14,
          ),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: const LatLng(
                AppConstants.jongnoSouthLat,
                AppConstants.jongnoWestLng,
              ),
              northeast: const LatLng(
                AppConstants.jongnoNorthLat,
                AppConstants.jongnoEastLng,
              ),
            ),
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(13.2, 18),
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '종로구 ${cat.name} 지도 · ${facilities.length}개 표시',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
