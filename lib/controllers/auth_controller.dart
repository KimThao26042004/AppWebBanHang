import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/views/splash_screen/splash_screen.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  var isloading = false.obs;

  // Text controllers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Xác định trạng thái đăng nhập khi AuthController được khởi tạo
    checkAuthState();
  }

  // Kiểm tra trạng thái đăng nhập
  checkAuthState() {
    auth.authStateChanges().listen((User? user) {
      currentUser = user;
    });
  }

  // Login method
  Future<UserCredential?> loginMethod({context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      // Cập nhật currentUser ngay sau khi đăng nhập thành công
      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: "Đăng nhập thất bại: ${e.message}");
    }
    return userCredential;
  }

  // Signup method
  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Cập nhật currentUser ngay sau khi đăng ký thành công
      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // Storing data method
  Future<void> storeUserData({name, password, email}) async {
    try {
      if (currentUser != null) {
        DocumentReference store = firestore.collection(usersCollection).doc(currentUser!.uid);
        await store.set({
          'name': name,
          'password': password,
          'email': email,
          'imageUrl': "",
          'id': currentUser!.uid,
        });
      } else {
        print("Không thể lưu dữ liệu: currentUser là null");
      }
    } catch (e) {
      print("Lỗi khi lưu dữ liệu người dùng: $e");
    }
  }

  // Signout method
  Future<bool> signoutMethod(context) async {
    try {
      await auth.signOut();
      // Đặt currentUser về null sau khi đăng xuất
      currentUser = null;
      await Future.delayed(const Duration(milliseconds: 500)); // Đợi Firebase cập nhật trạng thái
      Get.offAll(() => const SplashScreen());
      return true;
    } catch (e) {
      VxToast.show(context, msg: e.toString());
      return false;
    }
  }
}