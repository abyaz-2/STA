import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';

const _kAccent = Color(0xFF8BC34A);
const _kAccentDark = Color(0xFF558B2F);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Subscription> subscriptions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadSubscriptions() {
    setState(() {
      subscriptions = StorageService.getSubscriptions();
    });
  }

  double get monthlyTotal {
    double total = 0;
    for (var sub in subscriptions) {
      total += sub.billingCycle.toLowerCase() == 'monthly'
          ? sub.amount
          : sub.amount / 12;
    }
    return total;
  }

  List<Subscription> get upcomingRenewals {
    final now = DateTime.now();
    final sorted = List<Subscription>.from(subscriptions)
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return sorted
        .where((s) => !s.nextBillingDate.isBefore(now))
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mTotal = monthlyTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F3),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroCard(mTotal: mTotal, count: subscriptions.length),
          ),

          // ── Tab bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  // Pill segment
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        _PillTab(
                          label: 'Upcoming',
                          controller: _tabController,
                          index: 0,
                        ),
                        _PillTab(
                          label: 'Categories',
                          controller: _tabController,
                          index: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UpcomingTab(renewals: upcomingRenewals),
                _CategoriesTab(subscriptions: subscriptions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero spend card ──────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final double mTotal;
  final int count;
  const _HeroCard({required this.mTotal, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kAccent, _kAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Monthly Spend',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${mTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Yearly Projection  ₹${(mTotal * 12).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming renewals tab ────────────────────────────────────────────────────
class _UpcomingTab extends StatelessWidget {
  final List<Subscription> renewals;
  const _UpcomingTab({required this.renewals});

  @override
  Widget build(BuildContext context) {
    if (renewals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 56, color: _kAccent),
            SizedBox(height: 12),
            Text('No upcoming renewals 🎉',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Add subscriptions to track them.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: renewals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _RenewalCard(sub: renewals[i]),
    );
  }
}

class _RenewalCard extends StatelessWidget {
  final Subscription sub;
  const _RenewalCard({required this.sub});

  int get _daysLeft {
    return sub.nextBillingDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysLeft;
    final isUrgent = days <= 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withValues(alpha: 0.1)
                  : _kAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.subscriptions_rounded,
              color: isUrgent ? Colors.red : _kAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12,
                        color: isUrgent ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${sub.nextBillingDate.day}/${sub.nextBillingDate.month}/${sub.nextBillingDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUrgent ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount + days badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${sub.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withValues(alpha: 0.1)
                      : _kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  days == 0 ? 'Today' : '$days days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUrgent ? Colors.red : _kAccentDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Categories pie chart tab ─────────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  final List<Subscription> subscriptions;
  const _CategoriesTab({required this.subscriptions});

  Map<String, double> get _spending {
    final map = <String, double>{};
    for (var sub in subscriptions) {
      final cat = sub.category ?? 'Other';
      map[cat] = (map[cat] ?? 0) +
          (sub.billingCycle.toLowerCase() == 'monthly'
              ? sub.amount
              : sub.amount / 12);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final data = _spending.entries.toList();
    if (data.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final palette = [
      _kAccent,
      const Color(0xFF42A5F5),
      const Color(0xFFFFA726),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: data.asMap().entries.map((e) {
                  final color = palette[e.key % palette.length];
                  return PieChartSectionData(
                    value: e.value.value,
                    color: color,
                    radius: 55,
                    title: '',
                  );
                }).toList(),
                centerSpaceRadius: 48,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final color = palette[i % palette.length];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(data[i].key,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(
                    '₹${data[i].value.toStringAsFixed(0)}/mo',
                    style: const TextStyle(
                      color: _kAccentDark,
                      fontWeight: FontWeight.w700,
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

// ── Pill tab selector ────────────────────────────────────────────────────────
class _PillTab extends StatelessWidget {
  final String label;
  final TabController controller;
  final int index;

  const _PillTab(
      {required this.label, required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isSelected = controller.index == index;
        return GestureDetector(
          onTap: () => controller.animateTo(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? _kAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF888888),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
