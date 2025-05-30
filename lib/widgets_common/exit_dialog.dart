import 'package:flutter/material.dart';

// Hàm trả về widget ExitDialog
Widget exitDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Xác nhận thoát'),
    content: const Text('Bạn có chắc muốn thoát ứng dụng không?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Không'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Thoát'),
      ),
    ],
  );
}
