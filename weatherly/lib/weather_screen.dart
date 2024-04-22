import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_api.dart';
import 'notification_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherInfo = 'Enter a city to get started';
  bool _isLoading = false;

  List<Map<String, dynamic>> cities = [
    {'name': 'Alabama', 'lat': 32.806671, 'lon': -86.791130},
    {'name': 'Alaska', 'lat': 61.370716, 'lon': -152.404419},
    {'name': 'Arizona', 'lat': 33.729759, 'lon': -111.431221},
    {'name': 'Arkansas', 'lat': 34.969704, 'lon': -92.373123},
    {'name': 'California', 'lat': 36.116203, 'lon': -119.681564},
    {'name': 'Colorado', 'lat': 39.059811, 'lon': -105.311104},
    {'name': 'Connecticut', 'lat': 41.597782, 'lon': -72.755371},
    {'name': 'Delaware', 'lat': 39.318523, 'lon': -75.507141},
    {'name': 'Florida', 'lat': 27.766279, 'lon': -81.686783},
    {'name': 'Georgia', 'lat': 33.040619, 'lon': -83.643074},
    {'name': 'Wyoming', 'lat': 42.755966, 'lon': -107.302490},
    {'name': 'Hawaii', 'lat': 21.094318, 'lon': -157.498337},
    {'name': 'Idaho', 'lat': 44.240459, 'lon': -114.478828},
    {'name': 'Illinois', 'lat': 40.349457, 'lon': -88.986137},
    {'name': 'Indiana', 'lat': 39.849426, 'lon': -86.258278},
    {'name': 'Iowa', 'lat': 42.011539, 'lon': -93.210526},
    {'name': 'Kansas', 'lat': 38.526600, 'lon': -96.726486},
    {'name': 'Kentucky', 'lat': 37.668140, 'lon': -84.670067},
    {'name': 'Louisiana', 'lat': 31.169546, 'lon': -91.867805},
    {'name': 'Maine', 'lat': 44.693947, 'lon': -69.381927},
    {'name': 'Maryland', 'lat': 39.063946, 'lon': -76.802101},
    {'name': 'Massachusetts', 'lat': 42.230171, 'lon': -71.530106},
    {'name': 'Michigan', 'lat': 43.326618, 'lon': -84.536095},
    {'name': 'Minnesota', 'lat': 45.694454, 'lon': -93.900192},
    {'name': 'Mississippi', 'lat': 32.741646, 'lon': -89.678696},
    {'name': 'Missouri', 'lat': 38.456085, 'lon': -92.288368},
    {'name': 'Montana', 'lat': 46.921925, 'lon': -110.454353},
    {'name': 'Nebraska', 'lat': 41.125370, 'lon': -98.268082},
    {'name': 'Nevada', 'lat': 38.313515, 'lon': -117.055374},
    {'name': 'New Hampshire', 'lat': 43.452492, 'lon': -71.563896},
    {'name': 'New Jersey', 'lat': 40.298904, 'lon': -74.521011},
    {'name': 'New Mexico', 'lat': 34.840515, 'lon': -106.248482},
    {'name': 'North Carolina', 'lat': 35.630066, 'lon': -79.806419},
    {'name': 'North Dakota', 'lat': 47.528912, 'lon': -99.784012},
    {'name': 'Ohio', 'lat': 40.388783, 'lon': -82.764915},
    {'name': 'Oklahoma', 'lat': 35.565342, 'lon': -96.928917},
    {'name': 'Oregon', 'lat': 44.572021, 'lon': -122.070938},
    {'name': 'Pennsylvania', 'lat': 40.590752, 'lon': -77.209755},
    {'name': 'Rhode Island', 'lat': 41.680893, 'lon': -71.511780},
    {'name': 'South Carolina', 'lat': 33.856892, 'lon': -80.945007},
    {'name': 'South Dakota', 'lat': 44.299782, 'lon': -99.438828},
    {'name': 'Tennessee', 'lat': 35.747845, 'lon': -86.692345},
    {'name': 'Texas', 'lat': 31.054487, 'lon': -97.563461},
    {'name': 'Utah', 'lat': 40.150032, 'lon': -111.862434},
    {'name': 'Vermont', 'lat': 44.045876, 'lon': -72.710686},
    {'name': 'Virginia', 'lat': 37.769337, 'lon': -78.169968},
    {'name': 'Washington', 'lat': 47.400902, 'lon': -121.490494},
    {'name': 'West Virginia', 'lat': 38.491226, 'lon': -80.954570},
    {'name': 'Wisconsin', 'lat': 44.268543, 'lon': -89.616508},
  ];

  @override
  Widget build(BuildContext context) {
    var weatherApi = Provider.of<WeatherApi>(context, listen: false);
    var notificationService =
        Provider.of<NotificationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weatherly'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return cities.where((city) {
                  return city['name']
                      .toString()
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (Map<String, dynamic> option) =>
                  option['name'],
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  _isLoading = true;
                });
                weatherApi
                    .fetchWeather(selection['lat'], selection['lon'])
                    .then((data) {
                  setState(() {
                    _weatherInfo =
                        'City: ${data['name']} - Temp: ${data['main']['temp']}°C';
                    _isLoading = false;
                  });
                }).catchError((error) {
                  setState(() {
                    _weatherInfo = "Failed to get weather";
                    _isLoading = false;
                  });
                });
              },
            ),
            Expanded(
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(_weatherInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
