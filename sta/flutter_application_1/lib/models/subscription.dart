class Subscription {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String billingCycle; // monthly or yearly
  final DateTime nextBillingDate;
  final bool isShared;
  final String? groupId;
  final String? category;
  /// How many days before the billing date to fire the reminder notification.
  /// Supported values: 1, 3, 7. Defaults to 1.
  final int reminderDaysBefore;

  Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
    this.isShared = false,
    this.groupId,
    this.category,
    this.reminderDaysBefore = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'isShared': isShared,
      'groupId': groupId,
      'category': category,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  factory Subscription.fromMap(Map map) {
    return Subscription(
      id: map['id'],
      userId: map['userId'] ?? 'mock_user',
      name: map['name'],
      amount: (map['amount'] as num).toDouble(),
      billingCycle: map['billingCycle'],
      nextBillingDate: DateTime.parse(
        map['nextBillingDate'] ??
            map['nextDueDate'] ??
            DateTime.now().toIso8601String(),
      ),
      isShared: map['isShared'] ?? map['reminderEnabled'] ?? false,
      groupId: map['groupId'],
      category: map['category'],
      reminderDaysBefore: map['reminderDaysBefore'] ?? 1,
    );
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? billingCycle,
    DateTime? nextBillingDate,
    bool? isShared,
    String? groupId,
    String? category,
    int? reminderDaysBefore,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      isShared: isShared ?? this.isShared,
      groupId: groupId ?? this.groupId,
      category: category ?? this.category,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}
