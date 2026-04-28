import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../jongno_boundary_overlay.dart';
import '../model/map_facility.dart';
import '../viewmodel/map_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Set<Polygon> _jongnoMaskPolygons = const <Polygon>{};
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(context.read<MapViewModel>().ensureInitialized());
    });
    unawaited(_loadMaskPolygons());
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '종로구 지도',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
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
                    minMaxZoomPreference: const MinMaxZoomPreference(
                      13.4,
                      17.8,
                    ),
                    markers: viewModel.markers,
                    polygons: _jongnoMaskPolygons,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                    onTap: (_) => viewModel.clearSelectedFacility(),
                  ),
                  if (viewModel.isLoading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x33000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 90,
                    child: _GpsButton(
                      isLocating: _isLocating,
                      onTap: _goToCurrentLocation,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _MapSummary(
                      viewModel: viewModel,
                      onOpenDetail: (facility) => context.push(
                        '/facility/${facility.facilityId}?category=${facility.categoryId}',
                      ),
                      onOpenList: () => _showFacilityListSheet(
                        context,
                        viewModel.filteredFacilities,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 서비스를 켜주세요.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('위치 권한이 필요합니다.')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('설정에서 위치 권한을 허용해주세요.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.5,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져오지 못했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _loadMaskPolygons() async {
    final polygons = await JongnoBoundaryOverlay.buildMaskPolygons(
      strokeColor: const Color(0xFF2563EB),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _jongnoMaskPolygons = polygons;
    });
  }

  void _showFacilityListSheet(
    BuildContext context,
    List<MapFacility> facilities,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.52,
            minChildSize: 0.35,
            maxChildSize: 0.88,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '시설 목록 ${facilities.length}개',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: facilities.isEmpty
                        ? const Center(
                            child: Text(
                              '표시할 시설이 없습니다.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: facilities.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final facility = facilities[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                title: Text(
                                  facility.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  facility.address ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  context.push(
                                    '/facility/${facility.facilityId}?category=${facility.categoryId}',
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
  const _MapSummary({
    required this.viewModel,
    required this.onOpenDetail,
    required this.onOpenList,
  });

  final MapViewModel viewModel;
  final ValueChanged<MapFacility> onOpenDetail;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedFacility = viewModel.selectedFacility;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: selectedFacility == null
          ? Align(
              key: const ValueKey('summary-pill'),
              alignment: Alignment.bottomLeft,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenList,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0F172A),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_list_bulleted_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          viewModel.errorMessage ??
                              '${viewModel.filteredFacilities.length}개 시설',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.expand_less_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            )
            : Card(
              key: const ValueKey('selected-card'),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FacilityLogo(
                          facility: selectedFacility,
                          viewModel: viewModel,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedFacility.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getCategoryById(
                                    selectedFacility.categoryId,
                                  ).bgColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  viewModel
                                      .optionFor(selectedFacility.type)
                                      .label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: getCategoryById(
                                      selectedFacility.categoryId,
                                    ).color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedFacility.address ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    if ((selectedFacility.phone ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedFacility.phone!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => onOpenDetail(selectedFacility),
                        child: const Text('시설 상세 보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FacilityLogo extends StatelessWidget {
  const _FacilityLogo({
    required this.facility,
    required this.viewModel,
  });

  final MapFacility facility;
  final MapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final category = getCategoryById(facility.categoryId);
    final option = viewModel.optionFor(facility.type);
    final imageAssetPath = _normalizedAssetPath(facility.imageAssetPath);
    final imageUrl = _normalizedRemoteUrl(facility.imageUrl);
    final faviconUrl = _buildFaviconUrl(facility.homepage);

    Widget buildFallback() {
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.bgColor,
              option.color.withValues(alpha: 0.18),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                option.icon,
                size: 30,
                color: option.color,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  option.icon,
                  size: 11,
                  color: option.color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildRemote(String url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          url,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => buildFallback(),
        ),
      );
    }

    if (imageAssetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          imageAssetPath,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            if (imageUrl != null) {
              return buildRemote(imageUrl);
            }
            if (faviconUrl != null) {
              return buildRemote(faviconUrl);
            }
            return buildFallback();
          },
        ),
      );
    }
    if (imageUrl != null) {
      return buildRemote(imageUrl);
    }
    if (faviconUrl != null) {
      return buildRemote(faviconUrl);
    }
    return buildFallback();
  }

  String? _normalizedAssetPath(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String? _normalizedRemoteUrl(String? url) {
    final value = url?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return null;
    }
    if (uri.hasScheme) {
      return uri.toString();
    }
    final normalized = Uri.tryParse('https://$value');
    return normalized?.toString();
  }

  String? _buildFaviconUrl(String? homepage) {
    final normalized = _normalizedRemoteUrl(homepage);
    if (normalized == null) {
      return null;
    }
    final uri = Uri.tryParse(normalized);
    final host = uri?.host.trim();
    if (host == null || host.isEmpty) {
      return null;
    }
    return 'https://www.google.com/s2/favicons?sz=128&domain_url=$host';
  }
}

class _GpsButton extends StatelessWidget {
  const _GpsButton({required this.isLocating, required this.onTap});

  final bool isLocating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        onTap: isLocating ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.my_location_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
          ),
        ),
      ),
    );
  }
}
