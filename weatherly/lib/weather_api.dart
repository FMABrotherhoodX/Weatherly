import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String apiKey = 'daf043f55f1a28e50c66f6400a07f51e';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<dynamic> fetchWeather(double latitude, double longitude) async {
    var url = Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
