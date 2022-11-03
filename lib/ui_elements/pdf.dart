// ignore_for_file: public_member_api_docs
// @dart=2.9
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  const PdfView({Key key, this.widgets, this.img, this.widgets2})
      : super(key: key);

  final List<pw.Widget> widgets;
  final List<pw.Widget> widgets2;
  final pw.MemoryImage img;

  @override
  PrintState createState() => PrintState();
}

class PrintState extends State<PdfView> {
  var pdf;
  bool a = false;

  @override
  void initState() {
    pdf = pw.Document(
      compress: false,
      pageMode: PdfPageMode.fullscreen,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Invoice PDF"),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: PdfPreview(
          allowPrinting: true,
          allowSharing: true,
          build: (format) {
            return _generatePdf(format, context);
          },
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, BuildContext context1) async {
    if (!a) {
      pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (context) => [
                  pw.Container(
                      height: 400,
                      width: MediaQuery.of(context1).size.width + 800,
                      child: pw.Image(widget.img, fit: pw.BoxFit.fill)),
                  pw.Column(children: widget.widgets),
                ]),
      );
    }
    a = true;
    return pdf.save();
  }
}
