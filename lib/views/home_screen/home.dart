import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm import này để sử dụng SystemNavigator
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/home_controller.dart';
import 'package:flutter_emart1/views/cart_screen/cart_screen.dart';
import 'package:flutter_emart1/views/category_screen/category_screen.dart';
import 'package:flutter_emart1/views/home_screen/home_screen.dart';
import 'package:flutter_emart1/views/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_emart1/widgets_common/exit_dialog.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    if (currentUser != null) {
      controller.fetchUsername(currentUser!.uid);
    }

    var navBarItem = [
      BottomNavigationBarItem(icon: Image.asset(icHome, width: 26), label: home),
      BottomNavigationBarItem(icon: Image.asset(icCategories, width: 26), label: categories),
      BottomNavigationBarItem(icon: Image.asset(icCart, width: 26), label: cart),
      BottomNavigationBarItem(icon: Image.asset(icProfile, width: 26), label: account),
    ];

    var navBody = [
      const HomeScreen(),
      const CategoryScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        bool shouldExit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => exitDialog(context),
        ) ?? false;

        if (shouldExit) {
          // Thoát hoàn toàn khỏi ứng dụng thay vì quay lại màn hình trước đó
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Obx(() => Expanded(child: navBody.elementAt(controller.currentNavIndex.value))),
          ],
        ),
        bottomNavigationBar: Obx(
              () => BottomNavigationBar(
            currentIndex: controller.currentNavIndex.value,
            selectedItemColor: redColor,
            selectedLabelStyle: const TextStyle(fontFamily: semibold),
            type: BottomNavigationBarType.fixed,
            backgroundColor: whiteColor,
            items: navBarItem,
            onTap: (value) {
              controller.currentNavIndex.value = value;
            },
          ),
        ),
      ),
    );
  }
}