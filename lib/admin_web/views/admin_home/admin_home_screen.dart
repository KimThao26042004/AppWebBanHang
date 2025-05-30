import 'package:flutter/material.dart';
import 'package:flutter_emart1/admin_web/views/statistics/statistics_screen.dart';
import 'package:flutter_emart1/admin_web/views/products/products_screen.dart';
import 'package:flutter_emart1/admin_web/views/products/category_screen.dart';
import 'package:flutter_emart1/admin_web/views/order/order_screen.dart';
import 'package:flutter_emart1/admin_web/views/account/account_screen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _selected = 'Thống kê';

  Widget _buildBody() {
    switch (_selected) {
      case 'Thống kê':           return const StatisticsPage();
      case 'Sản phẩm':          return const ProductPage();
      case 'Danh mục sản phẩm':  return const CategoryPage();
      case 'Đơn hàng':          return const OrderPage();
      case 'Tài khoản':         return const AccountPage();
      default:                  return const Center(child: Text('Chọn 1 mục'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text(''),
              decoration: BoxDecoration(
              color: Colors.red
              ),
          ),
            ...[
              {'icon': Icons.bar_chart, 'label': 'Thống kê'},
              {'icon': Icons.inventory,  'label': 'Sản phẩm'},
              {'icon': Icons.category,   'label': 'Danh mục sản phẩm'},
              {'icon': Icons.list_alt,   'label': 'Đơn hàng'},
              {'icon': Icons.person,     'label': 'Tài khoản'},
            ].map((item) => ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['label'] as String),
              selected: _selected == item['label'],
              onTap: () {
                setState(() => _selected = item['label'] as String);
                Navigator.pop(context);
              },
            )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context);
                // Trả về login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}
