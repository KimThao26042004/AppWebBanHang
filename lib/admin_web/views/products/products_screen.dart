import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

final Map<String, List<String>> categoriesWithSubcategories = {
  'Thời trang nữ': ['Tất cả', 'Áo thun nữ', 'Áo sơ mi nữ', 'Áo giữ nhiệt nữ', 'Set đồ', 'Chân váy nữ', 'Đầm nữ'],
  'Thời trang nam': ['Tất cả', 'Áo khoác & Jacket', 'Áo sơ mi', 'Áo thun nam', 'Quần dài nam ', 'Quần nỉ nam', 'Đồ công sở'],
  'Thời trang trẻ em': ['Tất cả', 'Quần áo em bé', 'Áo trẻ em', 'Set đồ trẻ em', 'Quần trẻ em'],
  'Thời trang trung niên': ['Tất cả', 'Đầm trung niên', 'Set đồ trung niên'],
  'Trang sức': ['Tất cả', 'Vòng cổ', 'Vàng', 'Bông tai'],
  'Phụ kiện nam': ['Tất cả', 'Đồng hồ nam', 'Giày nam', 'Mũ nam'],
  'Phụ kiện nữ': ['Tất cả', 'Đồng hồ nữ', 'Giày nữ', 'Túi xách'],
};

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  CollectionReference get productsCollection =>
      FirebaseFirestore.instance.collection('products');

  Future<void> _showProductDialog(BuildContext context,
      {DocumentSnapshot? doc}) async {
    final isEdit = doc != null;

    final pNameCtrl =
    TextEditingController(text: isEdit ? doc!['p_name'] ?? '' : '');
    String? selectedCategory = isEdit ? doc!['p_category'] ?? null : null;
    String? selectedSubCategory = isEdit ? doc!['p_subcategory'] ?? null : null;
    final pQuantityCtrl = TextEditingController(
        text: isEdit ? (doc!['p_quantity']?.toString() ?? '') : '');
    final pPriceCtrl = TextEditingController(
        text: isEdit ? (doc!['p_price']?.toString() ?? '') : '');

    bool isFeatured = isEdit ? (doc!['is_featured'] ?? false) : false;

    List<String> subcategoriesForSelectedCategory = selectedCategory != null
        ? categoriesWithSubcategories[selectedCategory] ?? []
        : [];

    List<XFile> selectedImageFiles = [];

    List<String> oldImageUrls = isEdit && doc!['p_imgs'] != null
        ? List<String>.from(doc!['p_imgs'])
        : [];

    final picker = ImagePicker();

    Future<void> pickImages() async {
      if (kIsWeb) {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          selectedImageFiles = [pickedFile];
        }
      } else {
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          selectedImageFiles = pickedFiles;
        }
      }
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pNameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: categoriesWithSubcategories.keys
                      .map(
                        (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                      selectedSubCategory = null;
                      subcategoriesForSelectedCategory =
                      val != null ? categoriesWithSubcategories[val]! : [];
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSubCategory,
                  decoration: const InputDecoration(labelText: 'Phân loại'),
                  items: subcategoriesForSelectedCategory
                      .map(
                        (subcategory) => DropdownMenuItem(
                      value: subcategory,
                      child: Text(subcategory),
                    ),
                  )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSubCategory = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pQuantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá'),
                ),
                const SizedBox(height: 8),

                // Show old images if no new selected images
                if (selectedImageFiles.isEmpty && oldImageUrls.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: oldImageUrls
                        .map(
                          (url) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.network(
                            url,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                oldImageUrls.remove(url);
                              });
                            },
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),

                // Show selected images
                if (selectedImageFiles.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedImageFiles
                        .map(
                          (xfile) => kIsWeb
                          ? FutureBuilder<Uint8List>(
                        future: xfile.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return const SizedBox(
                                height: 80,
                                width: 80,
                                child: Center(
                                    child: Icon(Icons.error_outline)),
                              );
                            }
                          } else {
                            return const SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                        },
                      )
                          : Image.file(
                        File(xfile.path),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                        .toList(),
                  ),

                const SizedBox(height: 8),

                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Chọn ảnh'),
                  onPressed: () async {
                    await pickImages();
                    setState(() {});
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: isFeatured,
                      onChanged: (v) {
                        setState(() {
                          isFeatured = v ?? false;
                        });
                      },
                    ),
                    const Text('Nổi bật'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pName = pNameCtrl.text.trim();
                final pCategory = selectedCategory;
                final pSubCategory = selectedSubCategory;
                final pQuantity = int.tryParse(pQuantityCtrl.text.trim()) ?? 0;
                final pPrice = int.tryParse(pPriceCtrl.text.trim()) ?? 0;

                if (pName.isEmpty ||
                    pCategory == null ||
                    pSubCategory == null ||
                    pQuantity <= 0 ||
                    pPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập đủ thông tin hợp lệ')),
                  );
                  return;
                }

                // Upload new images & keep old ones
                List<String> uploadedImageUrls = List.from(oldImageUrls);

                if (selectedImageFiles.isNotEmpty) {
                  for (final xfile in selectedImageFiles) {
                    String fileName =
                        '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('product_images/$fileName');
                    UploadTask uploadTask;
                    if (kIsWeb) {
                      final bytes = await xfile.readAsBytes();
                      uploadTask = ref.putData(bytes);
                    } else {
                      uploadTask = ref.putFile(File(xfile.path));
                    }
                    final snapshot = await uploadTask;
                    final downloadUrl = await snapshot.ref.getDownloadURL();
                    uploadedImageUrls.add(downloadUrl);
                  }
                }

                if (isEdit) {
                  await productsCollection.doc(doc!.id).update({
                    'p_name': pName,
                    'p_category': pCategory,
                    'p_subcategory': pSubCategory,
                    'p_quantity': pQuantity,
                    'p_price': pPrice,
                    'is_featured': isFeatured,
                    'p_imgs': uploadedImageUrls,
                  });
                } else {
                  final newDoc = productsCollection.doc();
                  await newDoc.set({
                    'id': newDoc.id,
                    'p_name': pName,
                    'p_category': pCategory,
                    'p_subcategory': pSubCategory,
                    'p_quantity': pQuantity,
                    'p_price': pPrice,
                    'is_featured': isFeatured,
                    'p_sizes': [],
                    'p_colors': [],
                    'p_imgs': uploadedImageUrls,
                    'p_wishlist': [],
                  });
                }

                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _deleteProduct(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await productsCollection.doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quản lý sản phẩm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(context),
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
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text('Không có sản phẩm nào.'));

                final rows = docs.asMap().entries.map((e) {
                  final i = e.key;
                  final ds = e.value;
                  final d = ds.data()! as Map<String, dynamic>;

                  final pImgs = (d['p_imgs'] ?? []) as List<dynamic>;
                  final imgUrl = pImgs.isNotEmpty ? pImgs[0].toString() : '';

                  return DataRow(cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: imgUrl.isEmpty
                            ? const Icon(Icons.image_not_supported, size: 40)
                            : Image.network(imgUrl, fit: BoxFit.cover),
                      ),
                    ),
                    DataCell(Text(d['p_name'] ?? '')),
                    DataCell(Text(d['p_category'] ?? '')),
                    DataCell(Text(d['p_subcategory'] ?? '')),
                    DataCell(Text('${d['p_quantity'] ?? ''}')),
                    DataCell(Text('${d['p_price'] ?? ''}')),
                    DataCell(
                      Icon(
                        d['is_featured'] == true ? Icons.check : Icons.close,
                        color: d['is_featured'] == true ? Colors.green : Colors.red,
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _showProductDialog(context, doc: ds),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Sửa'),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _deleteProduct(context, ds.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Xóa'),
                      ),
                    ),
                  ]);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth,
                    ),
                    child: DataTable(
                      dataRowHeight: 60,
                      headingRowHeight: 56,
                      columnSpacing: 25,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.04,
                            child: const Text('STT'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.07,
                            child: const Text('Hình ảnh'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.2,
                            child: const Text('Tên sản phẩm'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.10,
                            child: const Text('Danh mục'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.10,
                            child: const Text('Phân loại'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.05,
                            child: const Text('Số lượng'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.07,
                            child: const Text('Giá'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: screenWidth * 0.04,
                            child: const Text('Nổi bật'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60,
                            child: const Text(''),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60,
                            child: const Text(''),
                          ),
                        ),
                      ],
                      rows: rows.map((row) {
                        final cells = row.cells;

                        final newCells = <DataCell>[
                          cells[0],
                          cells[1],
                          DataCell(
                            SizedBox(
                              width: screenWidth * 0.18,
                              child: Text(
                                cells[2].child is Text
                                    ? (cells[2].child as Text).data ?? ''
                                    : '',
                                style: const TextStyle(),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: screenWidth * 0.10,
                              child: Text(
                                cells[3].child is Text
                                    ? (cells[3].child as Text).data ?? ''
                                    : '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: screenWidth * 0.10,
                              child: Text(
                                cells[4].child is Text
                                    ? (cells[4].child as Text).data ?? ''
                                    : '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          ...cells.sublist(5),
                        ];
                        return DataRow(cells: newCells);
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
