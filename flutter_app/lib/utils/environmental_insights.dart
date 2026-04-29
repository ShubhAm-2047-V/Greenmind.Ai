class EnvironmentalInsights {
  
  static String getInsight(String disease, double temp, int humidity) {
    disease = disease.toLowerCase();
    
    // Default fallback insight
    String insight = "Maintain standard care. Keep monitoring the plant for any rapid changes.";

    if (disease.contains("blight") || disease.contains("fung") || disease.contains("rot")) {
      if (humidity > 75) {
        insight = "High humidity ($humidity%) strongly accelerates fungal growth like ${disease}. Ensure excellent air circulation and consider moving the plant to a drier area if possible.";
      } else if (humidity < 40) {
        insight = "Low humidity helps slow the spread of $disease. Continue to avoid getting the leaves wet when watering.";
      } else {
        insight = "Fungal infections like $disease thrive in moisture. Keep the leaves dry and ensure good ventilation.";
      }
    } 
    else if (disease.contains("bacteri")) {
      if (humidity > 70 && temp > 25) {
        insight = "Warm ($temp°C) and humid ($humidity%) conditions are highly favorable for bacterial spread. Isolate the plant immediately and avoid overhead watering.";
      } else {
        insight = "Bacterial infections spread easily through water splashing. Keep the foliage dry.";
      }
    }
    else if (disease.contains("healthy")) {
      if (temp > 35) {
        insight = "The plant is healthy, but extreme heat ($temp°C) can cause stress. Ensure adequate watering.";
      } else if (temp < 10) {
        insight = "The plant is healthy, but low temperatures ($temp°C) might slow growth or cause cold damage. Consider protecting it from drafts.";
      } else {
        insight = "Current weather conditions ($temp°C, $humidity% humidity) are generally favorable for maintaining plant health.";
      }
    }
    else {
      // Generic conditions based on weather
      if (temp > 32) {
        insight = "High temperatures ($temp°C) can cause additional stress to an infected plant. Ensure it has enough water and partial shade if outdoors.";
      } else if (humidity > 80) {
        insight = "Very high humidity ($humidity%) can exacerbate many plant diseases. Improve airflow around the plant.";
      }
    }

    return insight;
  }
}
