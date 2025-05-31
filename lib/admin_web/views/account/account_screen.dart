import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  CollectionReference get usersCollection =>
      FirebaseFirestore.instance.collection('user');

  Future<void> _showAccountDialog(BuildContext context,
      {DocumentSnapshot? doc}) async {
    final isEdit = doc != null;
    final nameCtrl = TextEditingController(text: isEdit ? doc!['name'] : '');
    final emailCtrl = TextEditingController(text: isEdit ? doc!['email'] : '');
    final passwordCtrl = TextEditingController();
    String role = isEdit ? doc!['role'] ?? 'user' : 'user';

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isEdit ? 'Sửa tài khoản' : 'Thêm tài khoản mới'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ tên'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'user', child: Text('User')),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final pwd = passwordCtrl.text.trim();

                final nameHasNumber = RegExp(r'\d').hasMatch(name);
                final emailValid = RegExp(
                    r'^[\w\.\-]+@(gmail\.com|st\.utc2\.edu\.vn)$')
                    .hasMatch(email);

                if (name.isEmpty || email.isEmpty || (!isEdit && pwd.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
                  );
                  return;
                }
                if (nameHasNumber) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Họ tên không được chứa số')),
                  );
                  return;
                }
                if (!emailValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text('Email phải có định dạng @gmail.com hoặc @st.utc2.edu.vn')),
                  );
                  return;
                }

                try {
                  if (isEdit) {
                    final current = FirebaseAuth.instance.currentUser;

                    if (current != null && current.uid == doc!.id) {
                      // User đang chỉnh sửa chính mình
                      // Cập nhật mật khẩu nếu có
                      if (pwd.isNotEmpty) {
                        await current.reauthenticateWithCredential(
                          EmailAuthProvider.credential(
                              email: current.email!, password: pwd),
                        );
                        await current.updatePassword(pwd);
                      }
                      // Cập nhật email nếu thay đổi
                      if (email != current.email) {
                        await current.updateEmail(email);
                      }
                    } else {
                      // Đang chỉnh sửa user khác
                      if (pwd.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Không thể cập nhật mật khẩu người dùng khác')),
                        );
                        return;
                      }
                      if (email != doc!['email']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Không thể cập nhật email người dùng khác')),
                        );
                        return;
                      }
                    }

                    await usersCollection.doc(doc!.id).update({
                      'name': name,
                      'email': email,
                      'role': role,
                      // Không lưu password plaintext trong Firestore
                    });
                  } else {
                    // Thêm mới user
                    final uc = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                        email: email, password: pwd);
                    final uid = uc.user!.uid;
                    await usersCollection.doc(uid).set({
                      'id': uid,
                      'name': name,
                      'email': email,
                      'role': role,
                      // Không lưu password plaintext trong Firestore
                      'cart_count': '00',
                      'imageUrl': '',
                      'order_count': '00',
                      'wishlist_count': '00',
                    });
                  }
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await usersCollection.doc(docId).delete();
        // Nếu muốn xóa user trên Firebase Auth, cần backend hoặc admin SDK
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa tài khoản: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Danh sách tài khoản',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAccountDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.snapshots(),
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return Text('Lỗi: ${snap.error}');
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Text('Không có tài khoản nào.');
                }
                return SizedBox(
                  width: screenWidth,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 60,
                      headingRowHeight: 56,
                      columnSpacing: 25,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.04,
                            child: const Text('#'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.15,
                            child: const Text('Họ tên'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.22,
                            child: const Text('Email'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.18,
                            child: const Text('Mật khẩu'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.15,
                            child: const Text('Vai trò'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: const Text(''),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: const Text(''),
                          ),
                        ),
                      ],
                      rows: docs.asMap().entries.map((e) {
                        final i = e.key;
                        final d = e.value.data()! as Map<String, dynamic>;
                        final role = d['role'] ?? 'user';
                        return DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(d['name'] ?? '')),
                          DataCell(Text(d['email'] ?? '')),
                          DataCell(Text(d['password'] ?? '')),
                          DataCell(Text(role == 'admin' ? 'Admin' : 'User')),
                          DataCell(ElevatedButton(
                            onPressed: () =>
                                _showAccountDialog(context, doc: e.value),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Sửa'),
                          )),
                          DataCell(ElevatedButton(
                            onPressed: () => _deleteAccount(context, e.value.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Xóa'),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}