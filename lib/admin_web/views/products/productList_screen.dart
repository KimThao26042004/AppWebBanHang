import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListPage extends StatelessWidget {
  final String subcategory;

  const ProductListPage({super.key, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    final productsCollection = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(title: Text('Sản phẩm: $subcategory')),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.where('p_subcategory', isEqualTo: subcategory).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('StreamBuilder error: ${snapshot.error}');
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Không có sản phẩm nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final name = data['p_name']?.toString() ?? '';
              final price = data['p_price']?.toString() ?? '';
              final images = (data['p_imgs'] as List<dynamic>?) ?? [];
              final imageUrl = images.isNotEmpty ? images[0].toString() : '';

              return ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 40),
                  )
                      : const Icon(Icons.image_not_supported, size: 40),
                ),
                title: Text(name),
                subtitle: Text('Giá: $price'),
              );
            },
          );
        },
      ),
    );
  }
}