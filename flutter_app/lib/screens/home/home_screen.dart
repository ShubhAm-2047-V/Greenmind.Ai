import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/weather_provider.dart';
import '../weather/weather_detail_screen.dart';
import 'camera_capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final weather = Provider.of<WeatherProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset('assets/logo.png', errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: Colors.green)),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  lang.translate("GreenMind AI"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            
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
                                        weather.condition,
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
            ),
            
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.translate("Detect Plant Disease"),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lang.translate("Take a picture of the affected leaf to get instant analysis."),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraCaptureScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade800,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(lang.translate("Capture Image")),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.camera_alt, size: 60, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
