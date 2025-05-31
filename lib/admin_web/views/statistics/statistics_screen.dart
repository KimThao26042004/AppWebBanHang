import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');
  final productsCollection = FirebaseFirestore.instance.collection('products');
  final usersCollection = FirebaseFirestore.instance.collection('user');

  Future<double> _fetchTotalIncomeAll() async {
    final snap = await ordersCollection.get();
    double totalIncome = 0.0;
    for (var doc in snap.docs) {
      final val = doc.data();
      final num amountNum = (val['totalAmount'] as num? ?? val['total'] as num? ?? 0);
      totalIncome += amountNum.toDouble();
    }
    return totalIncome;
  }

  Future<int> _fetchProductCount() async {
    final snap = await productsCollection.get();
    return snap.docs.length;
  }

  Future<int> _fetchUserCount() async {
    final snap = await usersCollection.get();
    return snap.docs.length;
  }

  Future<Map<int, double>> _fetchWeeklyIncome() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final snap = await ordersCollection
        .where('order_date', isGreaterThanOrEqualTo: startOfWeek)
        .get();

    final data = <int, double>{ for (var i = 0; i < 7; i++) i: 0.0 };
    for (var doc in snap.docs) {
      final ts = (doc['order_date'] as Timestamp).toDate();
      final idx = ts.weekday - 1;
      final num t = (doc['totalAmount'] as num? ?? 0);
      data[idx] = data[idx]! + t.toDouble();
    }
    return data;
  }

  Future<Map<int, double>> _fetchMonthlyIncome() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    final snap = await ordersCollection
        .where('order_date', isGreaterThanOrEqualTo: startOfYear)
        .get();

    final data = <int, double>{ for (var m = 1; m <= 12; m++) m: 0.0 };
    for (var doc in snap.docs) {
      final ts = (doc['order_date'] as Timestamp).toDate();
      final m = ts.month;
      final num t = (doc['totalAmount'] as num? ?? 0);
      data[m] = data[m]! + t.toDouble();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Thống Kê Tổng Quan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<double>(
              future: _fetchTotalIncomeAll(),
              builder: (ctx, snapIncome) {
                final income = snapIncome.data ?? 0.0;
                return FutureBuilder<int>(
                  future: _fetchProductCount(),
                  builder: (ctx2, snapProd) {
                    final prodCnt = snapProd.data ?? 0;
                    return FutureBuilder<int>(
                      future: _fetchUserCount(),
                      builder: (ctx3, snapUser) {
                        final userCnt = snapUser.data ?? 0;
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatTile(
                                  label: 'Tổng thu',
                                  value: NumberFormat.currency(
                                      locale: 'vi_VN', symbol: 'đ')
                                      .format(income),
                                ),
                                _StatTile(
                                  label: 'Sản phẩm',
                                  value: prodCnt.toString(),
                                ),
                                _StatTile(
                                  label: 'Tài khoản',
                                  value: userCnt.toString(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            const Text('Doanh Thu Hàng Tuần',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 200,
                child: const _WeeklyChart(),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Doanh Thu Hàng Tháng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 200,
                child: const _MonthlyChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final fetcher = context.findAncestorStateOfType<_StatisticsPageState>();
    return FutureBuilder<Map<int, double>>(
      future: fetcher?._fetchWeeklyIncome(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return const Center(child: Text('Lỗi tải dữ liệu'));
        }
        final data = snap.data!;

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // tắt cột trái
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (value, meta) {
                    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                    final idx = value.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(idx >= 0 && idx < labels.length ? labels[idx] : ''),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data.entries
                    .map((e) => FlSpot(e.key.toDouble() , e.value))
                    .toList(),
                isCurved: false,
                dotData: FlDotData(show: true),
                barWidth: 2,
              ),
            ],
            minY: 0,
            maxY: data.values.reduce((a, b) => a > b ? a : b) * 1.2,
          ),
        );
      },
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final fetcher = context.findAncestorStateOfType<_StatisticsPageState>();
    return FutureBuilder<Map<int, double>>(
      future: fetcher?._fetchMonthlyIncome(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return const Center(child: Text('Lỗi tải dữ liệu'));
        }
        final data = snap.data!;

        return BarChart(
          BarChartData(
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false), // sửa ở đây
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // tắt cột trái
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (value, meta) {
                    final m = value.toInt() + 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(DateFormat.MMM('en_US').format(DateTime(0, m))),
                    );
                  },
                ),
              ),
            ),
            barGroups: data.entries
                .map(
                  (e) => BarChartGroupData(
                x: e.key - 1,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    width: 10,
                  ),
                ],
                barsSpace: 6,
              ),
            )
                .toList(),
            maxY: data.values.reduce((a, b) => a > b ? a : b) * 1.2,
          ),
        );

      },
    );
  }
}
