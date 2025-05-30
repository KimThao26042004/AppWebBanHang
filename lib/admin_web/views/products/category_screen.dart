import 'package:flutter/material.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/consts/strings.dart';
import 'productList_screen.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categorySubcategoryMap = {
      womenClothingFashion: featuredTitles1,
      menClothingFashion: featuredTitles2,
      childrenClothingFashion: featuredTitles3,
      middleAgedFashion: featuredTitles4,
      jewelery: featuredTitles5,
      menAccessories: featuredTitles6,
      womenAccessories: featuredTitles7
    };

    // Use images from featuredListImages for subcategories as a fallback
    final subcategoryImages = {
      // featuredTitles1
      womenDress: featuredListImages1[5], // imgS1
      handBag: featuredListImages1[1], // imgS2
      womenTshirts: featuredListImages1[2], // imgS3
      // featuredTitles2
      officeWear: featuredListImages2[0], // imgS4
      menPants: featuredListImages2[1], // imgS5
      necklace: featuredListImages2[2], // imgS6
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh mục sản phẩm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                final category = categoriesList[index];
                final image = categoriesImages[index];
                final subcategories = categorySubcategoryMap[category] ?? [];

                return ExpansionTile(
                  leading: Image.asset(
                    image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 40),
                  ),
                  title: Text(category),
                  children: subcategories.map((subcategory) {
                    final subImg = subcategoryImages[subcategory] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ListTile(
                        leading: subImg.isNotEmpty
                            ? Image.asset(
                          subImg,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 40),
                        )
                            : const Icon(Icons.image_not_supported, size: 40),
                        title: Text(subcategory),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductListPage(subcategory: subcategory),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}