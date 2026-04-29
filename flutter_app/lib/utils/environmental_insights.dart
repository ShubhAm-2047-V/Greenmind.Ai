class EnvironmentalInsights {
  
  static String getInsight(String disease, double temp, int humidity, {bool isHindi = false}) {
    disease = disease.toLowerCase();
    
    // Default fallback insight
    String insight = isHindi 
      ? "मानक देखभाल बनाए रखें। किसी भी तीव्र परिवर्तन के लिए पौधे की निगरानी करते रहें।"
      : "Maintain standard care. Keep monitoring the plant for any rapid changes.";

    if (disease.contains("blight") || disease.contains("fung") || disease.contains("rot")) {
      if (humidity > 75) {
        insight = isHindi
          ? "उच्च आर्द्रता ($humidity%) $disease जैसे कवक के विकास को दृढ़ता से तेज करती है। उत्कृष्ट वायु संचार सुनिश्चित करें।"
          : "High humidity ($humidity%) strongly accelerates fungal growth like ${disease}. Ensure excellent air circulation.";
      } else if (humidity < 40) {
        insight = isHindi
          ? "कम आर्द्रता $disease के प्रसार को धीमा करने में मदद करती है। पानी देते समय पत्तियों को गीला करने से बचें।"
          : "Low humidity helps slow the spread of $disease. Continue to avoid getting the leaves wet.";
      } else {
        insight = isHindi
          ? "$disease जैसे कवक संक्रमण नमी में पनपते हैं। पत्तियों को सूखा रखें।"
          : "Fungal infections like $disease thrive in moisture. Keep the leaves dry.";
      }
    } 
    else if (disease.contains("bacteri")) {
      if (humidity > 70 && temp > 25) {
        insight = isHindi
          ? "गर्म ($temp°C) और आर्द्र ($humidity%) स्थितियां बैक्टीरिया के प्रसार के लिए बहुत अनुकूल हैं। पौधे को तुरंत अलग करें।"
          : "Warm ($temp°C) and humid ($humidity%) conditions are highly favorable for bacterial spread. Isolate the plant immediately.";
      } else {
        insight = isHindi
          ? "बैक्टीरिया संक्रमण पानी के छींटों से आसानी से फैलता है। पत्तियों को सूखा रखें।"
          : "Bacterial infections spread easily through water splashing. Keep the foliage dry.";
      }
    }
    else if (disease.contains("healthy")) {
      if (temp > 35) {
        insight = isHindi
          ? "पौधा स्वस्थ है, लेकिन अत्यधिक गर्मी ($temp°C) तनाव पैदा कर सकती है। पर्याप्त पानी सुनिश्चित करें।"
          : "The plant is healthy, but extreme heat ($temp°C) can cause stress. Ensure adequate watering.";
      } else if (temp < 10) {
        insight = isHindi
          ? "पौधा स्वस्थ है, लेकिन कम तापमान ($temp°C) विकास को धीमा कर सकता है। इसे ठंड से बचाएं।"
          : "The plant is healthy, but low temperatures ($temp°C) might slow growth. Protect it from cold.";
      } else {
        insight = isHindi
          ? "वर्तमान मौसम की स्थिति ($temp°C, $humidity% आर्द्रता) पौधे के स्वास्थ्य को बनाए रखने के लिए अनुकूल है।"
          : "Current weather conditions ($temp°C, $humidity% humidity) are favorable for plant health.";
      }
    }
    else {
      if (temp > 32) {
        insight = isHindi
          ? "उच्च तापमान ($temp°C) संक्रमित पौधे पर अतिरिक्त तनाव डाल सकता है। पर्याप्त पानी और छाया सुनिश्चित करें।"
          : "High temperatures ($temp°C) can cause additional stress to an infected plant. Ensure enough water and shade.";
      } else if (humidity > 80) {
        insight = isHindi
          ? "बहुत अधिक आर्द्रता ($humidity%) कई पौधों की बीमारियों को बढ़ा सकती है। वायु संचार में सुधार करें।"
          : "Very high humidity ($humidity%) can exacerbate plant diseases. Improve airflow.";
      }
    }

    return insight;
  }
}
