class Product {
  String title;
  double price;

  Product(this.title, this.price);

  Product.fromJson(Map<String, dynamic> jsonObject){
    this.title = jsonObject['title'];
    this.price = jsonObject['price'];
  }
}