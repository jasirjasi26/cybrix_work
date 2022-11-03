// @dart=2.9
// ignore_for_file: prefer_const_constructors_in_immutables, avoid_single_cascade_in_expression_statements, prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, avoid_print, unused_import

import 'dart:convert';
import 'dart:ui';
import 'package:cybrix/ui_elements/pdf.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cybrix/ui_elements/bluetooth_print.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/ui_elements/bottom_navigation.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class VanPage extends StatefulWidget {
  VanPage(
      {Key key,
      this.customerName,
      this.date,
      this.voucherNumber,
      this.billAmount,
      this.back,
      this.customerCode,
      this.values})
      : super(key: key);

  final String date;
  final String customerName;
  final String voucherNumber;
  final String billAmount;
  final bool back;
  final String customerCode;
  final Map<String, dynamic> values;

  @override
  VanPageState createState() => VanPageState();
}

class VanPageState extends State<VanPage> {
  final GlobalKey globalKey = GlobalKey();
  final _screenshotController = ScreenshotController();
  final pdf = pw.Document();
  DatabaseReference reference;
  List<String> total = [];
  List<String> item = [];
  List<String> rate = [];
  List<String> qty = [];
  List<String> tax = [];
  List<dynamic> disc = [];
  List<dynamic> unit = [];
  String cash = "-";
  String card = "-";
  String roundOff = "-";
  String balance = "-";
  String totaltax = "-";
  String totalDisc = "-";
  String bill = "-";
  String generatedPdfFilePath;
  String totalBill = "-";
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  double totalReceived = 0;
  String billTime = "";
  int totalQty = 0;
  double totalQuantity = 0;

  //Uint8List bytes;
  bool printBill = false;
  bool isloading = false;
  String val = '';
  List<pw.Widget> widgets = [];
  List<pw.Widget> widgets2 = [];

  BytesBuilder bytesBuilder = BytesBuilder();

  qrdata() {
    // 1.Sellername
    bytesBuilder.addByte(1);
    List<int> sellerNameBytes = utf8.encode(User.companyName);
    bytesBuilder.addByte(sellerNameBytes.length);
    bytesBuilder.add(sellerNameBytes);

    // 2.VAT registration number of the seller.
    bytesBuilder.addByte(2);
    List<int> vatRegistrationbytes = utf8.encode(User.trno);
    bytesBuilder.addByte(vatRegistrationbytes.length);
    bytesBuilder.add(vatRegistrationbytes);

    // 3.Time stamp of the invoice (date and time).
    bytesBuilder.addByte(3);
    List<int> timeStambbytes = utf8.encode(widget.date);
    bytesBuilder.addByte(timeStambbytes.length);
    bytesBuilder.add(timeStambbytes);

    // 4.Invoice total (with VAT).
    bytesBuilder.addByte(4);
    List<int> invoiceTotalbytes = utf8.encode(bill);
    bytesBuilder.addByte(invoiceTotalbytes.length);
    bytesBuilder.add(invoiceTotalbytes);
    // 5.VAt total
    bytesBuilder.addByte(5);
    List<int> vatTotalbytes = utf8.encode(totaltax);
    bytesBuilder.addByte(vatTotalbytes.length);
    bytesBuilder.add(vatTotalbytes);
    Uint8List qrCodeAsBytes = bytesBuilder.toBytes();
    final Base64Encoder b64Encoder = Base64Encoder();
    return b64Encoder.convert(qrCodeAsBytes);
  }

  Future<bool> _capture() async {
    bool done;
    setState(() {
      done = false;
    });
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    final image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData.buffer.asUint8List();
    //
    //
    // RenderRepaintBoundary boundary1 =
    // globalKey1.currentContext.findRenderObject();
    // final image1 = await boundary1.toImage( pixelRatio: 4.0);
    // final byteData1 = await image1.toByteData(format: ImageByteFormat.png);
    // final bytes1 = byteData1.buffer.asUint8List();

    // RenderRepaintBoundary boundary2 =
    // globalKey2.currentContext.findRenderObject();
    // final image2 = await boundary2.toImage(pixelRatio: 4.0);
    // final byteData2 = await image2.toByteData(format: ImageByteFormat.png);
    // final bytes2 = byteData2.buffer.asUint8List();

    final tempDir = (await getTemporaryDirectory()).path;
    // final qrcodeFile = File('$tempDir/qr_code.png');
    // await qrcodeFile.writeAsBytes(bytes);

    // final qrcodeFile1 = File('$tempDir/image.png');
    // await qrcodeFile1.writeAsBytes(bytes1);

    final qrcodeFile2 = File('$tempDir/image1.png');
    await qrcodeFile2.writeAsBytes(bytes);
    setState(() {
      done = true;
    });
    return done;
  }

