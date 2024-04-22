import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_api.dart';
import 'notification_service.dart';
import 'weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherApi>(create: (_) => WeatherApi()),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Weatherly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const WeatherScreen(),
      ),
    );
  }
}
