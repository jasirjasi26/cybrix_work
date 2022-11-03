// @dart=2.9
// ignore_for_file: avoid_single_cascade_in_expression_statements, avoid_print, prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'package:cybrix/data/user_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

class Print extends StatefulWidget {
  const Print(
      {Key key,
      this.customerName,
      this.date,
      this.voucherNumber,
      this.billAmount,
      this.customerCode})
      : super(key: key);

  final String date;
  final String customerName;
  final String voucherNumber;
  final String billAmount;
  final String customerCode;

  @override
  PrintState createState() => PrintState();
}

class PrintState extends State<Print> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  String pathImage;
  DatabaseReference reference;
  List<String> total = [];
  List<String> item = [];
  List<String> rate = [];
  List<int> qty = [];
  List<String> tax = [];
  List<dynamic> disc = [];
  String cash = "-";
  String card = "-";
  String roundOff = "-";
  String balance = "-";
  String totaltax = "-";
  String totalDisc = "-";
  String bill = "-";
  String generatedPdfFilePath;
  String totalBill = "-";
  double totalReceived = 0;
  String billTime = "--";
  int totalQty = 0;
  Uint8List bytes;
  String company = "--";
  String companyTrno = "--";
  String companyAddress = "--";
  String name = "--";
  String customerName = "--";
  String customerCode = "--";
  String voucherNumber = "--";

  Future<void> getBill() async {
    ///load details of company
    ///
    setState(() {
      name = User.name == "" || User.name == null ? "--" : User.name;
      company = User.companyName == "" || User.companyName == null
          ? "--"
          : User.companyName;
      companyTrno = User.trno == "" || User.trno == null ? "--" : User.trno;
      companyAddress =
          User.address == "" || User.address == null ? "--" : User.address;
      customerName = widget.customerName == "" ? "--" : widget.customerName;
      customerCode = widget.customerCode == "" ? "--" : widget.customerCode;
      voucherNumber = widget.voucherNumber == "" ? "--" : widget.voucherNumber;
    });

    print("kk");
    print(name);
    print(company);
    print(customerCode);
    print(customerName);
    print(voucherNumber);
    print(companyTrno);
    print(companyAddress);

    reference
      ..child("Bills")
          .child(widget.date)
          .child(User.vanNo)
          .child(widget.voucherNumber)
          .child("Items")
          .once()
          .then((DataSnapshot snapshot) {
        List<dynamic> value = snapshot.value;
        for (int i = 0; i < value.length; i++) {
          if (value[i] != null) {
            setState(() {
              item.add(value[i]['ItemName'].toString());
              qty.add(value[i]['Qty']);
              tax.add(value[i]['TaxAmount'].toString());
              total.add(value[i]['Total'].toString());
              rate.add(value[i]['Rate'].toString());
              //totalDisc=totalDisc+double.parse(value[i]['DiscAmount'].toString());
            });
          }
        }
      });

    reference
        .child("Bills")
        .child(widget.date)
        .child(User.vanNo)
        .child(widget.voucherNumber)
        .once()
        .then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        setState(() {
          cash = values['CashReceived'].toString();
          card = values['CardReceived'].toString();
          roundOff = values['RoundOff'].toString();
          balance = values['Balance'].toString();
          totaltax = values['TaxAmount'].toString();
          bill = values['Amount'].toString();
          totalDisc = values['TotalDiscount'].toString();
          totalBill = values['BillAmount'].toString();
          totalReceived = double.parse(cash) + double.parse(card);
          billTime = values['UpdatedTime'].toString().substring(0, 19);
          totalQty = qty.reduce((a, b) => a + b);
        });
      });
    });
  }

  sample() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printNewLine();
        // bluetooth.printImageBytes(
        //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        bluetooth.printCustom(company, 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(companyAddress, 0, 1);
        bluetooth.printCustom("TRN No." + companyTrno, 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("TAX INVOICE", 2, 1);
        bluetooth.printCustom("-----------------------------", 0, 1);
        bluetooth.printCustom("Cust Name:" + customerName, 0, 0);
        bluetooth.printCustom("Cust Code:" + customerCode, 0, 1);
        bluetooth.printCustom("Invoice No: " + voucherNumber, 1, 1);
        bluetooth.printCustom("Address: ", 0, 1);
        bluetooth.printCustom("TRN No.11112223", 0, 1);
        bluetooth.printCustom("Date&Time: " + billTime, 0, 1);
        bluetooth.printCustom("Salesman:" + name, 0, 1);
        bluetooth.printCustom("-----------------------------", 0, 1);
        bluetooth.printCustom("Item Name           Qty   Amount", 0, 0);
        bluetooth.printCustom("-----------------------------", 0, 1);
        for (int i = 0; i < item.length; i++) {
          bluetooth.printLeftRight(item[i].toString(),
              qty[i].toString() + "    " + total[i].toString(), 0);
          bluetooth.printNewLine();
        }
        bluetooth.printCustom("-----------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Total Qty: " + totalQty.toString(), 0, 1);
        bluetooth.printCustom("Grand Total: " + bill, 0, 1);
        bluetooth.printCustom("Discount: " + totalDisc, 0, 1);
        bluetooth.printCustom("RoundOff: " + roundOff, 0, 1);
        bluetooth.printCustom("Vat (5%): " + totaltax, 0, 1);
        bluetooth.printCustom("Net Amount: " + totalBill, 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Cash: " + cash, 0, 1);
        bluetooth.printCustom("Card: " + card, 0, 1);
        bluetooth.printCustom(
            "Amount Received: " + totalReceived.toString(), 0, 1);
        bluetooth.printCustom("Current Balance: " + balance, 0, 1);
        bluetooth.printCustom("-----------------------------", 0, 1);
        bluetooth.printNewLine();
        // bluetooth.printCustom("Customers Signature :    ", 0,1);
        bluetooth.printNewLine();
        // bluetooth.printNewLine();
        // bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);
    getBill();
  }

  Future<void> initPlatformState() async {
    ///Loading image
    final ByteData data = await rootBundle.load('assets/images/logo.jpg');
    setState(() {
      bytes = data.buffer.asUint8List();
    });

    bool isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // ignore: todo
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        // case BlueThermalPrinter.DISCONNECT_REQUESTED:
        //   setState(() {
        //     _connected = false;
        //     print("bluetooth device state: disconnect requested");
        //   });
        //   break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          leading: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
              child: Icon(Icons.arrow_back)),
          //automaticallyImplyLeading: true,
          title: Text(
            "Print",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Container(
                height: 70,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_logo.png'),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Device:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: DropdownButton(
                      items: _getDeviceItems(),
                      onChanged: (value) => setState(() => _device = value),
                      value: _device,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.brown),
                    onPressed: () {
                      initPlatformState();
                    },
                    child: Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: _connected ? Colors.red : Colors.green),
                    onPressed: _connected ? _disconnect : _connect,
                    child: Text(
                      _connected ? 'Disconnect' : 'Connect',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              _connected
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.brown),
                        onPressed: () {
                          sample();
                        },
                        child: Text('PRINT',
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   new SnackBar(
    //     content: new Text(
    //       message,
    //       style: new TextStyle(
    //         color: Colors.white,
    //       ),
    //     ),
    //     duration: duration,
    //   ),
    // );
  }
}
