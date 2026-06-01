class EnvironmentalInsights {
  
  static String getInsight(String disease, double temp, int humidity, {String languageCode = 'en'}) {
    disease = disease.toLowerCase();
    
    // Default fallback insight
    Map<String, String> defaultInsights = {
      'en': "Maintain standard care. Keep monitoring the plant for any rapid changes.",
      'hi': "मानक देखभाल बनाए रखें। किसी भी तीव्र परिवर्तन के लिए पौधे की निगरानी करते रहें।",
      'mr': "नेहमीप्रमाणे काळजी घ्या. वनस्पतीमध्ये काही बदल होत आहेत का यावर लक्ष ठेवा.",
      'kn': "ಸಾಮಾನ್ಯ ಆರೈಕೆಯನ್ನು ಮುಂದುವರಿಸಿ. ಯಾವುದೇ ತ್ವರಿತ ಬದಲಾವಣೆಗಳಿಗಾಗಿ ಸಸ್ಯವನ್ನು ಮೇಲ್ವಿಚಾರಣೆ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಿ.",
      'te': "సాధారణ సంరక్షణను కొనసాగించండి. ఏదైనా వేగవంతమైన మార్పుల కోసం మొక్కను పర్యవేక్షిస్తూ ఉండండి.",
      'gu': "સામાન્ય સંભાળ જાળવો. છોડમાં કોઈ ઝડપી ફેરફારો માટે તેના પર નજર રાખો."
    };

    String insight = defaultInsights[languageCode] ?? defaultInsights['en']!;

    if (disease.contains("blight") || disease.contains("fung") || disease.contains("rot")) {
      if (humidity > 75) {
        Map<String, String> highHumid = {
          'en': "High humidity ($humidity%) strongly accelerates fungal growth like ${disease}. Ensure excellent air circulation.",
          'hi': "उच्च आर्द्रता ($humidity%) $disease जैसे कवक के विकास को दृढ़ता से तेज करती है। उत्कृष्ट वायु संचार सुनिश्चित करें।",
          'mr': "जास्त आर्द्रता ($humidity%) $disease सारख्या बुरशीच्या वाढीला गती देते. चांगली हवा खेळती राहील याची खात्री करा.",
          'kn': "ಹೆಚ್ಚಿನ ಆರ್ದ್ರತೆಯು ($humidity%) $disease ನಂತಹ ಶಿಲೀಂಧ್ರಗಳ ಬೆಳವಣಿಗೆಯನ್ನು ಬಲವಾಗಿ ವೇಗಗೊಳಿಸುತ್ತದೆ. ಉತ್ತಮ ಗಾಳಿಯ ಪ್ರಸರಣವನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.",
          'te': "అధిక తేమ ($humidity%) $disease వంటి శిలీంధ్రాల పెరుగుదలను బాగా వేగవంతం చేస్తుంది. అద్భుతమైన గాలి ప్రసరణను నిర్ధారించండి.",
          'gu': "વધારે ભેજ ($humidity%) $disease જેવી ફૂગના વિકાસને ઝડપી બનાવે છે. સારી હવા ઉજાસ સુનિશ્ચિત કરો."
        };
        insight = highHumid[languageCode] ?? highHumid['en']!;
      } else if (humidity < 40) {
        Map<String, String> lowHumid = {
          'en': "Low humidity helps slow the spread of $disease. Continue to avoid getting the leaves wet.",
          'hi': "कम आर्द्रता $disease के प्रसार को धीमा करने में मदद करती है। पानी देते समय पत्तियों को गीला करने से बचें।",
          'mr': "कमी आर्द्रता $disease चा प्रसार रोखण्यास मदत करते. पानांवर पाणी टाकणे टाळा.",
          'kn': "ಕಡಿಮೆ ಆರ್ದ್ರತೆಯು $disease ಹರಡುವಿಕೆಯನ್ನು ನಿಧಾನಗೊಳಿಸಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ. ಎಲೆಗಳನ್ನು ಒದ್ದೆ ಮಾಡುವುದನ್ನು ತಪ್ಪಿಸಿ.",
          'te': "తక్కువ తేమ $disease వ్యాప్తిని నెమ్మదింపజేయడానికి సహాయపడుతుంది. ఆకులు తడవకుండా జాగ్ర態పడండి.",
          'gu': "ઓછો ભેજ $disease નો ફેલાવો ધીમો કરવામાં મદદ કરે છે. પાંદડા ભીના ન થાય તેની કાળજી રાખો."
        };
        insight = lowHumid[languageCode] ?? lowHumid['en']!;
      } else {
        Map<String, String> normalHumid = {
          'en': "Fungal infections like $disease thrive in moisture. Keep the leaves dry.",
          'hi': "$disease जैसे कवक संक्रमण नमी में पनपते हैं। पत्तियों को सूखा रखें।",
          'mr': "$disease सारखे बुरशीजन्य संसर्ग ओलाव्यात वाढतात. पाने कोरडी ठेवा.",
          'kn': "$disease ನಂತಹ ಶಿಲೀಂಧ್ರಗಳ ಸೋಂಕುಗಳು ತೇವಾಂಶದಲ್ಲಿ ಹರಡುತ್ತವೆ. ಎಲೆಗಳನ್ನು ಒಣಗಿಸಿ ಇಡಿ.",
          'te': "$disease వంటి శిలీంధ్రాల ఇన్ఫెక్షన్లు తేమలో పెరుగుతాయి. ఆకులను పొడిగా ఉంచండి.",
          'gu': "$disease જેવા ફૂગના ચેપ ભેજમાં ફેલાય છે. પાંદડા સૂકા રાખો."
        };
        insight = normalHumid[languageCode] ?? normalHumid['en']!;
      }
    } 
    else if (disease.contains("bacteri")) {
      if (humidity > 70 && temp > 25) {
        Map<String, String> warmHumid = {
          'en': "Warm ($temp°C) and humid ($humidity%) conditions are highly favorable for bacterial spread. Isolate the plant immediately.",
          'hi': "गर्म ($temp°C) and आर्द्र ($humidity%) स्थितियां बैक्टीरिया के प्रसार के लिए बहुत अनुकूल हैं। पौधे को तुरंत अलग करें।",
          'mr': "उष्ण ($temp°C) आणि दमट ($humidity%) हवामान जीवाणूंच्या प्रसारासाठी अनुकूल आहे. रोप त्वरित वेगळे करा.",
          'kn': "ಬಿಸಿ ($temp°C) ಮತ್ತು ಆರ್ದ್ರ ($humidity%) ಪರಿಸ್ಥಿತಿಗಳು ಬ್ಯಾಕ್ಟೀರಿಯಾದ ಹರಡುವಿಕೆಗೆ ಅತ್ಯಂತ ಪೂರಕವಾಗಿವೆ. ಸಸ್ಯವನ್ನು ತಕ್ಷಣವೇ ಪ್ರತ್ಯೇಕಿಸಿ.",
          'te': "వేడి ($temp°C) మరియు తేమతో కూడిన ($humidity%) పరిస్థితులు బ్యాక్టీరియా వ్యాప్తికి చాలా అనుకూలం. మొక్కను వెంటనే వేరు చేయండి.",
          'gu': "ગરમ ($temp°C) અને ભેજવાળી ($humidity%) સ્થિતિ બેક્ટેરિયાના ફેલાવા માટે અનુકૂળ છે. છોડને તરત જ અલગ કરો."
        };
        insight = warmHumid[languageCode] ?? warmHumid['en']!;
      } else {
        Map<String, String> normalBact = {
          'en': "Bacterial infections spread easily through water splashing. Keep the foliage dry.",
          'hi': "बैक्टीरिया संक्रमण पानी के छींटों से आसानी से फैलता है। पत्तियों को सूखा रखें।",
          'mr': "जीवाणू संसर्ग पाण्याच्या शिंतोड्यांमुळे सहज पसरतो. पाने कोरडी ठेवा.",
          'kn': "ಬ್ಯಾಕ್ಟೀರಿಯಾದ ಸೋಂಕುಗಳು ನೀರಿನ ಹನಿಗಳ ಮೂಲಕ ಸುಲಭವಾಗಿ ಹರಡುತ್ತವೆ. ಎಲೆಗಳನ್ನು ಒಣಗಿಸಿ ಇಡಿ.",
          'te': "బ్యాక్టీరియా ఇన్ఫెక్షన్లు నీటి తుంపరల ద్వారా సులభంగా వ్యాప్తి చెందుతాయి. ఆకులను పొడిగా ఉంచండి.",
          'gu': "બેક્ટેરિયાનો ચેપ પાણીના છાંટાથી સરળતાથી ફેલાય છે. પાંદડા સૂકા રાખો."
        };
        insight = normalBact[languageCode] ?? normalBact['en']!;
      }
    }
    else if (disease.contains("healthy")) {
      if (temp > 35) {
        Map<String, String> hotHealthy = {
          'en': "The plant is healthy, but extreme heat ($temp°C) can cause stress. Ensure adequate watering.",
          'hi': "पौधा स्वस्थ है, लेकिन अत्यधिक गर्मी ($temp°C) तनाव पैदा कर सकती है। पर्याप्त पानी सुनिश्चित करें।",
          'mr': "रोप निरोगी आहे, परंतु प्रचंड उष्णतेमुळे ($temp°C) ताण येऊ शकतो. पुरेसे पाणी द्या.",
          'kn': "ಸಸ್ಯವು ಆರೋಗ್ಯಕರವಾಗಿದೆ, ಆದರೆ ಅತಿಯಾದ ಬಿಸಿಲು ($temp°C) ಒತ್ತಡವನ್ನು ಉಂಟುಮಾಡಬಹುದು. ಸಾಕಷ್ಟು ನೀರುಣಿಸುವುದನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.",
          'te': "మొక్క ఆరోగ్యంగా ఉంది, కానీ అధిక వేడి ($temp°C) ఒత్తిడిని కలిగిస్తుంది. తగినంత నీరు అందేలా చూడండి.",
          'gu': "છોડ તંદુરસ્ત છે, પરંતુ વધુ પડતી ગરમી ($temp°C) તાણ પેદા કરી શકે છે. પૂરતું પાણી આપવાનું સુનિશ્ચિત કરો."
        };
        insight = hotHealthy[languageCode] ?? hotHealthy['en']!;
      } else if (temp < 10) {
        Map<String, String> coldHealthy = {
          'en': "The plant is healthy, but low temperatures ($temp°C) might slow growth. Protect it from cold.",
          'hi': "पौधा स्वस्थ है, लेकिन कम तापमान ($temp°C) विकास को धीमा कर सकता है। इसे ठंड से बचाएं।",
          'mr': "रोप निरोगी आहे, परंतु कमी तापमानामुळे ($temp°C) वाढ खुंटू शकते. थंडीपासून संरक्षण करा.",
          'kn': "ಸಸ್ಯವು ಆರೋಗ್ಯಕರವಾಗಿದೆ, ಆದರೆ ಕಡಿಮೆ ತಾಪಮಾನವು ($temp°C) ಬೆಳವಣಿಗೆಯನ್ನು ನಿಧಾನಗೊಳಿಸಬಹುದು. ಚಳಿಯಿಂದ ರಕ್ಷಿಸಿ.",
          'te': "మొక్క ఆరోగ్యంగా ఉంది, కానీ తక్కువ ఉష్ణోగ్రతలు ($temp°C) వృద్ధిని నెమ్మదింపజేయవచ్చు. చలి నుండి రక్షించండి.",
          'gu': "છોડ તંદુરસ્ત છે, પરંતુ ઓછું તાપમાન ($temp°C) વિકાસને ધીમો કરી શકે છે. ઠંડીથી બચાવો."
        };
        insight = coldHealthy[languageCode] ?? coldHealthy['en']!;
      } else {
        Map<String, String> normalHealthy = {
          'en': "Current weather conditions ($temp°C, $humidity% humidity) are favorable for plant health.",
          'hi': "वर्तमान मौसम की स्थिति ($temp°C, $humidity% आर्द्रता) पौधे के स्वास्थ्य को बनाए रखने के लिए अनुकूल है।",
          'mr': "सध्याचे हवामान ($temp°C, $humidity% आर्द्रता) रोपाच्या वाढीसाठी अनुकूल आहे.",
          'kn': "ಪ್ರಸ್ತುತ ಹವಾಮಾನ ಪರಿಸ್ಥಿತಿಗಳು ($temp°C, $humidity% ಆರ್ದ್ರತೆ) ಸಸ್ಯದ ಆರೋಗ್ಯಕ್ಕೆ ಪೂರಕವಾಗಿವೆ.",
          'te': "ప్రస్తుత వాతావరణ పరిస్థితులు ($temp°C, $humidity% తేమ) మొక్కల ఆరోగ్యానికి అనుకూలంగా ఉన్నాయి.",
          'gu': "હાલની હવામાન પરિસ્થિતિઓ ($temp°C, $humidity% ભેજ) છોડના સ્વાસ્થ્ય માટે અનુકૂળ છે."
        };
        insight = normalHealthy[languageCode] ?? normalHealthy['en']!;
      }
    }
    else {
      if (temp > 32) {
        Map<String, String> hotInfected = {
          'en': "High temperatures ($temp°C) can cause additional stress to an infected plant. Ensure enough water and shade.",
          'hi': "उच्च तापमान ($temp°C) संक्रमित पौधे पर अतिरिक्त तनाव डाल सकता है। पर्याप्त पानी और छाया सुनिश्चित करें।",
          'mr': "जास्त तापमानामुळे ($temp°C) बाधित रोपावर ताण येऊ शकतो. सावली आणि पाण्याची व्यवस्था करा.",
          'kn': "ಹೆಚ್ಚಿನ ತಾಪಮಾನವು ($temp°C) ಸೋಂಕಿತ ಸಸ್ಯಕ್ಕೆ ಹೆಚ್ಚುವರಿ ಒತ್ತಡವನ್ನು ಉಂಟುಮಾಡಬಹುದು. ಸಾಕಷ್ಟು ನೀರು ಮತ್ತು ನೆರಳನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.",
          'te': "అధిక ఉష్ణోగ్రతలు ($temp°C) సోకిన మొక్కకు అదనపు ఒత్తిడిని కలిగిస్తాయి. తగినంత నీరు మరియు నీడను నిర్ధారించండి.",
          'gu': "વધુ તાપમાન ($temp°C) ચેપગ્રસ્ત છોડ પર વધારાનું દબાણ લાવી શકે છે. પૂરતું પાણી અને છાંયો આપો."
        };
        insight = hotInfected[languageCode] ?? hotInfected['en']!;
      } else if (humidity > 80) {
        Map<String, String> highHumidInfected = {
          'en': "Very high humidity ($humidity%) can exacerbate plant diseases. Improve airflow.",
          'hi': "बहुत अधिक आर्द्रता ($humidity%) कई पौधों की बीमारियों को बढ़ा सकती है। वायु संचार में सुधार करें।",
          'mr': "जास्त आर्द्रतेमुळे ($humidity%) रोगाचा प्रसार वाढू शकतो. हवा खेळती राहील याची काळजी घ्या.",
          'kn': "ಅತಿಯಾದ ಆರ್ದ್ರತೆಯು ($humidity%) ಸಸ್ಯದ ರೋಗಗಳನ್ನು ಉಲ್ಬಣಗೊಳಿಸಬಹುದು. ಗಾಳಿಯ ಚಲನೆಯನ್ನು ಸುಧಾರಿಸಿ.",
          'te': "చాలా ఎక్కువ తేమ ($humidity%) మొక్కల వ్యాధులను తీవ్రతరం చేస్తుంది. గాలి ప్రసరణను మెరుగుపరచండి.",
          'gu': "ખૂબ વધારે ભેજ ($humidity%) છોડના રોગોને વધારી શકે છે. હવાની અવરજવર સુધારો."
        };
        insight = highHumidInfected[languageCode] ?? highHumidInfected['en']!;
      }
    }

    return insight;
  }
}
