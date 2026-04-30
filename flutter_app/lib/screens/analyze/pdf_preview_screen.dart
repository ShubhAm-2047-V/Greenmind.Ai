import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const PdfPreviewScreen({super.key, required this.resultData});

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    
    // Load a font that supports Hindi (Devanagari)
    final hindiFont = await PdfGoogleFonts.notoSansDevanagariRegular();
    final hindiFontBold = await PdfGoogleFonts.notoSansDevanagariBold();
    final defaultStyle = pw.TextStyle(font: hindiFont);
    final boldStyle = pw.TextStyle(font: hindiFontBold, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('GreenMind AI - Analysis Report', style: boldStyle.copyWith(fontSize: 24, color: PdfColors.green800)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _buildPdfRow('Plant:', resultData['plant'], boldStyle, defaultStyle),
              _buildPdfRow('Disease:', resultData['disease'], boldStyle, defaultStyle),
              _buildPdfRow('Confidence:', resultData['confidence'], boldStyle, defaultStyle),
              pw.SizedBox(height: 20),
              pw.Text('Description', style: boldStyle.copyWith(fontSize: 18)),
              pw.Text(resultData['description'], style: defaultStyle),
              pw.SizedBox(height: 10),
              pw.Text('Cause', style: boldStyle.copyWith(fontSize: 18)),
              pw.Text(resultData['cause'], style: defaultStyle),
              pw.SizedBox(height: 10),
              pw.Text('Solution', style: boldStyle.copyWith(fontSize: 18)),
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
