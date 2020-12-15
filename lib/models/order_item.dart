class OrderItem {
  String productName;
  double quantity;
  double originalPrice;
  double wholesalePrice;
  double sellingPrice;
  double deliveryPrice;

  OrderItem(
    this.productName,
    this.quantity,
    this.originalPrice,
    this.wholesalePrice,
    this.sellingPrice,
    this.deliveryPrice,
  );

  OrderItem.fromJson(Map<String, dynamic> map) {
    this.productName = map['productName'];
    this.quantity = map['quantity'];
    this.originalPrice = map['originalPrice'];
    this.wholesalePrice = map['wholesalePrice'];
    this.deliveryPrice = map['deliveryPrice'];
    this.sellingPrice = map['sellingPrice'];
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': this.productName,
      'quantity': this.quantity,
      'originalPrice': this.originalPrice,
      'wholesalePrice': this.wholesalePrice,
      'deliveryPrice': this.deliveryPrice,
      'sellingPrice': this.sellingPrice,
    };
  }
}
