import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const homeLocation = const LatLng(47.4884983978917, 12.076704094834634);

  final Set<Marker>_markers = Set<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> _polygonsLatLngs = List<LatLng>();
  Set<Circle> _circles = HashSet<Circle>();

  Location location = new Location();
  LocationData currentLocation;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  BitmapDescriptor homeLocationIcon;
  BitmapDescriptor currentLocationIcon;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    location.onLocationChanged.listen((LocationData latestLocation) {
      currentLocation = latestLocation;
      log("current location:" + latestLocation.toString());
      setState(() {
        _circles.clear();
        _circles.add(createCircle(LatLng(latestLocation.latitude, latestLocation.longitude)));
      });
    });
    loadIcons();
    setInitialLocation();
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();
      _markers.add(createMarker('Home', 'Home location', homeLocation, homeLocationIcon));
      createPolygon();
    });
  }

  void createPolygon() {
    _polygonsLatLngs.add(LatLng(47.48897299761674, 12.075536645266014));
    _polygonsLatLngs.add(LatLng(47.48901649728566, 12.07593898179892));
    _polygonsLatLngs.add(LatLng(47.48882799864729, 12.07627426063445));
    _polygonsLatLngs.add(LatLng(47.488626813930544, 12.076193791970985));
    _polygonsLatLngs.add(LatLng(47.48851444103313, 12.07574049616156));
    _polygonsLatLngs.add(LatLng(47.48867756315127, 12.07534620861972));
    _polygonsLatLngs.add(LatLng(47.48897299761674, 12.075536645266014));
    
    _polygons.add(Polygon(
      polygonId: PolygonId('polygon_id'),
      points: List.from(_polygonsLatLngs),
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.red.withOpacity(0.15),
    ));
  }

  Circle createCircle(LatLng latLng) {
    final String circleId = 'circle_id_${latLng.latitude}_${latLng.longitude}';
    return Circle(
      circleId: CircleId(circleId),
      center: latLng,
      radius: 2,
      fillColor: Colors.blue,
      strokeWidth: 2,
      strokeColor: Colors.white
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Maps in Flutter'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: homeLocation,
            zoom: 18,
          ),
          markers: _markers,
          polygons: _polygons,
          circles: _circles,
          mapType: MapType.satellite,
        ),
      ),
    );
  }

  void _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Marker createMarker(String markerName, String text, LatLng latLng, BitmapDescriptor icon) {
    final marker = Marker(
      markerId: MarkerId(markerName),
      position: LatLng(latLng.latitude, latLng.longitude),
      infoWindow: InfoWindow(
        title: markerName,
        snippet: text,
      ),
      icon: icon
      // ... to here.
    );
    return marker;
  }

  Future<void> loadIcons() async {
    homeLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/outline_home_black_24dp.png');
  }
}