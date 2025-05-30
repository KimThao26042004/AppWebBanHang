import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/controllers/product_controller.dart';
import 'package:flutter_emart1/widgets_common/our_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemDetails extends StatefulWidget {
  final String? title;
  final dynamic data;
  const ItemDetails({Key? key, required this.title, this.data}) : super(key: key);

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    // print(Colors.red.value);
    var controller = Get.find<ProductController>();
    controller.resetValues();
    controller.checkIfFav(widget.data);
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: widget.title!.text.color(darkFontGrey).fontFamily(bold).maxLines(1)
            .overflow(TextOverflow.ellipsis).make(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
          Obx(
                () => IconButton(
              onPressed: () {
                if (controller.isFav.value) {
                  controller.removeFromWishlist(widget.data.id, context);
                } else {
                  controller.addToWishlist(widget.data.id, context);
                }
              },
              icon:  Icon(
                  Icons.favorite_outlined,
                  color: controller.isFav.value ? redColor : darkFontGrey
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //swiper section

                      VxSwiper.builder(
                          autoPlay: true,
                          height: 350,
                          itemCount: widget.data['p_imgs'].length,
                          aspectRatio: 16/9,
                          viewportFraction: 1.0,
                          itemBuilder: (context, index) {
                            return Image.network(
                              widget.data['p_imgs'][index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }),
                      10.heightBox,
                      //title and details section
                      widget.title!.text.size(16).color(darkFontGrey).fontFamily(semibold).make(),
                      10.heightBox,
                      //rating
                      Row(
                        children: [
                          VxRating(
                            isSelectable: false,
                            value: double.parse(widget.data['p_rating']),
                            onRatingUpdate: (value) {},
                            normalColor: textfieldGrey,
                            selectionColor: golden,
                            count: 5,
                            maxRating: 5,
                            size: 25,
                          ),
                          8.widthBox,
                          "${widget.data['p_rating']}".text.fontFamily(semibold).underline.color(darkFontGrey).make(),
                        ],
                      ),

                      10.heightBox,
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(int.parse(widget.data['p_price'])).text.color(redColor).fontFamily(bold).size(18).make(),

                      10.heightBox,

                      Row(
                        children: [
                          Expanded(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "Thương hiệu".text.white.fontFamily(semibold).make(),
                              5.heightBox,
                              "${widget.data['p_seller']}".text.fontFamily(semibold).color(darkFontGrey).size(16).make()
                            ],
                          )),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.message_rounded, color: darkFontGrey),
                          ),
                        ],
                      ).box.height(60).padding(const EdgeInsets.symmetric(horizontal: 16)).color(textfieldGrey).make(),

                      //color section
                      20.heightBox,
                      Obx(
                            () => Column(
                          children: [
                            // COLOR
                            if (widget.data['p_colors'] != null && widget.data['p_colors'].isNotEmpty)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: "Màu sắc: ".text.color(textfieldGrey).make(),
                                  ),
                                  Row(
                                    children: List.generate(
                                      widget.data['p_colors'].length,
                                          (index) => Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          VxBox()
                                              .size(40, 40)
                                              .roundedFull
                                              .color(Color(widget.data['p_colors'][index]).withOpacity(1.0))
                                              .border(color: Colors.black, width: 1.5)
                                              .margin(const EdgeInsets.symmetric(horizontal: 4))
                                              .make()
                                              .onTap(() {
                                            controller.changeColorIndex(index);
                                          }),
                                          Visibility(
                                            visible: index == controller.colorIndex.value,
                                            child: Icon(
                                              Icons.done,
                                              color: widget.data['p_colors'][index] == 0xFFFFFFFF
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ).box.padding(const EdgeInsets.all(8)).make(),

                            // SIZE
                            if (widget.data['p_sizes'] != null && widget.data['p_sizes'].isNotEmpty)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: "Size: ".text.color(textfieldGrey).make(),
                                  ),
                                  Row(
                                    children: List.generate(
                                      widget.data['p_sizes'].length,
                                          (index) => VxBox(
                                        child: widget.data['p_sizes'][index]
                                            .toString()
                                            .text
                                            .color(controller.sizeIndex.value == index ? Colors.white : darkFontGrey)
                                            .makeCentered(),
                                      )
                                          .margin(const EdgeInsets.symmetric(horizontal: 4))
                                          .size(40, 40)
                                          .rounded
                                          .color(controller.sizeIndex.value == index ? darkFontGrey : Colors.transparent)
                                          .border(color: Colors.black, width: 1.5)
                                          .make()
                                          .onTap(() {
                                        controller.changeSizeIndex(index);
                                      }),
                                    ),
                                  )
                                ],
                              ).box.padding(const EdgeInsets.all(8)).make(),

                            // QUANTITY
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: "Số lượng: ".text.color(textfieldGrey).make(),
                                ),
                                Obx(
                                      () => Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            controller.decreaseQuantity();
                                            controller.calculateTotalPrice(int.parse(widget.data['p_price']));
                                          },
                                          icon: const Icon(Icons.remove)),
                                      controller.quantity.value.text
                                          .size(16)
                                          .color(darkFontGrey)
                                          .fontFamily(bold)
                                          .make(),
                                      IconButton(
                                          onPressed: () {
                                            controller.increaseQuantity(int.parse(widget.data['p_quantity']));
                                            controller.calculateTotalPrice(int.parse(widget.data['p_price']));
                                          },
                                          icon: const Icon(Icons.add)),
                                      0.widthBox,
                                      "(Số lượng còn ${widget.data['p_quantity']} )".text.color(textfieldGrey).make(),
                                    ],
                                  ),
                                )
                              ],
                            ).box.padding(const EdgeInsets.all(8)).make(),

                            // TOTAL
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: "Tổng tiền: ".text.color(textfieldGrey).make(),
                                ),
                                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                    .format(int.parse(controller.totalPrice.value.toString()))
                                    .text
                                    .color(redColor)
                                    .size(16)
                                    .fontFamily(bold)
                                    .make(),
                              ],
                            ).box.padding(const EdgeInsets.all(8)).make(),
                          ],
                        ).box.white.shadowSm.make(),
                      ),


                      //description section

                      10.heightBox,

                      "Mô tả".text.color(darkFontGrey).fontFamily(semibold).make(),
                      10.heightBox,
                      "${widget.data['p_desc']}".text.color(darkFontGrey).make(),

                      //buttons section
                      10.heightBox,

                      ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: List.generate(
                            itemDetailButtonList.length, (index) => ListTile(
                          title: itemDetailButtonList[index].text.fontFamily(semibold).color(darkFontGrey).make(),
                          trailing: const Icon(Icons.arrow_forward),

                        )
                        ),
                      ),
                      20.heightBox,

                      //products may like section

                      productsYouMayLike.text.fontFamily(bold).size(16).color(darkFontGrey).make(),
                      10.heightBox,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(6, (index) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                  imgP1,
                                  width: 130,
                                  fit: BoxFit.cover
                              ),
                              10.heightBox,
                              "Laptop 4GB/64GB".text.fontFamily(semibold).color(darkFontGrey).make(),
                              10.heightBox,
                              "₫ 1.800.000".text.color(redColor).fontFamily(bold).size(15).make()
                            ],
                          ).box.white.margin(const EdgeInsets.symmetric(horizontal: 4)).roundedSM.padding(const EdgeInsets.all(8)).make()),
                        ),
                      )

                    ],
                  ),
                ),),


            ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ourButton(
                color: redColor,
                onPress: () {
                  if (controller.quantity.value > 0) {
                    // Kiểm tra nếu có màu hoặc size
                    final hasColor = widget.data['p_colors'] != null && widget.data['p_colors'].isNotEmpty;
                    final hasSize = widget.data['p_sizes'] != null && widget.data['p_sizes'].isNotEmpty;

                    controller.addToCart(
                      color: hasColor ? widget.data['p_colors'][controller.colorIndex.value] : '',
                      size: hasSize ? widget.data['p_sizes'][controller.sizeIndex.value] : '',
                      price: widget.data['p_price'],
                      context: context,
                      vendorID: widget.data['vendor_id'],
                      img: widget.data['p_imgs'][0],
                      qty: controller.quantity.value,
                      sellername: widget.data['p_seller'],
                      title: widget.data['p_name'],
                      tprice: controller.totalPrice.value,
                    );

                    VxToast.show(context, msg: "Thêm thành công");
                  } else {
                    VxToast.show(context, msg: "Vui lòng chọn số lượng lớn hơn 0");
                  }
                },
                textColor: whiteColor,
                title: "Thêm vào giỏ hàng",
              ),
            )

          ],
        ),
      ),
    );
  }
}