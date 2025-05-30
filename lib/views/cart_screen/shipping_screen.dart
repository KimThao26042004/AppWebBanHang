import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/cart_controller.dart';
import 'package:flutter_emart1/views/cart_screen/payment_method.dart';
import 'package:flutter_emart1/widgets_common/custom_textfield.dart';
import 'package:flutter_emart1/widgets_common/our_button.dart';
import 'package:get/get.dart';
class ShippingDetails extends StatelessWidget {
  const ShippingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: "Chọn địa chỉ nhận hàng".text.fontFamily(semibold).color(darkFontGrey).make(),
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          child: ourButton(
            onPress: () {
              Get.to(() => PaymentMethods());
            },
            color: redColor,
            textColor: whiteColor,
            title: "Tiếp tục",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              customTextField(isPass: false, title: "Họ và tên", controller: controller.nameController),
              customTextField(isPass: false, title: "Số điện thoại", controller: controller.phoneController),
              customTextField(isPass: false, title: "Tỉnh/Thành phố", controller: controller.cityController),
              customTextField(isPass: false, title: "Quận/Huyện", controller: controller.districtController),
              customTextField(isPass: false, title: "Tên đường, Tòa nhà, Số nhà,.", controller: controller.streetController),
          
            ],
          
          ),
        ),

      ),
    );
  }
}
