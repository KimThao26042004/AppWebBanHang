import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emart1/views/orders_screen/orders_details.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Đơn hàng".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: StreamBuilder(
          stream: FirestoreServices.getAllOrders(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: loadingIndicator(),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return "Bạn chưa có đơn hàng nào".text.color(darkFontGrey).makeCentered();
            } else {
              var data = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: "${index + 1}".text.fontFamily(bold).color(darkFontGrey).xl.make(),
                      title: data[index]['order_code'].toString().text.color(redColor).fontFamily(bold).make(),
                      subtitle: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(data[index]['totalAmount'])
                          .text
                          .fontFamily(bold)
                          .make(),
                      trailing: IconButton(
                          onPressed: () {
                            Get.to(() => OrderDetails(data: data[index]));
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: darkFontGrey,
                          )),
                    );
                  });
            }
          }),
    );
  }
}
