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
      body: _testRow(context),
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
    double totalSellingPrice = 0;
    for (var item in widget.listOrder) {
      totalSellingPrice += item.sellingPrice;
    }
    return totalSellingPrice;
  }

  double calcOriginalPrice() {
    double totalOriginalPrice = 0;
    for (var item in widget.listOrder) {
      totalOriginalPrice += item.originalPrice;
    }
    return totalOriginalPrice;
  }

  double calcWholesalePrice() {
    double totalWholesalePrice = 0;
    for (var item in widget.listOrder) {
      totalWholesalePrice += item.wholesalePrice;
    }
    return totalWholesalePrice;
  }

  double calcTotalNetProfit() {
    return calcSellingPrice() - calcWholesalePrice();
  }

  double calcNetProfit(int position) {
    return (widget.listOrder[position].sellingPrice -
        widget.listOrder[position].wholesalePrice);
  }

  Widget _testRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataTextStyle: TextStyle(color: Colors.blueAccent),
        horizontalMargin: 16,
        columnSpacing: 16,
        sortAscending: true,
        columns: [
          DataColumn(
              label: _drawColumnTableProducts('الصنف'),
              numeric: false,
              tooltip: 'إسم الصنف'),
          DataColumn(
              label: _drawColumnTableProducts('الكمية'),
              numeric: true,
              tooltip: 'كمية الصنف المطلوبة'),
          DataColumn(
              label: _drawColumnTableProducts('السعر الأصلي'),
              numeric: true,
              tooltip: 'سعر الصنف الواحد الخاص بالتاجر'),
          DataColumn(
            label: _drawColumnTableProducts('سعر الجملة'),
            numeric: true,
            tooltip: 'سعر الجملة الخاص بالمسوّق',
          ),
          DataColumn(
            label: _drawColumnTableProducts('التوصيل'),
            numeric: true,
            tooltip: 'سعر التوصيل',
          ),
          DataColumn(
            label: _drawColumnTableProducts('التحصيل'),
            numeric: true,
            tooltip: 'مجموع التحصيل من هذا الصنف',
          ),
          DataColumn(
            label: _drawColumnTableProducts('ربح المسوّق'),
            numeric: true,
            tooltip: 'ربح المسوّق من هذا الصنف',
          ),
          DataColumn(
            label: _drawColumnTableProducts('تقرير'),
            numeric: false,
            tooltip: 'هل استلم أم لا',
          ),
        ],
        rows: widget.listOrder
            .map((orderItem) => DataRow(cells: [
                  DataCell(
                    Text(
                      orderItem.deliveryPrice.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    showEditIcon: true,
                    onTap: () {
                      setState(() {
                        widget.listOrder.remove(orderItem);
                      });
                    },
                  ),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                ]))
            .toList(),
      ),
    );
  }

  Widget _drawColumnTableProducts(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dataCellText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }

  // Widget _rowOfCart(BuildContext context) {
  //   return Container(
  //     child: ListView.builder(
  //       padding: EdgeInsets.all(16),
  //       itemCount: widget.listOrder.length,
  //       itemBuilder: (BuildContext context, int position) {
  //         return Column(
  //           children: <Widget>[
  //             Card(
  //               child: Container(
  //                 height: 90,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 child: ListView(
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  //                   scrollDirection: Axis.horizontal,
  //                   children: <Widget>[
  //                     _columnOfReport(context, 'اسم الصنف',
  //                         widget.listOrder[position].productName),
  //                     _dividing(context),
  //                     _columnOfReport(context, 'الكمية',
  //                         widget.listOrder[position].quantity.toString()),
  //                     _dividing(context),
  //                     _columnOfReport(context, 'السعر الأصلي',
  //                         widget.listOrder[position].originalPrice.toString()),
  //                     _dividing(context),
  //                     _columnOfReport(context, 'سعر الجملة',
  //                         widget.listOrder[position].wholesalePrice.toString()),
  //                     _dividing(context),
  //                     _columnOfReport(context, 'سعر البيع',
  //                         widget.listOrder[position].sellingPrice.toString()),
  //                     _dividing(context),
  //                     _columnOfReport(context, 'ربح المسوّق',
  //                         calcNetProfit(position).toString()),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _columnOfReport(BuildContext context, String title, String details) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       _title(context, title),
  //       Spacer(flex: 1),
  //       Text(details),
  //     ],
  //   );
  // }

//   Widget _title(BuildContext context, String title) {
//     return RichText(
//       text: TextSpan(
//         text: '$title\n',
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//             fontSize: 12,
//             fontFamily: GoogleFonts.cairo().fontFamily),
//         children: <TextSpan>[
//           TextSpan(
//             text: '----------------',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dividing(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5),
//       height: 50,
//       width: 1,
//       color: Colors.black,
//     );
//   }
}
