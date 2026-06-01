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
                      gradient: LinearGradient(
                        colors: [const Color(0xFFFFFBEB).withOpacity(0.9), Colors.white.withOpacity(0.9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.shade200.withOpacity(0.15), 
                          blurRadius: 15, 
                          offset: const Offset(0, 5),
                        )
                      ],
                      border: Border.all(color: const Color(0xFFFDE68A).withOpacity(0.5), width: 1.5),
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
                                children: [
                                  // Left side (Temperature & Sun/Condition)
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        // Weather Icon (Sun has glowing warm color)
                                        Icon(
                                          weather.getWeatherIcon(), 
                                          color: weather.condition.toLowerCase().contains("clear") 
                                              ? Colors.amber.shade600 
                                              : Colors.blue.shade400, 
                                          size: 44,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${weather.temperature}°C",
                                              style: const TextStyle(
                                                fontSize: 20, 
                                                fontWeight: FontWeight.bold, 
                                                color: Color(0xFF0F172A), // Premium dark text
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              lang.translate(weather.condition),
                                              style: TextStyle(
                                                color: Colors.grey.shade600, 
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Vertical Divider
                                  Container(
                                    height: 35,
                                    width: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  
                                  // Right side (Humidity)
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.opacity, color: Color(0xFF2196F3), size: 30),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${weather.humidity}%", 
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            Text(
                                              lang.translate("Humidity"), 
                                              style: TextStyle(
                                                fontSize: 11, 
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
