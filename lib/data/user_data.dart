// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:shared_preferences/shared_preferences.dart';

class User {
  static String name = "";
  static String vanNo = "";
  static String vanName = "";
  static String number = "";
  static String database = "";
  static String address = "";
  static String trno = "";
  static String imageUrl = "";
  static String companyName = "";
  static int decimals = 0;
  static String voucherStarting = vanName + vanNo + "S";
  static String orderStarting = vanName + vanNo + "O";
  static String returnStarting = vanName + vanNo + "R";
  static String cashReceiptStarting = vanName + vanNo + "C";
  static String voucherNumber = "";
  static String orderNumber = "";
  static String returnNumber = "";
  static String cashReceiptNumber = "";

  updateVoucherNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("vouchernumber", number);
  }

  updateOrder(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("ordernumber", number);
  }

  updateReturn(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("returnnumber", number);
  }

  updateCashReceipt(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("cashnumber", number);
  }

  addUser() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    prefs.setString("number", number);
    prefs.setString("vanNo", vanNo);
    prefs.setString("vanName", vanName);
    prefs.setString("database", database);
    prefs.setString("address", address);
    prefs.setString("trno", trno);
    prefs.setString("companyName", companyName);
    prefs.setInt("decimal", decimals);
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }
}
