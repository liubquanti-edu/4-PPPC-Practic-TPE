import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/marker.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUnit = 'gas';
  MarkerModel? _selectedMarker;
  String? _mapStyle;
 
  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
    _loadMarkers();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/darkmap.json');
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  Future<void> _loadMarkers() async {
    final snapshots = await _firestore.collection('markers').where('unit', isEqualTo: _selectedUnit).get();
    Set<Marker> markers = {};

    for (var doc in snapshots.docs) {
      final markerData = MarkerModel.fromMap(doc.data());
      markers.add(
        Marker(
          markerId: MarkerId(markerData.id),
          position: LatLng(markerData.latitude, markerData.longitude),
          infoWindow: InfoWindow(
            title: markerData.title,
            snippet: markerData.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(markerData.unit)),
          onTap: () => _onMarkerTapped(markerData),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerColor(String unit) {
    switch (unit) {
      case 'gas':
        return BitmapDescriptor.hueGreen;
      case 'hotel':
        return BitmapDescriptor.hueBlue;
      case 'service':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMarkerTapped(MarkerModel marker) {
    setState(() {
      _selectedMarker = marker;
    });
  }

  void _openInGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openDirections(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          _selectedUnit = 'gas';
          break;
        case 1:
          _selectedUnit = 'hotel';
          break;
        case 2:
          _selectedUnit = 'service';
          break;
      }
      _loadMarkers();
      _selectedMarker = null;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedMarker = null;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      controller.setMapStyle(_mapStyle);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_mapController != null) {
      final brightness = MediaQuery.of(context).platformBrightness;
      _mapController!.setMapStyle(
        brightness == Brightness.dark ? _mapStyle : null
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final logoAsset = brightness == Brightness.dark 
        ? 'assets/logodark.svg'
        : 'assets/logolight.svg';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              logoAsset,
              height: 32,
              color: brightness == Brightness.dark ? Colors.teal.shade200 : Colors.teal.shade800,
            ),
            const SizedBox(width: 12),
            const Text('Мапа сервісів'),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Вихід'),
                  content: Text('Ви дійсно бажаєте вийти з облікового запису?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Скасувати'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Вийти'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(49.58964818142734, 34.55102480094977),
          zoom: 12,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onTap: _onMapTapped,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedUnit == 'gas' ? 0 : _selectedUnit == 'hotel' ? 1 : 2,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.local_gas_station),
            label: 'АЗС',
          ),
          NavigationDestination(
            icon: Icon(Icons.hotel),
            label: 'Готелі',
          ),
          NavigationDestination(
            icon: Icon(Icons.build),
            label: 'СТО',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedMarker != null) ...[
            FloatingActionButton(
              onPressed: () => _openInGoogleMaps(_selectedMarker!.latitude, _selectedMarker!.longitude),
              child: Icon(Icons.map),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => _openDirections(_selectedMarker!.latitude, _selectedMarker!.longitude),
              child: Icon(Icons.directions),
            ),
            SizedBox(height: 10),
          ],
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}