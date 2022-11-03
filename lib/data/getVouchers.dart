// ignore_for_file: file_names, import_of_legacy_library_into_null_safe, avoid_print

import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/ui_elements/bluetooth_print.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetVouchers {
  Future<void> getVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    if (await DataConnectionChecker().hasConnection) {
      await FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .child(User.database)
          .child("Vouchers")
          .child(User.vanNo)
          .once()
          .then(
        (DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          print(values);
          if(values!=null){
            values.forEach((key, values) {
              print("snapshot values from firebase ${snapshot.value}");
              if (key.toString() == "ReturnNumber") {
                User().updateReturn(int.parse(values.toString()));
              }
              if (key.toString() == "VoucherNumber") {
                User().updateVoucherNumber(int.parse(values.toString()));
              }
              if (key.toString() == "OrderNumber") {
                User().updateOrder(int.parse(values.toString()));
              }
              if (key.toString() == "CashReceiptVoucher") {
                User().updateCashReceipt(int.parse(values.toString()));
              }
            });
          }

        },
      );
      int v = prefs.getInt("vouchernumber");
      int o = prefs.getInt("ordernumber");
      int r = prefs.getInt("returnnumber");
      int c = prefs.getInt("cashnumber");

      User.voucherNumber = User.voucherStarting + (v + 1).toString();
      User.orderNumber = User.orderStarting + (o + 1).toString();
      User.returnNumber = User.returnStarting + (r + 1).toString();
      User.cashReceiptNumber = User.cashReceiptStarting + (c + 1).toString();
    } else {
      int v = prefs.getInt("vouchernumber");
      int o = prefs.getInt("ordernumber");
      int r = prefs.getInt("returnnumber");
      int c = prefs.getInt("cashnumber");

      User.voucherNumber = User.voucherStarting + (v + 1).toString();
      User.orderNumber = User.orderStarting + (o + 1).toString();
      User.returnNumber = User.returnStarting + (r + 1).toString();
      User.cashReceiptNumber = User.cashReceiptStarting + (c + 1).toString();
    }
  }
}
