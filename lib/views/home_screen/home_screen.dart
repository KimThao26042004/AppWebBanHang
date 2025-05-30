import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/controllers/home_controller.dart';
import 'package:flutter_emart1/controllers/product_controller.dart';
import 'package:flutter_emart1/services/firestore_services.dart';
import 'package:flutter_emart1/views/category_screen/item_details.dart';
import 'package:flutter_emart1/views/home_screen/components/featured_button.dart';
import 'package:flutter_emart1/views/home_screen/search_screen.dart';
import 'package:flutter_emart1/widgets_common/home_buttons.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Tạo phương thức để xử lý việc điều hướng đến ItemDetails
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
    var controller = Get.find<HomeController>();

    return Container(
      color: lightGrey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 60,
                child: TextFormField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search).onTap((){
                      if (controller.searchController.text.isNotEmptyAndNotNull) {
                        Get.to(() => SearchScreen(
                          title: controller.searchController.text,
                        ));
                      }
                    }),
                    filled: true,
                    fillColor: whiteColor,
                    hintText: searchanything,
                    hintStyle: TextStyle(color: textfieldGrey),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              10.heightBox,

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      VxSwiper.builder(
                          itemCount: slidersList.length,
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          height: 150,
                          enlargeCenterPage: true,
                          itemBuilder: (context, index) {
                            return Image
                                .asset(
                              slidersList[index],
                              fit: BoxFit.fill,
                            )
                                .box
                                .rounded
                                .clip(Clip.antiAlias)
                                .margin(const EdgeInsets.symmetric(horizontal: 8))
                                .make();
                          }),

                      10.heightBox,
                      //deals buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                            2, (index) => homeButtons(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth / 2.5,
                          icon: index == 0 ? icTodaysDeal : icFlashDeal,
                          title: index == 0 ? todayDeal : flashsale,
                        )),
                      ),


                      //2nd swiper
                      10.heightBox,
                      //swiper brand
                      VxSwiper.builder(
                          itemCount: secondSlidersList.length,
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          height: 150,
                          enlargeCenterPage: true,
                          itemBuilder: (context, index) {
                            return Image
                                .asset(
                              secondSlidersList[index],
                              fit: BoxFit.fill,
                            )
                                .box
                                .rounded
                                .clip(Clip.antiAlias)
                                .margin(const EdgeInsets.symmetric(horizontal: 8))
                                .make();
                          }),

                      //category buttons
                      10.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                            3,
                                (index) => homeButtons(
                              height: context.screenHeight * 0.15,
                              width: context.screenWidth / 3.5,
                              icon: index == 0? icTopCategories : index == 1 ? icBrands : icTopSeller,
                              title: index == 0 ? newProduct : index == 1 ? brand : topSellers,
                            )),
                      ),

                      //featured categories
                      20.heightBox,

                      Align(
                          alignment: Alignment.centerLeft,
                          child: featuredCategories.text.color(darkFontGrey).size(18).fontFamily(semibold).make()),
                      20.heightBox,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              3,
                                  (index) => Column(
                                children: [
                                  featuredButton(icon: featuredListImages1[index], title: featuredTitles1[index]),
                                  10.heightBox,
                                  featuredButton(icon: featuredListImages2[index], title: featuredTitles2[index]),

                                ],
                              )),
                        ),
                      ),

                      //featured product

                      20.heightBox,

                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: const BoxDecoration(color: redColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            featuredProduct.text.white.fontFamily(bold).size(18).make(),
                            10.heightBox,
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: FutureBuilder(
                                  future: FirestoreServices.getFeaturedProducts(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: loadingIndicator(),
                                      );
                                    } else if (snapshot.data!.docs.isEmpty) {
                                      return "Không có sản phẩm nổi bật".text
                                          .white.makeCentered();
                                    } else {
                                      var featuredData = snapshot.data!.docs;
                                      return Row(
                                        // Trong Row của List.generate
                                        children: List.generate(featuredData.length, (index) =>
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Image.network(
                                                  featuredData[index]['p_imgs'][0],
                                                  width: 130,
                                                  height: 130,
                                                  fit: BoxFit.cover,
                                                ),
                                                10.heightBox,
                                                "${featuredData[index]['p_name']}"
                                                    .text
                                                    .fontFamily(semibold)
                                                    .color(darkFontGrey)
                                                    .size(14)
                                                    .maxLines(2)
                                                    .overflow(TextOverflow.ellipsis)
                                                    .softWrap(true)  // Đảm bảo text sẽ xuống dòng
                                                    .make(),
                                                10.heightBox,
                                                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                                    .format(int.parse(featuredData[index]['p_price']))
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
                                                .padding(const EdgeInsets.all(8))
                                                .width(150)  // Đặt chiều rộng cố định cho card
                                                .make().onTap(() => navigateToItemDetails(
                                                "${featuredData[index]['p_name']}",
                                                featuredData[index]
                                            ))
                                        ),
                                      );
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),

                      //third swiper
                      20.heightBox,
                      VxSwiper.builder(
                          itemCount: secondSlidersList.length,
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          height: 150,
                          enlargeCenterPage: true,
                          itemBuilder: (context, index) {
                            return Image
                                .asset(
                              secondSlidersList[index],
                              fit: BoxFit.fill,
                            )
                                .box
                                .rounded
                                .clip(Clip.antiAlias)
                                .margin(const EdgeInsets.symmetric(horizontal: 8))
                                .make();
                          }),

                      //all products section
                      20.heightBox,
                      Align(
                          alignment: Alignment.centerLeft,
                          child: allproducts.text.fontFamily(bold).color(darkFontGrey).size(18).make()),
                      20.heightBox,
                      StreamBuilder(
                          stream: FirestoreServices.allproducts(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return loadingIndicator();
                            } else{
                              var allproductsdata = snapshot.data!.docs;
                              return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: allproductsdata.length,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, mainAxisExtent: 300 ),
                                  itemBuilder: (context,index){
                                    return Column(
                                      children: [
                                        Image.network(
                                            allproductsdata[index]['p_imgs'][0],
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover
                                        ),
                                        const Spacer(),
                                        "${allproductsdata[index]['p_name']}"
                                            .text
                                            .fontFamily(semibold)
                                            .color(darkFontGrey)
                                            .maxLines(2)
                                            .overflow(TextOverflow.ellipsis)
                                            .make(),
                                        10.heightBox,
                                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                            .format(int.parse(allproductsdata[index]['p_price']))
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
                                        .padding(const EdgeInsets.all(12))
                                        .make().onTap(() => navigateToItemDetails(
                                        "${allproductsdata[index]['p_name']}",
                                        allproductsdata[index]
                                    ));
                                  });
                            }
                          })
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}