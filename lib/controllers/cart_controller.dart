import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartController extends GetxController {
  var totalP = 0.obs;

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var cityController = TextEditingController();
  var districtController = TextEditingController();
  var streetController = TextEditingController();

  var paymentIndex = 0.obs;
  late dynamic productSnapshot;
  var products = [];
  var placingOrder = false.obs;


  calculate(data) {
    totalP.value = 0;
    for (var i = 0; i < data.length; i++) {
      totalP.value = totalP.value + int.parse(data[i]['tprice'].toString());
    }
  }

  increaseQuantity(DocumentSnapshot doc) {
    int currentQty = doc['qty'] ?? 1;
    int price = int.parse(doc['price'].toString());

    int newQty = currentQty + 1;
    int totalPrice = price * newQty; // Calculate new total price

    // Update in Firestore
    firestore.collection(cartCollection).doc(doc.id).update({
      'qty': newQty,
      'tprice': totalPrice.toString(),
    });
  }

  decreaseQuantity(DocumentSnapshot doc) {
    int currentQty = doc['qty'] ?? 1;

    if (currentQty > 1) {
      int price = int.parse(doc['price'].toString());
      int newQty = currentQty - 1;
      int totalPrice = price * newQty; // Calculate new total price

      // Update in Firestore
      firestore.collection(cartCollection).doc(doc.id).update({
        'qty': newQty,
        'tprice': totalPrice.toString(),

      });
    }
  }

  changePaymentIndex(index) {
    paymentIndex.value = index;
  }
  placeMyOrder({required orderPaymentMethod, required totalAmount}) async {
    try {
      placingOrder(true);
      await getProductDetails();

      if (products.isEmpty) {
        placingOrder(false);
        Get.snackbar('Error', 'No products found in cart');
        return;
      }

      await firestore.collection(ordersCollection).doc().set({
        'order_code': "233981237",
        'order_date': FieldValue.serverTimestamp(),
        'order_by': currentUser!.uid,
        'order_by_name': Get.find<HomeController>().username.toString(),
        'order_by_address': '${streetController.text}, ${districtController.text}, ${cityController.text}',
        'order_by_phone': phoneController.text,
        'shipping_method': "SPX Express",
        'payment_method': orderPaymentMethod,
        'recipient_name': '${nameController.text}',
        'order_placed': true,
        'order_confirmed': false,
        'order_delivered': false,
        'order_on_delivery': false,
        'totalAmount': totalAmount,
        'orders': FieldValue.arrayUnion(products)
      });

      // Clear cart after successful order placement
      await clearCart();
      Get.snackbar('Success', 'Đặt hàng thành công');
    } catch (e) {
      Get.snackbar('Error', 'Đặt hàng bị lỗi: $e');
      print("Error placing order: $e");
    } finally {
      placingOrder(false);
    }
  }

  getProductDetails() {
    products.clear(); // Clear previous products first

    for (var i = 0; i < productSnapshot.length; i++) {
      try {
        // Using get() with optional default values to prevent null errors
        products.add({
          'color': productSnapshot[i].data().containsKey('color') ? productSnapshot[i]['color'] : '',
          'size': productSnapshot[i].data().containsKey('size') ? productSnapshot[i]['size'] : '',
          'img': productSnapshot[i].data().containsKey('img') ? productSnapshot[i]['img'] : '',
          'vendor_id': productSnapshot[i].data().containsKey('vendor_id') ? productSnapshot[i]['vendor_id'] : '',
          't_price': productSnapshot[i].data().containsKey('tprice') ? productSnapshot[i]['tprice'] : '0',
          'qty': productSnapshot[i].data().containsKey('qty') ? productSnapshot[i]['qty'] : 1,
          'title': productSnapshot[i].data().containsKey('title') ? productSnapshot[i]['title'] : 'Product'
        });
      } catch (e) {
        print("Error processing product at index $i: $e");
      }
    }
  }

  clearCart(){
    for (var i = 0; i < productSnapshot.length; i++) {
      firestore.collection(cartCollection).doc(productSnapshot[i].id).delete();
    }
  }
}