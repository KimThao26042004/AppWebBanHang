import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  CollectionReference get ordersCollection =>
      FirebaseFirestore.instance.collection('orders');

  Future<void> _showEditDialog(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data()! as Map<String, dynamic>;

    bool orderConfirmed = data['order_confirmed'] ?? false;
    bool orderOnDelivery = data['order_on_delivery'] ?? false;
    bool orderDelivered = data['order_delivered'] ?? false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa trạng thái đơn hàng'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Đã xác nhận'),
                  value: orderConfirmed,
                  onChanged: (val) => setState(() => orderConfirmed = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Đang giao hàng'),
                  value: orderOnDelivery,
                  onChanged: (val) => setState(() => orderOnDelivery = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Đã giao hàng'),
                  value: orderDelivered,
                  onChanged: (val) => setState(() => orderDelivered = val ?? false),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ordersCollection.doc(doc.id).update({
                  'order_confirmed': orderConfirmed,
                  'order_on_delivery': orderOnDelivery,
                  'order_delivered': orderDelivered,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật thành công! Email thông báo đã được gửi.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi cập nhật đơn hàng: $e')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  String formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dateTime = ts.toDate();
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.95;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách đơn hàng',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('Không có đơn hàng nào.'));

                final rows = docs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final doc = entry.value;
                  final data = doc.data()! as Map<String, dynamic>;

                  return DataRow(cells: [
                    DataCell(Text('${i + 1}')), // STT
                    DataCell(Text(data['order_code'] ?? '')),
                    DataCell(Text(data['order_by_phone'] ?? '')),
                    DataCell(Text(data['recipient_name'] ?? '')),
                    DataCell(Text(formatDate(data['order_date'] as Timestamp?))),
                    DataCell(Text(data['shipping_method'] ?? '')),
                    DataCell(Text('${data['totalAmount'] ?? ''}')),
                    DataCell(Icon(
                      data['order_confirmed'] == true ? Icons.check : Icons.close,
                      color: data['order_confirmed'] == true ? Colors.green : Colors.red,
                    )),
                    DataCell(Icon(
                      data['order_on_delivery'] == true ? Icons.check : Icons.close,
                      color: data['order_on_delivery'] == true ? Colors.green : Colors.red,
                    )),
                    DataCell(Icon(
                      data['order_delivered'] == true ? Icons.check : Icons.close,
                      color: data['order_delivered'] == true ? Colors.green : Colors.red,
                    )),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _showEditDialog(context, doc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Sửa'),
                      ),
                    ),
                  ]);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: DataTable(
                      dataRowHeight: 60,
                      headingRowHeight: 56,
                      columnSpacing: 15,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04,
                            child: const Text('#'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.11,
                            child: const Text('Mã đơn hàng'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.11,
                            child: const Text('Số điện thoại'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.08,
                            child: const Text('Người nhận'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: const Text('Ngày tạo'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            child: const Text('Phương thức vận chuyển'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.08,
                            child: const Text('Tổng tiền'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: const Text('Xác nhận'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: const Text('Đang giao'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: const Text('Đã giao'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: const Text(''),
                          ),
                        ),
                      ],
                      rows: rows,
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
