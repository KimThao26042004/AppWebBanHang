import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/cart_controller.dart';
import 'package:flutter_emart1/views/cart_screen/payment_method.dart';
import 'package:flutter_emart1/widgets_common/custom_textfield.dart';
import 'package:flutter_emart1/widgets_common/our_button.dart';
import 'package:get/get.dart';

class ShippingDetails extends StatelessWidget {
  const ShippingDetails({super.key});

  // Hàm kiểm tra số điện thoại hợp lệ (chỉ số, từ 9 đến 11 chữ số)
  bool isValidPhone(String phone) {
    return RegExp(r'^\d{9,11}$').hasMatch(phone);
  }

  // Hiển thị dialog thông báo
  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Thông báo",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, color: redColor),
      middleText: message,
      textConfirm: "OK",
      confirmTextColor: whiteColor,
      buttonColor: redColor,
      onConfirm: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: "Chọn địa chỉ nhận hàng"
              .text
              .fontFamily(semibold)
              .color(darkFontGrey)
              .make(),
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          child: ourButton(
            onPress: () {
              if (controller.nameController.text.isEmpty ||
                  controller.phoneController.text.isEmpty ||
                  controller.cityController.text.isEmpty ||
                  controller.districtController.text.isEmpty ||
                  controller.streetController.text.isEmpty) {
                showErrorDialog("Vui lòng điền đầy đủ thông tin giao hàng");
              } else if (!isValidPhone(controller.phoneController.text)) {
                showErrorDialog("Số điện thoại không hợp lệ (chỉ chấp nhận 9-11 chữ số)");
              } else {
                Get.to(() => PaymentMethods());
              }
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
              customTextField(
                isPass: false,
                title: "Họ và tên",
                controller: controller.nameController,
              ),
              customTextField(
                isPass: false,
                title: "Số điện thoại",
                controller: controller.phoneController,
              ),
              customTextField(
                isPass: false,
                title: "Tỉnh/Thành phố",
                controller: controller.cityController,
              ),
              customTextField(
                isPass: false,
                title: "Quận/Huyện",
                controller: controller.districtController,
              ),
              customTextField(
                isPass: false,
                title: "Tên đường, Tòa nhà, Số nhà,.",
                controller: controller.streetController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}