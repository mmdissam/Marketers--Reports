class Report {
  String userId;
  DateTime history;
  String clientName;
  int phone;
  String productName;
  double quantity;
  double price;
  double deliveryPrice;
  double total;
  double netProfit;
  double sellingPrice;
  String comments;

  Report(
      this.userId,
      this.history,
      this.clientName,
      this.phone,
      this.productName,
      this.quantity,
      this.price,
      this.deliveryPrice,
      this.total,
      this.netProfit,
      this.sellingPrice,
      this.comments);

  Report.fromJson(Map<String, dynamic> map) {
    this.userId = map['user_id'];
    this.history = map['history'];
    this.clientName = map['clientName'];
    this.phone = map['phone'];
    this.productName = map['productName'];
    this.quantity = map['quantity'];
    this.price = map['price'];
    this.deliveryPrice = map['deliveryPrice'];
    this.total = map['total'];
    this.netProfit = map['netProfit'];
    this.sellingPrice = map['sellingPrice'];
    this.comments = map['comments'];
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': this.userId,
      'history': this.history,
      'clientName': this.clientName,
      'phone': this.phone,
      'productName': this.productName,
      'quantity': this.quantity,
      'price': this.price,
      'deliveryPrice': this.deliveryPrice,
      'total': this.total,
      'netProfit': this.netProfit,
      'sellingPrice': this.sellingPrice,
      'comments': this.comments,
    };
  }
}
