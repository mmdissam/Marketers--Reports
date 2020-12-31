class OrderItem {
  String productName;
  int quantity;
  int originalPrice;
  int wholesalePrice;
  int sellingPrice;
  int deliveryPrice;
  String comments;

  OrderItem(
    this.productName,
    this.quantity,
    this.originalPrice,
    this.wholesalePrice,
    this.sellingPrice,
    this.deliveryPrice,
    this.comments,
  );

  OrderItem.fromJson(Map<String, dynamic> map) {
    this.productName = map['productName'];
    this.quantity = map['quantity'];
    this.originalPrice = map['originalPrice'];
    this.wholesalePrice = map['wholesalePrice'];
    this.deliveryPrice = map['deliveryPrice'];
    this.sellingPrice = map['sellingPrice'];
    this.comments = map['comments'];
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': this.productName,
      'quantity': this.quantity,
      'originalPrice': this.originalPrice,
      'wholesalePrice': this.wholesalePrice,
      'deliveryPrice': this.deliveryPrice,
      'sellingPrice': this.sellingPrice,
      'comments': this.comments,
    };
  }
}
