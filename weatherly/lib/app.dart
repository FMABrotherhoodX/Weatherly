import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'homescreen.dart';

class WeatherlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
