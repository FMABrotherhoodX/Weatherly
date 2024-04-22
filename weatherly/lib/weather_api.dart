import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String apiKey = '9c4e718d8b37c3202fdfbfc8bce35afb';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<dynamic> fetchWeatherForecast(
      double latitude, double longitude) async {
    var url = Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather forecast data');
    }
  }
}
