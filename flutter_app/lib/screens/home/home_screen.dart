import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/weather_provider.dart';
import '../weather/weather_detail_screen.dart';
import 'camera_capture_screen.dart';
import '../../widgets/app_header.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final weather = Provider.of<WeatherProvider>(context);

    return Column(
      children: [
        const AppHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherDetailScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: weather.isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(10.0), child: CircularProgressIndicator()))
                        : weather.hasError
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Text(lang.translate("Weather unavailable"), style: const TextStyle(color: Colors.red)),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    onPressed: () => weather.fetchWeather(),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(weather.getWeatherIcon(), color: Colors.blue.shade500, size: 40),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${weather.temperature}°C",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                          ),
                                          Text(
                                            lang.translate(weather.condition),
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.water_drop, color: Colors.blue.shade400, size: 16),
                                          const SizedBox(width: 4),
                                          Text("${weather.humidity}%", style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(lang.translate("Humidity"), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 25),
                const HeroCard().animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
