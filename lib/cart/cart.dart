import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketers_reports/models/order_item.dart';

class Cart extends StatefulWidget {
  final List<OrderItem> listOrder;

  const Cart({Key key, this.listOrder}) : super(key: key);
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextStyle _textStyle =
      TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);

  TextStyle _textStylePirce = TextStyle(color: Colors.black87);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      bottomNavigationBar: bottomNavigationBar(),
      body: _rowOfCart(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        'الطلبيات',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Container bottomNavigationBar() {
    return Container(
      color: Colors.deepOrange,
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text('سعر البيع', style: _textStyle),
              subtitle: Text(
                calcSellingPrice().toString(),
                style: _textStylePirce,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('السعر الأصلي',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              subtitle: Text(
                calcOriginalPrice().toString(),
                style: _textStylePirce,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('سعر الجملة', style: _textStyle),
              subtitle: Text(
                calcWholesalePrice().toString(),
                style: _textStylePirce,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('ربح المسوّق', style: _textStyle),
              subtitle: Text(
                calcTotalNetProfit().toString(),
                style: _textStylePirce,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calcSellingPrice() {
    double sellingPrice = 0;
    for (var item in widget.listOrder) {
      sellingPrice += item.sellingPrice;
    }
    return sellingPrice;
  }

  double calcOriginalPrice() {
    double sellingPrice = 0;
    for (var item in widget.listOrder) {
      sellingPrice += item.originalPrice;
    }
    return sellingPrice;
  }

  double calcWholesalePrice() {
    double sellingPrice = 0;
    for (var item in widget.listOrder) {
      sellingPrice += item.wholesalePrice;
    }
    return sellingPrice;
  }

  double calcTotalNetProfit() {
    return calcSellingPrice() - calcWholesalePrice();
  }

  double calcNetProfit(int position) {
    return widget.listOrder[position].sellingPrice -
        widget.listOrder[position].wholesalePrice;
  }

  Widget _rowOfCart(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.listOrder.length,
        itemBuilder: (BuildContext context, int position) {
          return Column(
            children: <Widget>[
              Card(
                child: Container(
                  height: 90,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _columnOfReport(context, 'اسم الصنف',
                          widget.listOrder[position].productName),
                      _dividing(context),
                      _columnOfReport(context, 'الكمية',
                          widget.listOrder[position].quantity.toString()),
                      _dividing(context),
                      _columnOfReport(context, 'السعر الأصلي',
                          widget.listOrder[position].originalPrice.toString()),
                      _dividing(context),
                      _columnOfReport(context, 'سعر الجملة',
                          widget.listOrder[position].wholesalePrice.toString()),
                      _dividing(context),
                      _columnOfReport(context, 'سعر البيع',
                          widget.listOrder[position].sellingPrice.toString()),
                      _dividing(context),
                      _columnOfReport(context, 'ربح المسوّق',
                          calcNetProfit(position).toString()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _columnOfReport(BuildContext context, String title, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(context, title),
        Spacer(flex: 1),
        Text(details),
      ],
    );
  }

  Widget _title(BuildContext context, String title) {
    return RichText(
      text: TextSpan(
        text: '$title\n',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 12,
            fontFamily: GoogleFonts.cairo().fontFamily),
        children: <TextSpan>[
          TextSpan(
            text: '----------------',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _dividing(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 50,
      width: 1,
      color: Colors.black,
    );
  }
}
