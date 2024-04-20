import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_api.dart';
import 'notification_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weatherly')),
      body: Center(
        child: Text('Weather Information Displayed Here'),
      ),
    );
  }
}
