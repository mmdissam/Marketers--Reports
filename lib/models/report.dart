import 'package:marketers_reports/models/order_item.dart';

class Report {
  String userId;
  DateTime history;
  String clientName;
  int phone;
  bool orderReceived;
  // double total;
  // double netProfit;
  String comments;
  List<OrderItem> orderItem;

  Report(
    this.userId,
    this.history,
    this.clientName,
    this.phone,
    this.orderReceived,
    // this.total,
    // this.netProfit,
    this.comments,
    this.orderItem,
  );

  Report.fromJson(Map<String, dynamic> map) {
    this.userId = map['user_id'];
    this.history = map['history'];
    this.clientName = map['clientName'];
    this.phone = map['phone'];
    this.orderReceived = map['orderReceived'];
    // this.total = map['total'];
    // this.netProfit = map['netProfit'];
    this.comments = map['comments'];
    this.orderItem = map['order_item']
        .map<OrderItem>((item) => OrderItem.fromJson(item))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': this.userId,
      'history': this.history,
      'clientName': this.clientName,
      'phone': this.phone,
      'orderReceived': this.orderReceived,
      // 'total': this.total,
      // 'netProfit': this.netProfit,
      'comments': this.comments,
      'order_item': toJsonOrderItem(this.orderItem),
    };
  }

  static List<Map<String, dynamic>> toJsonOrderItem(
      List<OrderItem> orderItems) {
    List<Map<String, dynamic>> list = [];
    orderItems.forEach((element) {
      list.add(element.toMap());
    });
    return list;
  }
}
