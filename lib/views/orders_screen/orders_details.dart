import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/views/orders_screen/order_place_detail.dart';
import 'package:flutter_emart1/views/orders_screen/order_status.dart';
import 'package:intl/intl.dart';

class OrderDetails extends StatelessWidget {
  final dynamic data;
  const OrderDetails({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Order Details".text.fontFamily(semibold).make(),
      ),
      body: data == null
          ? Center(
        child: "No order data available".text.color(darkFontGrey).make(),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            orderStatus(
                color: redColor,
                icon: Icons.done,
                title: "Đặt hàng thành công",
                showDone: data['order_placed'] ?? false),
            orderStatus(
                color: Colors.blue,
                icon: Icons.thumb_up,
                title: "Đã xác nhận",
                showDone: data['order_confirmed'] ?? false),
            orderStatus(
                color: redColor,
                icon: Icons.car_crash,
                title: "Đang vận chuyển",
                showDone: data['order_on_delivery'] ?? false),
            orderStatus(
                color: redColor,
                icon: Icons.done_all_rounded,
                title: "Đã giao thành công",
                showDone: data['order_delivered'] ?? false),
            const Divider(),
            10.heightBox,
            Column(
              children: [
                // Modified orderPlaceDetails will be used by this screen
                orderPlaceDetails(
                    d1: data['order_code'] ?? "N/A",
                    d2: data['shipping_method'] ?? "N/A",
                    title1: "Mã đơn hàng",
                    title2: "Phương thức vận chuyển"),
                orderPlaceDetails(
                    d1: data['order_date'] != null
                        ? DateFormat().add_yMd().format((data['order_date'].toDate()))
                        : "N/A",
                    d2: data['payment_method'] ?? "N/A",
                    title1: "Ngày đặt hàng",
                    title2: "Phương thức thanh toán"),
                orderPlaceDetails(
                    d1: "Chưa thanh toán",
                    d2: "Đã đặt hàng",
                    title1: "Trạng thái thanh toán",
                    title2: "Tình trạng đơn hàng"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use Expanded for the first column to ensure it takes available space
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Thông tin giao hàng".text.fontFamily(semibold).make(),
                            "${data['recipient_name'] ?? 'N/A'}".text.make(),
                            "${data['order_by_address'] ?? 'N/A'}".text.make(),
                            "${data['order_by_phone'] ?? 'N/A'}".text.make(),
                          ],
                        ),
                      ),
                      // Add some spacing
                      const SizedBox(width: 10),
                      // Use Expanded for the second column as well
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Tổng số tiền".text.fontFamily(semibold).make(),
                            "${data['totalAmount'] ?? '0'}".text.color(redColor).fontFamily(bold).make(),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ).box.outerShadowMd.white.make(),

            const Divider(),
            10.heightBox,
            "Sản phẩm đã đặt".text.size(16).color(darkFontGrey).fontFamily(semibold).makeCentered(),
            10.heightBox,
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: List.generate(data['orders'].length, (index) {
                final order = data['orders'][index];
                final hasColor = order['color'] != null && order['color'].toString().isNotEmpty;
                final hasSize = order['size'] != null && order['size'].toString().isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use the modified orderPlaceDetails widget with null checks
                    orderPlaceDetails(
                      title1: order['title'] ?? "Sản phẩm",
                      title2: order['t_price'] ?? "0",
                      d1: "${order['qty'] ?? 0}x",
                      d2: "Trả hàng/hoàn tiền",
                    ),

                    // COLOR
                    if (hasColor)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            "Màu: ".text.make(),
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Color(order['color']),
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // SIZE
                    if (hasSize)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            "Size: ".text.make(),
                            "${order['size']}".text.semiBold.make(),
                          ],
                        ),
                      ),

                    const Divider(),
                  ],
                );
              }).toList(),
            ).box.outerShadowMd.white.margin(const EdgeInsets.only(bottom: 4)).make(),
          ],
        ),
      ),
    );
  }
}