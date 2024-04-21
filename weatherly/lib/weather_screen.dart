import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_api.dart';
import 'notification_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherInfo = 'Fetching weather data...';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      var weatherApi = Provider.of<WeatherApi>(context, listen: false);
      var weatherData = await weatherApi.fetchWeather(
          40.7128, -74.0060); // Example coordinates (New York)
      setState(() {
        _weatherInfo =
            'City: ${weatherData['name']} - Temp: ${weatherData['main']['temp']}°C';
      });
    } catch (e) {
      setState(() {
        _weatherInfo = "Failed to get weather";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var notificationService =
        Provider.of<NotificationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weatherly'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_weatherInfo),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Notify Weather Alert'),
              onPressed: () {
                notificationService.showNotification(
                    0, "Weather Alert", "Severe weather warning!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
