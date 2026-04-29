import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  
  // Weather Data
  double _temperature = 0.0;
  int _humidity = 0;
  String _condition = "Unknown";
  String _iconPath = "01d"; // OpenWeatherMap icon code format
  
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  double get temperature => _temperature;
  int get humidity => _humidity;
  String get condition => _condition;
  String get iconPath => _iconPath;

  WeatherProvider() {
    fetchWeather();
  }

  // --- BACKEND WEATHER CONFIG ---
  static const String _backendUrl = "https://greenmindaibackend.vercel.app/weather";
  static const String _cityName = "solapur"; 

  Future<void> fetchWeather() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final String url = "$_backendUrl?city=$_cityName";

    try {
      print("Weather: Fetching from backend for $_cityName...");
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // OpenWeatherMap response format remains the same, just relayed by backend
        _temperature = data['main']['temp'].toDouble();
        _humidity = data['main']['humidity'];
        _condition = data['weather'][0]['main'];
        _iconPath = data['weather'][0]['icon'];
        _hasError = false;
        print("Weather: Success via Backend! Temp: $_temperature");
      } else {
        _hasError = true;
        print("Weather: Backend Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      _hasError = true;
      print("Weather: Exception - $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get the correct Material Icon based on condition
  IconData getWeatherIcon() {
    if (_condition.toLowerCase().contains("cloud")) return Icons.cloud;
    if (_condition.toLowerCase().contains("rain")) return Icons.water_drop;
    if (_condition.toLowerCase().contains("clear")) return Icons.wb_sunny;
    if (_condition.toLowerCase().contains("snow")) return Icons.ac_unit;
    if (_condition.toLowerCase().contains("thunder")) return Icons.thunderstorm;
    return Icons.wb_twilight;
  }
}
