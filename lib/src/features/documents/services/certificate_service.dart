import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

class CertificateService {
  /// Generate a Certificate PDF
  Future<Uint8List> generateCertificate({
    required String studentName,
    required String courseName,
    required String duration,
    required String date,
    required String certificateId,
    required String verificationUrl,
  }) async {
    final pdf = pw.Document();

    // Load fonts (Standard fonts to prevent parsing errors)
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Removed QR Image generation as we are using BarcodeWidget directly

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 5),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 10),
                pw.Text(
                  'CERTIFICATE',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 36,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'OF COMPLETION',
                  style: pw.TextStyle(font: fontBold, fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  studentName,
                  style: pw.TextStyle(font: fontBold, fontSize: 30),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'has successfully completed the course on',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  courseName,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 22,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Duration: $duration',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20), // Reduced from 40
                // Footer Row
                pw.Expanded(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Date Column
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            date,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Container(
                            width: 100,
                            height: 1,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Date',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      // QR Code Column
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 80,
                            height: 80,
                            padding: const pw.EdgeInsets.all(2),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                              color: PdfColors.white,
                            ),
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: verificationUrl,
                              drawText: false,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Scan to Verify',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'ID: ${certificateId.length > 8 ? certificateId.substring(0, 8) : certificateId}...',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),

                      // Signature Column
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Gokul Shree',
                            style: pw.TextStyle(font: font, fontSize: 18),
                          ),
                          pw.Container(
                            width: 100,
                            height: 1,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Director Signature',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Digitally Signed Document - Verified by Gokul Shree Architecture College',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // Removed _generateQrBytes as we are using BarcodeWidget directly

  /// Compute SHA-256 hash of document data
  String computeHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
