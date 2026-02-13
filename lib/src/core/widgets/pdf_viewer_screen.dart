import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => pdfBytes,
        useActions: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: fileName,
        allowSharing: true,
        allowPrinting: true,
      ),
    );
  }
}
