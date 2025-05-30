import 'package:flutter_emart1/controllers/auth_controller.dart';
import 'package:flutter_emart1/views/home_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/widgets_common/applogo_widget.dart';
import 'package:flutter_emart1/widgets_common/bg_widget.dart';
import 'package:flutter_emart1/widgets_common/custom_textfield.dart';
import 'package:flutter_emart1/widgets_common/our_button.dart';
import 'package:flutter_emart1/controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  var controller = Get.put(AuthController());

  //text controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Column(
              children: [
                (context.screenHeight * 0.1).heightBox,
                applogoWidget(),
                10.heightBox,
                "Join the $appname".text.fontFamily(bold).white.size(22).make(),
                15.heightBox,
                Obx(() => Column(
                    children: [
                      customTextField(title: name, hint: nameHint, controller: nameController, isPass: false),
                      customTextField(title: email, hint: emailHint, controller: emailController, isPass: false),
                      customTextField(title: password, hint: passwordHint, controller: passwordController, isPass: true),
                      customTextField(title: retypePassword, hint: passwordHint, controller: passwordRetypeController, isPass: true),


                      Row(
                        children: [
                          Checkbox(
                          checkColor: whiteColor, // Màu dấu check (✓)
                          activeColor: redColor,
                              value: isCheck,
                              onChanged: (newValue){
                            setState(() {
                              isCheck = newValue;
                            });
                              },
                          ),
                          5.widthBox,

                          Expanded(
                            child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "I agree to the ",
                                      style: TextStyle(
                                        fontFamily: regular,
                                        color: fontGrey,
                                      )),
                                    TextSpan(
                                      text: termAndCond,
                                      style: TextStyle(
                                        fontFamily: regular,
                                        color: redColor,
                                      )),
                                    TextSpan(
                                        text: " & ",
                                        style: TextStyle(
                                          fontFamily: regular,
                                          color: fontGrey,
                                        )),
                                    TextSpan(
                                        text: privacyPolicy,
                                        style: TextStyle(
                                          fontFamily: regular,
                                          color: redColor,
                                        ))
                                  ]
                                ))
                          )
                        ]
                      ),
                      5.heightBox,
                      controller.isloading.value
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(redColor),
                      )
                          : ourButton(
                        color: isCheck == true ? redColor : lightGrey,
                        title: signup,
                        textColor: whiteColor,
                        onPress: () async {
                          if (isCheck == true) {
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                nameController.text.isEmpty) {
                              VxToast.show(context, msg: "Vui lòng điền đầy đủ thông tin");
                              return;
                            }

                            controller.isloading(true);
                            try {
                              final userCredential = await controller.signupMethod(
                                context: context,
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              if (userCredential != null) {
                                await controller.storeUserData(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  name: nameController.text,
                                );

                                controller.isloading(false);
                                VxToast.show(context, msg: loggedin);
                                Get.offAll(() => Home());
                              } else {
                                controller.isloading(false);
                                VxToast.show(context, msg: "Đăng ký thất bại");
                              }
                            } catch (e) {
                              controller.isloading(false);
                              VxToast.show(context, msg: e.toString());
                            }

                          } else {
                            VxToast.show(context, msg: "Bạn phải đồng ý với điều khoản.");
                          }
                        },
                      ).box.width(context.screenWidth - 50).make(),

                      10.heightBox,
                      RichText(text: TextSpan(
                        children: [
                          TextSpan(
                            text: alreadyHaveAccount,
                            style: TextStyle(fontFamily: bold, color: fontGrey),
                          ),
                          TextSpan(
                            text: login,
                            style: TextStyle(fontFamily: bold, color: redColor),
                          )
                        ],
                      ),
                      ).onTap((){
                        Get.back();
                      }),
                    ],
                  ).box.white.rounded.padding(EdgeInsets.all(16)).width(context.screenWidth - 70).shadowSm.make(),
                )
              ],
            ),
          ),
        ));
  }
}
