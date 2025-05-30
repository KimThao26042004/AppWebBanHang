import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/product_controller.dart';
import 'package:flutter_emart1/services/firestore_services.dart';
import 'package:flutter_emart1/views/category_screen/item_details.dart';
import 'package:flutter_emart1/widgets_common/bg_widget.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CategoryDetail extends StatefulWidget {
  final String? title;
  const CategoryDetail({Key? key, required this.title}) : super(key: key);

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switchCategory(widget.title);
  }

  switchCategory(title) {
    if (title == "Tất cả") {
      // Use the parent category name, not "Tất cả"
      productMethod = FirestoreServices.getProducts(widget.title);
    } else if (controller.subcat.contains(title)) {
      // Subcategory products
      productMethod = FirestoreServices.getSubCategoryProducts(title);
    } else {
      // Category products
      productMethod = FirestoreServices.getProducts(title);
    }
  }

  var controller = Get.find<ProductController>();
  dynamic productMethod;
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ProductController>();

    return bgWidget(
      child: Scaffold(
        appBar: AppBar(title: widget.title!.text.fontFamily(bold).white.make()),
        body: Column(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  controller.subcat.length,
                      (index) => "${controller.subcat[index]}"
                      .text
                      .size(12)
                      .fontFamily(semibold)
                      .color(darkFontGrey)
                      .align(TextAlign.center)
                      .makeCentered()
                      .box
                      .white
                      .rounded
                      .size(120, 60)
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .make().onTap((){
                        switchCategory("${controller.subcat[index]}");
                        setState(() {
                        });
                      }),
                ),
              ),
            ),
            20.heightBox,

            StreamBuilder(
                stream: productMethod,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Expanded(
                      child: Center(
                        child: loadingIndicator(),
                      ),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Expanded(
                      child: "Hiện không có sản phẩm !".text.color(darkFontGrey).makeCentered(),
                    );
                  } else {
                    var data = snapshot.data!.docs;
                    return
                        Expanded(
                            child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: data.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 250, mainAxisSpacing: 8, crossAxisSpacing: 8),
                                itemBuilder: (context, index){
                                  return Column(
                                    children: [
                                      Image.network(
                                          data[index]['p_imgs'][0],
                                          height: 150,
                                          width: 200,
                                          fit: BoxFit.cover
                                      ),
                                      10.heightBox,
                                      "${data[index]['p_name']}"
                                          .text
                                          .fontFamily(semibold)
                                          .color(darkFontGrey)
                                          .maxLines(2)
                                          .overflow(TextOverflow.ellipsis)
                                          .make(),
                                      10.heightBox,
                                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                          .format(int.parse(data[index]['p_price']))
                                          .text
                                          .color(redColor)
                                          .fontFamily(bold)
                                          .size(15)
                                          .make()
                                    ],
                                  )
                                      .box
                                      .white
                                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                                      .roundedSM
                                      .outerShadowSm
                                      .padding(const EdgeInsets.all(12))
                                      .make()
                                      .onTap(() {
                                        controller.checkIfFav(data[index]);
                                    Get.to(() => ItemDetails(title: "${data[index]['p_name']}", data: data[index]));
                                  });
                                }));

                  }
                }),
          ],
        )
      ),
    );
  }
}
