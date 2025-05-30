import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/services/firestore_services.dart';
import 'package:flutter_emart1/widgets_common/loading_indicator.dart';

class wishlistScreen extends StatelessWidget {
  const wishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Sản phẩm yêu thích".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getWishlist(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return "Wishlist is empty!".text.color(darkFontGrey).makeCentered();
          } else {
            var data = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Ảnh sản phẩm
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(5),
                          child: Image.network(
                            "${data[index]['p_imgs'][0]}",
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Thông tin sản phẩm
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "${data[index]['p_name']}".text
                                  .fontFamily(semibold)
                                  .maxLines(2)
                                  .overflow(TextOverflow.ellipsis)
                                  .size(16)
                                  .make(),
                              5.heightBox,
                              "${data[index]['p_price']}".numCurrency.text
                                  .color(redColor)
                                  .fontFamily(semibold)
                                  .make(),
                            ],
                          ),
                        ),

                        // Nút unlike (xoá khỏi wishlist)
                        IconButton(
                          icon: const Icon(Icons.favorite, color: redColor),
                          onPressed: () async {
                            await firestore
                                .collection(productsCollection)
                                .doc(data[index].id)
                                .set({
                              'p_wishlist': FieldValue.arrayRemove([currentUser!.uid])
                            }, SetOptions(merge: true));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),

    );
  }
}