  takeBillPdf() async {
    setState(() {
      printBill = false;
    });
    final imageFile = await _screenshotController.capture(pixelRatio: 4.0);

    final image = pw.MemoryImage(
      File(imageFile.path).readAsBytesSync(),
    );

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          ); // Center
        }));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/" + "Invoice.pdf");
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles([file.path], text: "Shared " + widget.voucherNumber);
    return file;
  }

  Future<void> getBill() async {
    setState(() {
      isloading = true;
    });
    for (int i = 0; i < widget.values['Items'].length; i++) {
      setState(() {
        item.add(widget.values['Items'][i]['ItemName'].toString());
        qty.add(widget.values['Items'][i]['Qty']);
        unit.add(widget.values['Items'][i]['Unit']);
        tax.add(widget.values['Items'][i]['TaxAmount']);
        total.add(widget.values['Items'][i]['Total'].toString());
        rate.add(widget.values['Items'][i]['Rate'].toString());
      });
    }

    setState(() {
      cash = widget.values['CashReceived'].toString();
      card = widget.values['CardReceived'].toString();
      roundOff = widget.values['RoundOff'].toString();
      balance = widget.values['Balance'].toString();
      totaltax = widget.values['TaxAmount'].toString();
      bill = widget.values['Amount'].toString();
      totalDisc = widget.values['TotalDiscount'].toString();
      totalBill = widget.values['BillAmount'].toString();
      totalReceived = double.parse(cash) + double.parse(card);
      billTime = widget.values['UpdatedTime'].toString().substring(0, 19);
      //totalQty = qty.reduce((a, b) => a + b) as int;
    });

    setState(() {
      isloading = false;
    });
    //}
  }

  @override
  void initState() {
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);
    getBill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: WillPopScope(
        onWillPop: () async {
          if (widget.back) {
            return true;
          } else {
            return false;
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              isloading
                  ? Center(
                      child: Container(
                          height: 50,
                          width: 50,
                          child: Center(child: CircularProgressIndicator())))
                  : homeData(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.back
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: 100,
                height: 45,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BottomBar();
                    }));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.01, -0.72),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xff385194),
                          const Color(0xff182d66)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x80182d66),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 18,
                          color: const Color(0xfff7fdfd),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  homeData() {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              key: globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      User.companyName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5b5b5b),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Center(
                    child: Text(
                      User.address,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        color: const Color(0xff5b5b5b),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('Tax Invoice',
                        style: TextStyle(
                          fontSize: 14,
                        )),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VAT No : ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        User.trno,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          child:Image.network(User.imageUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:QrImage(
                          data: qrdata(),
                          version: QrVersions.auto,
                          size: 120.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Voucher Number : ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.voucherNumber,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Name :  ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.customerName,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Date :  ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.date,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Balance :  ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        balance,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Van No : ' + User.vanNo,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Driver : ' + User.number,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            RepaintBoundary(
              //key: globalKey1,
              child: Container(
                // height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[500],
                      child: Table(
                        columnWidths: {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(0.8),
                          4: FlexColumnWidth(1),
                          5: FlexColumnWidth(1),
                          6: FlexColumnWidth(1.5),
                        },
                        border: TableBorder.all(),
                        // Allows to add a border decoration around your table
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'SL NO',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'ITEM',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'UNIT',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'QTY',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'RATE',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'TAX',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'AMOUNT',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: List.generate(
                        item.length,
                        (index) => Table(
                            border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(0.8),
                              4: FlexColumnWidth(1),
                              5: FlexColumnWidth(1),
                              6: FlexColumnWidth(1.5),
                            },
                            // Allows to add a border decoration around your table
                            children: [
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    item[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    unit[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    qty[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    rate[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    tax[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    total[index],
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RepaintBoundary(
              //key: globalKey1,
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Bill',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            totalBill.toString(),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            totaltax,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RoundOff',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            roundOff,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            totalDisc.toString(),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Bill Amount',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 13,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            bill,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cash Received',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            cash,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card Received',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            card,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xff5b5b5b),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      automaticallyImplyLeading: widget.back ? true : false,
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: GestureDetector(
            onTap: () async{
              widgets.clear();
              RenderRepaintBoundary boundary =
              globalKey.currentContext.findRenderObject();
              final image = await boundary.toImage(pixelRatio: 3.0);
              final byteData = await image.toByteData(format: ImageByteFormat.png);
              final bytes = byteData.buffer.asUint8List();
              final image1 = pw.MemoryImage(bytes);

              widgets2.add(pw.Image(image1));

              widgets.add(pw.Table(border: pw.TableBorder.all(), columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(0.8),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1),
                6: pw.FlexColumnWidth(1.5),
              },
                  // Allows to add a border decoration around your table
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "SL NO",
                          style: pw.TextStyle(
                            //  fontFamily: 'Arial',
                            fontSize: 10,
                            //   color: Colors.black,
                          ),
                          // textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "ITEM",
                          style: pw.TextStyle(
                            // fontFamily: 'Arial',
                            fontSize: 10,
                            //color: Colors.black,
                          ),
                          // textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "UNIT",
                          style: pw.TextStyle(
                            //  fontFamily: 'Arial',
                            fontSize: 10,
                            //color: Colors.black,
                          ),
                          //textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "QTY",
                          style: pw.TextStyle(
                            //fontFamily: 'Arial',
                            fontSize: 10,
                            // color: Colors.black,
                          ),
                          // textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "RATE",
                          style: pw.TextStyle(
                            //fontFamily: 'Arial',
                            fontSize: 10,
                            //color: Colors.black,
                          ),
                          // textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "TAX",
                          style: pw.TextStyle(
                            //fontFamily: 'Arial',
                            fontSize: 10,
                            //color: Colors.black,
                          ),
                          //textAlign: TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          "TOTAL",
                          style: pw.TextStyle(
                            //fontFamily: 'Arial',
                            fontSize: 10,
                            //color: Colors.black,
                          ),
                          //textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                  ]));
              for (int i = 0; i < item.length; i++) {
                widgets
                    .add(pw.Table(border: pw.TableBorder.all(), columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(0.8),
                  4: pw.FlexColumnWidth(1),
                  5: pw.FlexColumnWidth(1),
                  6: pw.FlexColumnWidth(1.5),
                },
                        // Allows to add a border decoration around your table
                        children: [
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            (i + 1).toString(),
                            style: pw.TextStyle(
                              //  fontFamily: 'Arial',
                              fontSize: 10,
                              //   color: Colors.black,
                            ),
                            // textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            item[0],
                            style: pw.TextStyle(
                              // fontFamily: 'Arial',
                              fontSize: 10,
                              //color: Colors.black,
                            ),
                            // textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            unit[0],
                            style: pw.TextStyle(
                              //  fontFamily: 'Arial',
                              fontSize: 10,
                              //color: Colors.black,
                            ),
                            //textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            qty[0],
                            style: pw.TextStyle(
                              //fontFamily: 'Arial',
                              fontSize: 10,
                              // color: Colors.black,
                            ),
                            // textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            rate[0],
                            style: pw.TextStyle(
                              //fontFamily: 'Arial',
                              fontSize: 10,
                              //color: Colors.black,
                            ),
                            // textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            tax[0],
                            style: pw.TextStyle(
                              //fontFamily: 'Arial',
                              fontSize: 10,
                              //color: Colors.black,
                            ),
                            //textAlign: TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(
                            total[0],
                            style: pw.TextStyle(
                              //fontFamily: 'Arial',
                              fontSize: 10,
                              //color: Colors.black,
                            ),
                            //textAlign: TextAlign.left,
                          ),
                        ),
                      ]),
                    ]));
              }

              widgets.add(
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 20),
                  child: pw.Column(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Bill',
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                                // fontWeight: pw.FontWeight.bold,
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              totalBill.toString(),
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                //color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Tax',
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                //color: const Color(0xff5b5b5b),
                                //fontWeight: pw.FontWeight.bold,
                              ),
                              // textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              totaltax,
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'RoundOff',
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                //color: const Color(0xff5b5b5b),
                                //fontWeight: pw.FontWeight.bold,
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              roundOff,
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Discount',
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                //color: const Color(0xff5b5b5b),
                                //fontWeight: pw.FontWeight.bold,
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              totalDisc.toString(),
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                              ),
                              // textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0, top: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Net Bill Amount',
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 13,
                                // color: const Color(0xff5b5b5b),
                                fontWeight: pw.FontWeight.bold,
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              bill,
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                //color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Cash Received',
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                                //fontWeight: FontWeight.w500,
                              ),
                              // textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              cash,
                              style: pw.TextStyle(
                                //fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Card Received',
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                                //fontWeight: FontWeight.w500,
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            pw.Text(
                              card,
                              style: pw.TextStyle(
                                // fontFamily: 'Arial',
                                fontSize: 12,
                                // color: const Color(0xff5b5b5b),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => Print(
              //       billAmount: widget.billAmount,
              //       date: widget.date,
              //       voucherNumber: widget.voucherNumber,
              //       customerName: widget.customerName,
              //       customerCode: widget.customerCode,
              //     ),
              //   ),
              // );
              //_capture().then((value) => {
              //       if (value)
              //         {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => PdfView(
                              widgets: widgets,
                              widgets2:widgets2,
                              img:image1
                            ),
                          ),
                        );
                     // }
               //   });
            },
            child: Container(
              height: 18,
              width: 40,
              child: Image.asset(
                'assets/images/print.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        //   child: GestureDetector(
        //     onTap: () {
        //       takeBillPdf();
        //     },
        //     child: Container(
        //       height: 15,
        //       width: 25,
        //       child: Image.asset(
        //         'assets/images/pdf.png',
        //         fit: BoxFit.fill,
        //       ),
        //     ),
        //   ),
        // ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          },
          child: Icon(
            Icons.refresh,
            size: 35,
          ),
        ),
        SizedBox(
          width: 15,
        ),
      ],
      elevation: 1.0,
      titleSpacing: 0,
      toolbarHeight: 70,
    );
  }
}
