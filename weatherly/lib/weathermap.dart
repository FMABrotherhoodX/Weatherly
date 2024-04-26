import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherMapScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherMapScreen({Key? key, required this.weatherData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assign default values in case 'lat' or 'lon' is null or not a double
    final latitude = weatherData['lat'] is double
        ? weatherData['lat'] as double
        : 37.42796133580664;
    final longitude = weatherData['lon'] is double
        ? weatherData['lon'] as double
        : -122.085749655962;
    final LatLng center = LatLng(latitude, longitude);

    // Create a new Google Map Controller
    final Completer<GoogleMapController> _controller = Completer();

    // Prepare the marker with weather information
    final String name = weatherData['name'] ?? 'Unknown';
    final String temperature = weatherData['temperature']?.toString() ?? 'N/A';
    final String description =
        weatherData['description']?.toString() ?? 'No description';
    final Marker marker = Marker(
      markerId: MarkerId('selectedLocation'),
      position: center,
      infoWindow: InfoWindow(
          title: name, snippet: 'Temp: $temperature, Desc: $description'),
      icon: BitmapDescriptor.defaultMarker,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Map - $name'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 10,
        ),
        mapType: MapType.normal,
        markers: {marker},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
