// @dart=2.9
// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  OrderModel({
    this.amount,
    this.arabicName,
    this.itemCount,
    this.balance,
    this.billAmount,
    this.totalDiscount,
    this.cardReceived,
    this.cashReceived,
    this.customerId,
    this.customerName,
    this.deliveryDate,
    this.items,
    this.oldBalance,
    this.orderId,
    this.qty,
    this.refNo,
    this.roundOff,
    this.salesType,
    this.settledBy,
    this.taxAmount,
    this.totalCess,
    this.totalGst,
    this.totalReceived,
    this.totalVat,
    this.updatedBy,
    this.updatedTime,
    this.voucherDate,
  });

  String amount;
  String arabicName;
  String itemCount;
  String balance;
  String billAmount;
  String totalDiscount;
  String cardReceived;
  String cashReceived;
  String customerId;
  String customerName;
  DateTime deliveryDate;
  List<Item> items;
  String oldBalance;
  String orderId;
  String qty;
  String refNo;
  String roundOff;
  String salesType;
  String settledBy;
  String taxAmount;
  String totalCess;
  String totalGst;
  String totalReceived;
  String totalVat;
  String updatedBy;
  DateTime updatedTime;
  DateTime voucherDate;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    amount: json["Amount"],
    arabicName: json["ArabicName"],
    itemCount: json["ItemCount"],
    balance: json["Balance"],
    billAmount: json["BillAmount"],
    totalDiscount: json["TotalDiscount"],
    cardReceived: json["CardReceived"],
    cashReceived: json["CashReceived"],
    customerId: json["CustomerID"],
    customerName: json["CustomerName"],
    deliveryDate: DateTime.parse(json["DeliveryDate"]),
    items: List<Item>.from(json["Items"].map((x) => Item.fromJson(x))),
    oldBalance: json["OldBalance"],
    orderId: json["OrderID"],
    qty: json["Qty"],
    refNo: json["RefNo"],
    roundOff: json["RoundOff"],
    salesType: json["SalesType"],
    settledBy: json["SettledBy"],
    taxAmount: json["TaxAmount"],
    totalCess: json["TotalCESS"],
    totalGst: json["TotalGST"],
    totalReceived: json["TotalReceived"],
    totalVat: json["TotalVAT"],
    updatedBy: json["UpdatedBy"],
    updatedTime: DateTime.parse(json["UpdatedTime"]),
    voucherDate: DateTime.parse(json["VoucherDate"]),
  );

  Map<String, dynamic> toJson() => {
    "Amount": amount,
    "ArabicName": arabicName,
    "ItemCount": itemCount,
    "Balance": balance,
    "BillAmount": billAmount,
    "TotalDiscount": totalDiscount,
    "CardReceived": cardReceived,
    "CashReceived": cashReceived,
    "CustomerID": customerId,
    "CustomerName": customerName,
    "DeliveryDate": "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
    "Items": List<dynamic>.from(items.map((x) => x.toJson())),
    "OldBalance": oldBalance,
    "OrderID": orderId,
    "Qty": qty,
    "RefNo": refNo,
    "RoundOff": roundOff,
    "SalesType": salesType,
    "SettledBy": settledBy,
    "TaxAmount": taxAmount,
    "TotalCESS": totalCess,
    "TotalGST": totalGst,
    "TotalReceived": totalReceived,
    "TotalVAT": totalVat,
    "UpdatedBy": updatedBy,
    "UpdatedTime": updatedTime.toIso8601String(),
    "VoucherDate": "${voucherDate.year.toString().padLeft(4, '0')}-${voucherDate.month.toString().padLeft(2, '0')}-${voucherDate.day.toString().padLeft(2, '0')}",
  };
}

class Item {
  Item({
    this.itemId,
    this.arabicNameForItem,
    this.cessAmount,
    this.code,
    this.discAmount,
    this.discPercentage,
    this.gstAmount,
    this.inclusiveRate,
    this.itemName,
    this.qty,
    this.rate,
    this.taxAmount,
    this.total,
    this.unit,
    this.updatedBy,
    this.updatedTime,
    this.vatAmount,
  });

  String itemId;
  String arabicNameForItem;
  String cessAmount;
  String code;
  String discAmount;
  String discPercentage;
  String gstAmount;
  String inclusiveRate;
  String itemName;
  String qty;
  String rate;
  String taxAmount;
  String total;
  String unit;
  String updatedBy;
  DateTime updatedTime;
  String vatAmount;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["ItemID"],
    arabicNameForItem: json["ArabicNameForItem"],
    cessAmount: json["CESSAmount"],
    code: json["Code"],
    discAmount: json["DiscAmount"],
    discPercentage: json["DiscPercentage"],
    gstAmount: json["GSTAmount"],
    inclusiveRate: json["InclusiveRate"],
    itemName: json["ItemName"],
    qty: json["Qty"],
    rate: json["Rate"],
    taxAmount: json["TaxAmount"],
    total: json["Total"],
    unit: json["Unit"],
    updatedBy: json["UpdatedBy"],
    updatedTime: DateTime.parse(json["UpdatedTime"]),
    vatAmount: json["VATAmount"],
  );

  Map<String, dynamic> toJson() => {
    "ItemID": itemId,
    "ArabicNameForItem": arabicNameForItem,
    "CESSAmount": cessAmount,
    "Code": code,
    "DiscAmount": discAmount,
    "DiscPercentage": discPercentage,
    "GSTAmount": gstAmount,
    "InclusiveRate": inclusiveRate,
    "ItemName": itemName,
    "Qty": qty,
    "Rate": rate,
    "TaxAmount": taxAmount,
    "Total": total,
    "Unit": unit,
    "UpdatedBy": updatedBy,
    "UpdatedTime": updatedTime.toIso8601String(),
    "VATAmount": vatAmount,
  };
}
