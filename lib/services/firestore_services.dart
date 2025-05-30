import 'package:flutter_emart1/consts/consts.dart';

class FirestoreServices {
  //get users data
  static getUser(uid) {
    return firestore.collection(usersCollection).where('id', isEqualTo: uid).snapshots();
  }

  //get products according to category
  static getProducts(category){
    return firestore.collection(productsCollection).where('p_category', isEqualTo: category).snapshots();
  }

  static getSubCategoryProducts(title){
    return firestore.collection(productsCollection).where('p_subcategory', isEqualTo: title).snapshots();
  }

  //get cart items for current user
  static getCart(uid) {
    return firestore.collection(cartCollection).where('added_by', isEqualTo: uid).snapshots();
  }

  //delete document
  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  //update cart quantity
  static updateCartQuantity(docId, qty, totalPrice) {
    return firestore.collection(cartCollection).doc(docId).update({
      'qty': qty,
      'tprice': totalPrice,
    });
  }

  static getAllOrders() {
    return firestore.collection(ordersCollection).where('order_by', isEqualTo: currentUser!.uid).snapshots();
  }

  static getWishlist() {
    return firestore
        .collection(productsCollection)
        .where('p_wishlist', arrayContains: currentUser!.uid)
        .snapshots();
  }

  // static getAllMessages() {
  //   return firestore.collection(chatsCollection).where('from_id', isEqualTo: currentUser!.uid).snapshots();
  // }
  static getCounts() async {
    var res = await Future.wait([
      firestore.collection(cartCollection).where('added_by', isEqualTo: currentUser!.uid).get().then((value) {
          return value.docs.length;
      }),
        firestore.collection(productsCollection).where('p_wishlist', arrayContains: currentUser!.uid).get().then((value) {
          return value.docs.length;
    }),
        firestore.collection(ordersCollection).where('order_by', isEqualTo: currentUser!.uid).get().then((value) {
          return value.docs.length;
      })
    ]);
    return res;
  }

  static allproducts() {
    return firestore.collection(productsCollection).snapshots();

  }

  static getFeaturedProducts() {
    return firestore.collection(productsCollection).where('is_featured', isEqualTo: true).get();
  }

  static searchProducts(title) {
    return firestore.collection(productsCollection).get();
  }

}