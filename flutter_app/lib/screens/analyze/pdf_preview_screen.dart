import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final String languageCode;

  const PdfPreviewScreen({super.key, required this.resultData, this.languageCode = 'en'});

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    
    // Labels based on language
    Map<String, Map<String, String>> labels = {
      'en': {
        'plant': 'Plant:',
        'disease': 'Disease:',
        'confidence': 'Confidence:',
        'description': 'Description',
        'cause': 'Cause',
        'solution': 'Solution',
        'title': 'GreenMind AI - Analysis Report'
      },
      'hi': {
        'plant': 'पौधा:',
        'disease': 'बीमारी:',
        'confidence': 'आत्मविश्वास:',
        'description': 'विवरण',
        'cause': 'कारण',
        'solution': 'समाधान',
        'title': 'ग्रीनमाइंड एआई - विश्लेषण रिपोर्ट'
      },
      'mr': {
        'plant': 'रोप:',
        'disease': 'रोग:',
        'confidence': 'आत्मविश्वास:',
        'description': 'वर्णन',
        'cause': 'कारण',
        'solution': 'उपाय',
        'title': 'ग्रीनमाइंड एआई - विश्लेषण अहवाल'
      }
    };

    final currentLabels = labels[languageCode] ?? labels['en']!;

    // Load a font that supports Hindi (Devanagari)
    final hindiFont = await PdfGoogleFonts.notoSansDevanagariRegular();
    final hindiFontBold = await PdfGoogleFonts.notoSansDevanagariBold();
    final defaultStyle = pw.TextStyle(font: hindiFont);
    final boldStyle = pw.TextStyle(font: hindiFontBold, fontWeight: pw.FontWeight.bold);
    // Load the logo
    final logoImage = await imageFromAssetBundle('assets/logo.png');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(currentLabels['title']!, style: boldStyle.copyWith(fontSize: 24, color: PdfColors.green800)),
                  pw.Image(logoImage, width: 60),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _buildPdfRow(currentLabels['plant']!, resultData['plant'], boldStyle, defaultStyle),
              _buildPdfRow(currentLabels['disease']!, resultData['disease'], boldStyle, defaultStyle),
              _buildPdfRow(currentLabels['confidence']!, resultData['confidence'].toString(), boldStyle, defaultStyle),
              pw.SizedBox(height: 20),
              pw.Text(currentLabels['description']!, style: boldStyle.copyWith(fontSize: 18)),
              pw.Text(resultData['description'], style: defaultStyle),
              pw.SizedBox(height: 10),
              pw.Text(currentLabels['cause']!, style: boldStyle.copyWith(fontSize: 18)),
              pw.Text(resultData['cause'], style: defaultStyle),
              pw.SizedBox(height: 10),
              pw.Text(currentLabels['solution']!, style: boldStyle.copyWith(fontSize: 18)),
              pw.Text(resultData['solution'], style: defaultStyle),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfRow(String label, String value, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(width: 10),
          pw.Text(value, style: valueStyle),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, 'Analysis Report'),
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
