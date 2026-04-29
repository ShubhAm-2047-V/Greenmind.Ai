import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/language_provider.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate("Weather Details")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green.shade900,
      ),
      body: weather.isLoading
          ? const Center(child: CircularProgressIndicator())
          : weather.hasError
              ? Center(
                  child: Text(
                    "Could not load weather data.",
                    style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        weather.getWeatherIcon(),
                        size: 100,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${weather.temperature}°C",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherMetric(Icons.water_drop, "Humidity", "${weather.humidity}%"),
                            _buildWeatherMetric(Icons.thermostat, "Feels Like", "${weather.temperature + 1.5}°C"), // Dummy feels like
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.eco, color: Colors.green.shade700),
                                const SizedBox(width: 10),
                                Text(
                                  "General Plant Care",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getGeneralCareTip(weather.temperature, weather.humidity),
                              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 30),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  String _getGeneralCareTip(double temp, int humidity) {
    if (temp > 30 && humidity < 50) {
      return "It's hot and dry. Ensure your plants are watered frequently and consider misting indoor plants.";
    } else if (temp > 30 && humidity >= 50) {
      return "Hot and humid conditions favor rapid growth but also fungal diseases. Ensure good airflow.";
    } else if (temp < 15) {
      return "It's getting cold. Reduce watering frequency and protect sensitive plants from frost.";
    } else {
      return "Conditions are mild. Maintain standard watering and care routines.";
    }
  }
}
