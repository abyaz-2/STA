import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Subscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  void loadSubscriptions() {
    setState(() {
      subscriptions = StorageService.getSubscriptions();
    });
  }

  Map<String, double> get categorySpend {
    Map<String, double> map = {};
    for (var sub in subscriptions) {
      final cat = sub.category ?? 'Other';
      final current = map[cat] ?? 0;
      map[cat] = current + (sub.billingCycle.toLowerCase() == 'monthly' ? sub.amount : sub.amount / 12);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final catData = categorySpend.entries.toList();
    catData.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Analytics')),
      body: subscriptions.isEmpty
          ? const Center(child: Text('No data for analytics'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Spend by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Expanded(
                    flex: 2,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < catData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      catData[value.toInt()].key,
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text('₹${value.toInt()}', style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: catData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value,
                                color: Theme.of(context).colorScheme.primary,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Detailed Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: catData.length,
                      itemBuilder: (context, index) {
                        final item = catData[index];
                        return ListTile(
                          leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                          title: Text(item.key),
                          trailing: Text('₹${item.value.toStringAsFixed(2)} / mo'),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
