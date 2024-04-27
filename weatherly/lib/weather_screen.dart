import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'user_report.dart';
import 'weather_api.dart';
import 'weathermap.dart';

enum ColorTheme { blue, purple }

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherInfo = 'Enter a state to get started';
  bool _isLoading = false;
  bool _isCelsius = true;
  late TapGestureRecognizer _temperatureToggleRecognizer;
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode
  ColorTheme _colorTheme = ColorTheme.blue;
  Map<String, dynamic>? _lastFetchedData;

  final ThemeData lightBlueTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.blue.shade100,
    appBarTheme: const AppBarTheme(color: Colors.blue),
  );

  final ThemeData lightPurpleTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.purple,
    scaffoldBackgroundColor: Colors.purple.shade100,
    appBarTheme: const AppBarTheme(color: Colors.purple),
  );

  final ThemeData darkBlueTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.blue.shade800,
    appBarTheme: AppBarTheme(color: Colors.blue.shade700),
  );

  final ThemeData darkPurpleTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.purple,
    scaffoldBackgroundColor: Colors.purple.shade800,
    appBarTheme: AppBarTheme(color: Colors.purple.shade700),
  );

  @override
  void initState() {
    super.initState();
    _temperatureToggleRecognizer = TapGestureRecognizer()
      ..onTap = _toggleTemperatureUnit;
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light && _colorTheme == ColorTheme.blue) {
        _colorTheme = ColorTheme.purple;
      } else if (_themeMode == ThemeMode.light &&
          _colorTheme == ColorTheme.purple) {
        _themeMode = ThemeMode.dark;
        _colorTheme = ColorTheme.blue;
      } else if (_themeMode == ThemeMode.dark &&
          _colorTheme == ColorTheme.blue) {
        _colorTheme = ColorTheme.purple;
      } else if (_themeMode == ThemeMode.dark &&
          _colorTheme == ColorTheme.purple) {
        _themeMode = ThemeMode.light;
        _colorTheme = ColorTheme.blue;
      }
    });
  }

  ThemeData get currentTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return _colorTheme == ColorTheme.blue
            ? ThemeData.light().copyWith(
                primaryColor: Colors.blue,
                scaffoldBackgroundColor: Colors.blue.shade100,
                appBarTheme: const AppBarTheme(color: Colors.blue))
            : ThemeData.light().copyWith(
                primaryColor: Colors.purple,
                scaffoldBackgroundColor: Colors.purple.shade100,
                appBarTheme: const AppBarTheme(color: Colors.purple));
      case ThemeMode.dark:
        return _colorTheme == ColorTheme.blue
            ? ThemeData.dark().copyWith(
                primaryColor: Colors.blue,
                scaffoldBackgroundColor: Colors.blue.shade800,
                appBarTheme: AppBarTheme(color: Colors.blue.shade700))
            : ThemeData.dark().copyWith(
                primaryColor: Colors.purple,
                scaffoldBackgroundColor: Colors.purple.shade800,
                appBarTheme: AppBarTheme(color: Colors.purple.shade700));
      default:
        return ThemeData.light();
    }
  }

  void _toggleTemperatureUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
      if (_lastFetchedData != null) {
        _weatherInfo = _parseForecastData(_lastFetchedData!);
      }
    });
  }

  void _fetchWeather(Map<String, dynamic> selection) {
    var weatherApi = Provider.of<WeatherApi>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    weatherApi
        .fetchWeatherForecast(selection['lat'], selection['lon'])
        .then((data) {
      setState(() {
        _lastFetchedData = data;
        _weatherInfo = _parseForecastData(data);
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _weatherInfo = "Failed to get weather forecast";
        _isLoading = false;
      });
    });
  }

  String _parseForecastData(Map<String, dynamic> data) {
    Map<String, List<double>> dailyTemperatures = {};

    for (var forecast in data['list']) {
      DateTime date = DateTime.parse(forecast['dt_txt']);
      String dateKey = '${date.year}-${date.month}-${date.day}';
      double temp = (forecast['main']['temp'] as num)
          .toDouble();
      if (!dailyTemperatures.containsKey(dateKey)) {
        dailyTemperatures[dateKey] = [];
      }
      dailyTemperatures[dateKey]?.add(temp);
    }

    DateTime today = DateTime.now();
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      DateTime date = today.add(Duration(days: i));
      String dateKey = '${date.year}-${date.month}-${date.day}';
      List<double> temps = dailyTemperatures[dateKey] ?? [];
      if (temps.isNotEmpty) {
        double avgTemp = temps.reduce((a, b) => a + b) / temps.length;
        double maxTemp = temps.reduce((a, b) => a > b ? a : b);
        double minTemp = temps.reduce((a, b) => a < b ? a : b);

        if (!_isCelsius) {
          avgTemp = _cToF(avgTemp);
          maxTemp = _cToF(maxTemp);
          minTemp = _cToF(minTemp);
        }

        buffer.writeln(
            '$dateKey - Avg Temp: ${avgTemp.roundToDouble()}°${_isCelsius ? 'C' : 'F'}, Max Temp: ${maxTemp.roundToDouble()}°${_isCelsius ? 'C' : 'F'}, Min Temp: ${minTemp.roundToDouble()}°${_isCelsius ? 'C' : 'F'}');
      } else {
        buffer.writeln('$dateKey - No data available');
      }
    }

    return buffer.toString();
  }

  double _cToF(double celsius) {
    return (celsius * 9 / 5 + 32);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: currentTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Weatherly',
            style: GoogleFonts.teko(
              textStyle:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return cities.where((Map<String, dynamic> city) {
                    return city['name']
                        .toString()
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: GoogleFonts.teko(
                        textStyle: const TextStyle(fontSize: 18)),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Search City',
                      labelStyle: GoogleFonts.teko(
                          textStyle: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<Map<String, dynamic>> onSelected,
                  Iterable<Map<String, dynamic>> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: 300,
                        height: 200,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                              0.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> option =
                                options.elementAt(index);

                            return ListTile(
                              title: Text(
                                option['name'],
                                style: GoogleFonts.teko(
                                    textStyle: const TextStyle(fontSize: 18)),
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                displayStringForOption: (Map<String, dynamic> option) =>
                    option['name'],
                onSelected: (Map<String, dynamic> selection) {
                  _fetchWeather(selection);
                },
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Click here to toggle temperature unit',
                          style: GoogleFonts.teko(
                            textStyle: const TextStyle(
                                color: Colors.blue, fontSize: 13),
                          ),
                          recognizer: _temperatureToggleRecognizer,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _weatherInfo,
                        style: GoogleFonts.teko(
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              bottom: 80,
              child: FloatingActionButton(
                onPressed: _toggleTheme,
                tooltip: 'Toggle Theme',
                child: const Icon(Icons.color_lens),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WeatherMapScreen(
                            weatherData: _lastFetchedData ?? {})),
                  );
                },
                tooltip: 'Show Map',
                child: const Icon(Icons.map),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 160,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserReportScreen(
                              cities: [],
                            )),
                  );
                },
                tooltip: 'Report Issue',
                child: const Icon(Icons.report_problem),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureToggleRecognizer.dispose();
    super.dispose();
  }

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
}
