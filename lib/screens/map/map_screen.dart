import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // ✅ Option A: Map ready guard
  bool _mapReady = false;
  LatLng? _pendingCenter;
  double? _pendingZoom;

  // ✅ Current location + live tracking
  LatLng? _myLocation;
  bool _loadingLocation = true;
  StreamSubscription<Position>? _posSub;

  bool _followMe = true; // google maps style follow
  bool _liveTracking = true;

  // ✅ Search + suggestions
  final TextEditingController _searchCtrl = TextEditingController();
  List<_PlaceResult> _results = [];
  bool _searching = false;
  Timer? _debounce;

  // ✅ Route + distance
  LatLng? _selectedPlace;
  List<LatLng> _routePoints = [];
  double? _distanceKm;
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndLiveTracking(); // ✅ permission + start tracking
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _posSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // =========================
  // Snack helper
  // =========================
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================
  // ✅ Location OFF popup
  // =========================
  Future<void> _showLocationOffDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Turn on Location"),
          content: const Text(
            "Your location services are turned off. Please enable location to use map features.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Geolocator.openLocationSettings(); // ✅ opens location toggle screen
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // ✅ Permission denied forever popup
  // =========================
  Future<void> _showPermissionForeverDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Location permission is permanently denied. Please enable it from app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Geolocator.openAppSettings(); // ✅ app settings
            },
            child: const Text("Open App Settings"),
          ),
        ],
      ),
    );
  }

  // =========================
  // ✅ Safe move (Option A)
  // =========================
  void _safeMove(LatLng center, double zoom) {
    if (!_mapReady) {
      _pendingCenter = center;
      _pendingZoom = zoom;
      return;
    }
    _mapController.move(center, zoom);
  }

  // =========================
  // Permission + service checks
  // =========================
  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationOffDialog(); // ✅ popup instead of message
      return false;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      _snack("Location permission denied");
      return false;
    }

    if (perm == LocationPermission.deniedForever) {
      await _showPermissionForeverDialog();
      return false;
    }

    return true;
  }

  // =========================
  // ✅ Init location + start live tracking
  // =========================
  Future<void> _initLocationAndLiveTracking() async {
    try {
      final ok = await _ensurePermission();
      if (!ok) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final me = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _myLocation = me;
        _loadingLocation = false;
      });

      _safeMove(me, 15);

      // ✅ start live tracking
      _startLiveTracking();
    } catch (e) {
      if (mounted) setState(() => _loadingLocation = false);
      _snack("Location error: $e");
    }
  }

  void _startLiveTracking() {
    _posSub?.cancel();
    if (!_liveTracking) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // ✅ update every 10 meters
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) {
        final me = LatLng(pos.latitude, pos.longitude);

        setState(() {
          _myLocation = me;
        });

        if (_followMe) {
          _safeMove(me, 16);
        }

        if (_selectedPlace != null) {
          final meters = const Distance().as(
            LengthUnit.Meter,
            me,
            _selectedPlace!,
          );
          setState(() => _distanceKm = meters / 1000.0);
        }
      },
    );
  }

  // =========================
  // Search debounce (suggestions while typing)
  // =========================
  void _onSearchChanged(String text) {
    _debounce?.cancel();

    final q = text.trim();
    if (q.length < 3) {
      setState(() => _results = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPlaces(q);
    });
  }

  // =========================
  // Search (Nominatim)
  // =========================
  Future<void> _searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _searching = true;
      _results = [];
    });

    try {
      final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&addressdetails=1&limit=8",
      );

      final res = await http.get(
        uri,
        headers: {
          "User-Agent": "com.gwalior_darshan (premsagar998186@gmail.com)",
          "Accept-Language": "en",
        },
      );

      if (res.statusCode != 200) {
        setState(() => _searching = false);
        return;
      }

      final data = jsonDecode(res.body) as List<dynamic>;
      final list = data.map((e) => _PlaceResult.fromJson(e)).toList();

      setState(() {
        _results = list;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  // =========================
  // Route via OSRM
  // =========================
  Future<void> _selectPlace(_PlaceResult place) async {
    final me = _myLocation;
    if (me == null) {
      _snack("Current location not available yet");
      return;
    }

    final dest = LatLng(place.lat, place.lon);

    setState(() {
      _selectedPlace = dest;
      _searchCtrl.text = place.name;
      _results = [];
      _loadingRoute = true;
      _routePoints = [];
      _distanceKm = null;

      _followMe = false;
    });

    _safeMove(dest, 15);

    try {
      final url =
          "https://router.project-osrm.org/route/v1/driving/${me.longitude},${me.latitude};${dest.longitude},${dest.latitude}?overview=full&geometries=geojson";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        _snack("Route failed (${res.statusCode})");
        setState(() => _loadingRoute = false);
        return;
      }

      final json = jsonDecode(res.body);
      final routes = json["routes"] as List<dynamic>;
      if (routes.isEmpty) {
        _snack("No route found");
        setState(() => _loadingRoute = false);
        return;
      }

      final route = routes.first;
      final distanceMeters = (route["distance"] as num).toDouble();
      final coords = route["geometry"]["coordinates"] as List<dynamic>;

      final points = coords.map((c) {
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      setState(() {
        _routePoints = points;
        _distanceKm = distanceMeters / 1000.0;
        _loadingRoute = false;
      });
    } catch (e) {
      setState(() => _loadingRoute = false);
      _snack("Route error: $e");
    }
  }

  void _clearAll() {
    setState(() {
      _selectedPlace = null;
      _routePoints = [];
      _distanceKm = null;
      _results = [];
      _searchCtrl.clear();
      _followMe = true;
    });

    if (_myLocation != null) {
      _safeMove(_myLocation!, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1746A2);
    final fallback = const LatLng(26.2183, 78.1828);
    final center = _myLocation ?? fallback;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _loadingLocation
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),

                // ✅ Option A: map ready callback
                onMapReady: () {
                  _mapReady = true;
                  if (_pendingCenter != null && _pendingZoom != null) {
                    _mapController.move(_pendingCenter!, _pendingZoom!);
                    _pendingCenter = null;
                    _pendingZoom = null;
                  }
                },

                // ✅ if user drags map, stop follow
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && _followMe) {
                    setState(() => _followMe = false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.gwalior_darshan',
                ),

                // ✅ Route line
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                // ✅ Markers
                MarkerLayer(
                  markers: [
                    if (_myLocation != null)
                      Marker(
                        point: _myLocation!,
                        width: 56,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.18),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_taxi,
                              size: 32,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    if (_selectedPlace != null)
                      Marker(
                        point: _selectedPlace!,
                        width: 46,
                        height: 46,
                        child: const Icon(Icons.location_on,
                            size: 44, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),

            // =========================
            // Search UI
            // =========================
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: "Search places...",
                              border: InputBorder.none,
                            ),
                            onChanged: _onSearchChanged,
                            onSubmitted: _searchPlaces,
                          ),
                        ),
                        if (_searching)
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.close, color: Colors.black54),
                          ),
                      ],
                    ),
                  ),

                  if (_results.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final p = _results[i];
                          return ListTile(
                            dense: true,
                            title: Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();

                              setState(() {
                                _searchCtrl.text = p.name;
                                _results = [];
                              });

                              await _selectPlace(p);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // =========================
            // Bottom distance card
            // =========================
            if (_selectedPlace != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions, color: primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _loadingRoute
                            ? const Text("Getting directions...")
                            : Text(
                          _distanceKm == null
                              ? "Distance: --"
                              : "Distance: ${_distanceKm!.toStringAsFixed(2)} km",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                ),
              ),

            // =========================
            // My location button
            // =========================
            Positioned(
              right: 12,
              bottom: _selectedPlace == null ? 18 : 90,
              child: FloatingActionButton(
                heroTag: "myLocBtn",
                backgroundColor: primaryBlue,
                onPressed: () async {
                  await _initLocationAndLiveTracking();
                  if (_myLocation != null) _safeMove(_myLocation!, 16);
                  setState(() => _followMe = true);
                },
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceResult {
  final String name;
  final double lat;
  final double lon;

  _PlaceResult({required this.name, required this.lat, required this.lon});

  factory _PlaceResult.fromJson(Map<String, dynamic> json) {
    return _PlaceResult(
      name: (json["display_name"] ?? "").toString(),
      lat: double.parse(json["lat"].toString()),
      lon: double.parse(json["lon"].toString()),
    );
  }
}
