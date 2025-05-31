import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/models/category_model.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  var quantity = 0.obs;
  var colorIndex = 0.obs;
  var sizeIndex = 0.obs;
  var totalPrice = 0.obs;

  var subcat = [];
  var subCatProducts = [].obs;

  var isFav = false.obs;

  getSubCategories(title) async {
    subcat.clear();
    var data = await rootBundle.loadString("lib/services/category_model.json");
    var decoded = categoryModelFromJson(data);
    var s = decoded.categories.where((element) => element.name == title).toList();

    for (var e in s[0].subcategory) {
      subcat.add(e);
    }
  }

  getProductsBySubcategory(String subcat) async {
    subCatProducts.clear();
    var snapshot = await firestore
        .collection(productsCollection)
        .where('p_subcategory', isEqualTo: subcat)
        .limit(10)
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data();
      data['id'] = doc.id; // ✅ Đúng
      subCatProducts.add(data);
    }

  }

  changeColorIndex(index) {
    colorIndex.value = index;
  }

  changeSizeIndex(index) {
    sizeIndex.value = index;
  }

  increaseQuantity(totalQuantity) {
    if (quantity.value < totalQuantity){
      quantity.value++;
    }
  }

  decreaseQuantity() {
    if (quantity.value > 0) {
      quantity.value--;
    }
  }

  calculateTotalPrice(price) {
    totalPrice.value = price * quantity.value;
  }

  addToCart({title, img, sellername, color, size, price, qty, tprice, context}) async {
    await firestore.collection(cartCollection).doc().set({
      'title': title,
      'img': img,
      'sellername': sellername,
      'color': color,
      'size': size,
      'qty': qty,
      // 'vendor_id': vendorID,
      'price': price,
      'tprice': tprice,
      'added_by': currentUser!.uid
    }).catchError((error) {
      VxToast.show(context, msg: error.toString());
    });
  }

  void resetValues() {
    quantity.value = 0;
    totalPrice.value = 0;
    colorIndex.value = 0;
    sizeIndex.value = 0;
    isFav.value = false;
  }

  addToWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayUnion([currentUser!.uid])
    }, SetOptions(merge: true));
    isFav(true);
    VxToast.show(context, msg: "Thêm vào yêu thích thành công");
  }

  removeFromWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayRemove([currentUser!.uid])
    }, SetOptions(merge: true));
    isFav(false);
    VxToast.show(context, msg: "Đã xóa khỏi yêu thích");

  }

  checkIfFav(data) async {
    if (data['p_wishlist'].contains(currentUser!.uid)) {
      isFav(true);
    } else {
      isFav(false);
    }
  }

}