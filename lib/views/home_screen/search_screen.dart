import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/product_controller.dart';
import 'package:flutter_emart1/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emart1/views/category_screen/item_details.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  final String? title;
  const SearchScreen({Key? key, this.title}) : super(key: key);
  void navigateToItemDetails(String title, dynamic data) {
    // Kiểm tra xem ProductController đã được khởi tạo chưa
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    // Điều hướng đến trang ItemDetails
    Get.to(() => ItemDetails(
      title: title,
      data: data,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: title!.text.color(darkFontGrey).make(),
      ),
      body: FutureBuilder(
          future: FirestoreServices.searchProducts(title),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!snapshot.hasData) {
              return Center(
                child: loadingIndicator(),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return "Không tìm thấy sản phẩm nào".text.makeCentered();
            } else {
              var data = snapshot.data!.docs;
              var filtered = data.where((element) =>
              element['p_name'] != null &&
                  element['p_name'].toString().toLowerCase().contains(title!.toLowerCase())
              ).toList();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, mainAxisExtent: 300),
                  children: List.generate(filtered.length, (index) => Column(
                    children: [
                      Image.network(
                          filtered[index]['p_imgs'][0],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover
                      ),
                      const Spacer(),
                      "${filtered[index]['p_name']}"
                          .text
                          .fontFamily(semibold)
                          .color(darkFontGrey)
                          .maxLines(2)
                          .overflow(TextOverflow.ellipsis)
                          .make(),
                      10.heightBox,
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(int.parse(filtered[index]['p_price']))
                          .text
                          .color(redColor)
                          .fontFamily(bold)
                          .size(15)
                          .make()
                    ],
                  )
                      .box
                      .white
                      .outerShadowMd
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .roundedSM
                      .padding(const EdgeInsets.all(12))
                      .make().onTap(() => navigateToItemDetails(
                      "${filtered[index]['p_name']}",
                      filtered[index]
                  ))),
                ),
              );
            }
          }),
    );
  }
}