import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../screens/subscription_detail_screen.dart';

const _kAccent = Color(0xFF8BC34A);
const _kAccentDark = Color(0xFF558B2F);

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onDelete;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  int get _daysLeft =>
      subscription.nextBillingDate.difference(DateTime.now()).inDays;

  Color get _iconBg {
    // Pick a color based on subscription name hash for variety
    final palette = [
      const Color(0xFF8BC34A),
      const Color(0xFF42A5F5),
      const Color(0xFFFFA726),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];
    return palette[subscription.name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysLeft;
    final isUrgent = days <= 3;

    return Dismissible(
      key: Key(subscription.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionDetailScreen(subscription: subscription),
          ),
        ),
        child: Container(
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
              // Colored icon circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _iconBg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    subscription.name.isNotEmpty
                        ? subscription.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _iconBg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + cycle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subscription.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (subscription.isShared) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Shared',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _kAccentDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: isUrgent ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${subscription.nextBillingDate.day}/${subscription.nextBillingDate.month}/${subscription.nextBillingDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUrgent ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subscription.billingCycle.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF666666)),
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
                    '₹${subscription.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? Colors.red.withValues(alpha: 0.1)
                          : _kAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      days < 0
                          ? 'Overdue'
                          : days == 0
                              ? 'Today'
                              : '$days days',
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
        ),
      ),
    );
  }
}
