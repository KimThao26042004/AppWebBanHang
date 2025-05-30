import 'package:flutter_emart1/consts/consts.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentNavIndex = 0.obs;

  // Thêm username
  var username = ''.obs;

  var featuredList = [];

  var searchController = TextEditingController();

  // Hàm để load username từ Firestore
  void fetchUsername(String uid) async {
    var userDoc = await firestore.collection('user').doc(uid).get();
    username.value = userDoc['name'];
  }
}