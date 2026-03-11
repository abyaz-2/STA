import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
import '../../services/category_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Subscription> subscriptions = [];
  Map<String, String> categoryIdToName = {}; // id -> name mapping

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
    loadCategoryNames();
  }

  void loadCategoryNames() async {
    final categoryService = CategoryService();
    final categories = await categoryService.getAllCategories();
    final mapping = <String, String>{};
    for (var cat in categories) {
      mapping[cat.id] = cat.name;
    }
    setState(() {
      categoryIdToName = mapping;
    });
  }

  void loadSubscriptions() {
    setState(() {
      subscriptions = StorageService.getSubscriptions();
    });
  }

  double get monthlyTotal {
    double total = 0;
    for (var sub in subscriptions) {
      if (sub.billingCycle.toLowerCase() == 'monthly') {
        total += sub.amount;
      } else {
        total += sub.amount / 12;
      }
    }
    return total;
  }

  List<Subscription> get upcomingRenewals {
    final now = DateTime.now();
    final sorted = List<Subscription>.from(subscriptions);
    sorted.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return sorted.where((sub) => sub.nextBillingDate.isAfter(now) || sub.nextBillingDate.isAtSameMomentAs(now)).take(5).toList();
  }

  Map<String, double> get categorySpend {
    Map<String, double> map = {};
    for (var sub in subscriptions) {
      final catId = sub.category ?? 'Other';
      final catName = categoryIdToName[catId] ?? 'Other';
      final current = map[catName] ?? 0;
      map[catName] = current + (sub.billingCycle.toLowerCase() == 'monthly' ? sub.amount : sub.amount / 12);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const Center(child: Text("Add subscriptions to see analytics."));
    }

    final double mTotal = monthlyTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Monthly Summary Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Monthly Spend", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      "₹${mTotal.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Yearly Projection: ₹${(mTotal * 12).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pie Chart for Categories
            const Text("Category Split", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Renewals
            const Text("Upcoming Renewals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...upcomingRenewals.map((sub) {
              return Card(
                child: ListTile(
                  title: Text(sub.name),
                  subtitle: Text("Due: ${sub.nextBillingDate.toLocal().toString().split(' ')[0]}"),
                  trailing: Text("₹${sub.amount.toStringAsFixed(2)}"),
                ),
              );
            }),
            if (upcomingRenewals.isEmpty)
              const Text("No upcoming renewals this month."),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [Colors.indigo, Colors.teal, Colors.amber, Colors.deepOrange, Colors.purple];
    final map = categorySpend;
    int index = 0;
    
    return map.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        value: e.value,
        title: e.key,
        color: color,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
