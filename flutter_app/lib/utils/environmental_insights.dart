class EnvironmentalInsights {
  
  static String getInsight(String disease, double temp, int humidity, {String languageCode = 'en'}) {
    disease = disease.toLowerCase();
    
    // Default fallback insight
    Map<String, String> defaultInsights = {
      'en': "Maintain standard care. Keep monitoring the plant for any rapid changes.",
      'hi': "मानक देखभाल बनाए रखें। किसी भी तीव्र परिवर्तन के लिए पौधे की निगरानी करते रहें।",
      'mr': "नेहमीप्रमाणे काळजी घ्या. वनस्पतीमध्ये काही बदल होत आहेत का यावर लक्ष ठेवा."
    };

    String insight = defaultInsights[languageCode] ?? defaultInsights['en']!;

    if (disease.contains("blight") || disease.contains("fung") || disease.contains("rot")) {
      if (humidity > 75) {
        Map<String, String> highHumid = {
          'en': "High humidity ($humidity%) strongly accelerates fungal growth like ${disease}. Ensure excellent air circulation.",
          'hi': "उच्च आर्द्रता ($humidity%) $disease जैसे कवक के विकास को दृढ़ता से तेज करती है। उत्कृष्ट वायु संचार सुनिश्चित करें।",
          'mr': "जास्त आर्द्रता ($humidity%) $disease सारख्या बुरशीच्या वाढीला गती देते. चांगली हवा खेळती राहील याची खात्री करा."
        };
        insight = highHumid[languageCode] ?? highHumid['en']!;
      } else if (humidity < 40) {
        Map<String, String> lowHumid = {
          'en': "Low humidity helps slow the spread of $disease. Continue to avoid getting the leaves wet.",
          'hi': "कम आर्द्रता $disease के प्रसार को धीमा करने में मदद करती है। पानी देते समय पत्तियों को गीला करने से बचें।",
          'mr': "कमी आर्द्रता $disease चा प्रसार रोखण्यास मदत करते. पानांवर पाणी टाकणे टाळा."
        };
        insight = lowHumid[languageCode] ?? lowHumid['en']!;
      } else {
        Map<String, String> normalHumid = {
          'en': "Fungal infections like $disease thrive in moisture. Keep the leaves dry.",
          'hi': "$disease जैसे कवक संक्रमण नमी में पनपते हैं। पत्तियों को सूखा रखें।",
          'mr': "$disease सारखे बुरशीजन्य संसर्ग ओलाव्यात वाढतात. पाने कोरडी ठेवा."
        };
        insight = normalHumid[languageCode] ?? normalHumid['en']!;
      }
    } 
    else if (disease.contains("bacteri")) {
      if (humidity > 70 && temp > 25) {
        Map<String, String> warmHumid = {
          'en': "Warm ($temp°C) and humid ($humidity%) conditions are highly favorable for bacterial spread. Isolate the plant immediately.",
          'hi': "गर्म ($temp°C) and आर्द्र ($humidity%) स्थितियां बैक्टीरिया के प्रसार के लिए बहुत अनुकूल हैं। पौधे को तुरंत अलग करें।",
          'mr': "उष्ण ($temp°C) आणि दमट ($humidity%) हवामान जीवाणूंच्या प्रसारासाठी अनुकूल आहे. रोप त्वरित वेगळे करा."
        };
        insight = warmHumid[languageCode] ?? warmHumid['en']!;
      } else {
        Map<String, String> normalBact = {
          'en': "Bacterial infections spread easily through water splashing. Keep the foliage dry.",
          'hi': "बैक्टीरिया संक्रमण पानी के छींटों से आसानी से फैलता है। पत्तियों को सूखा रखें।",
          'mr': "जीवाणू संसर्ग पाण्याच्या शिंतोड्यांमुळे सहज पसरतो. पाने कोरडी ठेवा."
        };
        insight = normalBact[languageCode] ?? normalBact['en']!;
      }
    }
    else if (disease.contains("healthy")) {
      if (temp > 35) {
        Map<String, String> hotHealthy = {
          'en': "The plant is healthy, but extreme heat ($temp°C) can cause stress. Ensure adequate watering.",
          'hi': "पौधा स्वस्थ है, लेकिन अत्यधिक गर्मी ($temp°C) तनाव पैदा कर सकती है। पर्याप्त पानी सुनिश्चित करें।",
          'mr': "रोप निरोगी आहे, परंतु प्रचंड उष्णतेमुळे ($temp°C) ताण येऊ शकतो. पुरेसे पाणी द्या."
        };
        insight = hotHealthy[languageCode] ?? hotHealthy['en']!;
      } else if (temp < 10) {
        Map<String, String> coldHealthy = {
          'en': "The plant is healthy, but low temperatures ($temp°C) might slow growth. Protect it from cold.",
          'hi': "पौधा स्वस्थ है, लेकिन कम तापमान ($temp°C) विकास को धीमा कर सकता है। इसे ठंड से बचाएं।",
          'mr': "रोप निरोगी आहे, परंतु कमी तापमानामुळे ($temp°C) वाढ खुंटू शकते. थंडीपासून संरक्षण करा."
        };
        insight = coldHealthy[languageCode] ?? coldHealthy['en']!;
      } else {
        Map<String, String> normalHealthy = {
          'en': "Current weather conditions ($temp°C, $humidity% humidity) are favorable for plant health.",
          'hi': "वर्तमान मौसम की स्थिति ($temp°C, $humidity% आर्द्रता) पौधे के स्वास्थ्य को बनाए रखने के लिए अनुकूल है।",
          'mr': "सध्याचे हवामान ($temp°C, $humidity% आर्द्रता) रोपाच्या वाढीसाठी अनुकूल आहे."
        };
        insight = normalHealthy[languageCode] ?? normalHealthy['en']!;
      }
    }
    else {
      if (temp > 32) {
        Map<String, String> hotInfected = {
          'en': "High temperatures ($temp°C) can cause additional stress to an infected plant. Ensure enough water and shade.",
          'hi': "उच्च तापमान ($temp°C) संक्रमित पौधे पर अतिरिक्त तनाव डाल सकता है। पर्याप्त पानी और छाया सुनिश्चित करें।",
          'mr': "जास्त तापमानामुळे ($temp°C) बाधित रोपावर ताण येऊ शकतो. सावली आणि पाण्याची व्यवस्था करा."
        };
        insight = hotInfected[languageCode] ?? hotInfected['en']!;
      } else if (humidity > 80) {
        Map<String, String> highHumidInfected = {
          'en': "Very high humidity ($humidity%) can exacerbate plant diseases. Improve airflow.",
          'hi': "बहुत अधिक आर्द्रता ($humidity%) कई पौधों की बीमारियों को बढ़ा सकती है। वायु संचार में सुधार करें।",
          'mr': "जास्त आर्द्रतेमुळे ($humidity%) रोगाचा प्रसार वाढू शकतो. हवा खेळती राहील याची काळजी घ्या."
        };
        insight = highHumidInfected[languageCode] ?? highHumidInfected['en']!;
      }
    }

    return insight;
  }
}
