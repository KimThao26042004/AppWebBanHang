import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/controllers/cart_controller.dart';
import 'package:flutter_emart1/views/home_screen/home.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';
import 'package:flutter_emart1/widgets_common/our_button.dart';
import 'package:get/get.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();
    return SafeArea(
      child: Obx(() => Scaffold(
          backgroundColor: whiteColor,
          bottomNavigationBar: SizedBox(
            height: 50,
            child: controller.placingOrder.value
              ? Center(
              child: loadingIndicator(),
            )
              : ourButton(
              onPress: () async {
                await controller.placeMyOrder(
                    orderPaymentMethod: paymentMethods[controller.paymentIndex.value],
                    totalAmount: controller.totalP.value);
                await controller.clearCart();
                VxToast.show(context, msg: "Đặt hàng thành công");
                Get.offAll(Home());
              },
              color: redColor,
              textColor: whiteColor,
              title: "Thanh toán"
            ),
          ),
          appBar: AppBar(
            title: "Chọn phương thức thanh toán".text.fontFamily(semibold).color(darkFontGrey).make(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(
                  () => Column(
                children: List.generate(paymentMethods.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      controller.changePaymentIndex(index);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.paymentIndex.value == index ? redColor : Colors.transparent,
                          width: 4
                        )
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            paymentMethodsImg[index],
                            width: double.infinity,
                            height: 120,
                            colorBlendMode: controller.paymentIndex.value == index ? BlendMode.darken : BlendMode.color,
                            color: controller.paymentIndex.value == index
                                ? Colors.black.withAlpha((0.4 * 255).toInt())
                                : Colors.transparent,
                            fit: BoxFit.fill,
                          ),
                         controller.paymentIndex.value == index ? Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              activeColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              value: true,
                              onChanged: (value) {},
                            ),
                          ): Container(),
                          Positioned(
                              bottom: 10,
                              right: 10,
                              child: paymentMethods[index].text.white.fontFamily(bold).size(16).make(),
                          )
                        ],
                      ),
                    ),
                  );
                }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
