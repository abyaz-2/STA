  class Subscription {
  final String id;
  final String name;
  final double amount;
  final String billingCycle; // monthly or yearly
  final DateTime nextDueDate;
  final bool reminderEnabled;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextDueDate,
    required this.reminderEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle,
      'nextDueDate': nextDueDate.toIso8601String(),
      'reminderEnabled': reminderEnabled,
    };
  }

  factory Subscription.fromMap(Map map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      billingCycle: map['billingCycle'],
      nextDueDate: DateTime.parse(map['nextDueDate']),
      reminderEnabled: map['reminderEnabled'],
    );
  }
}
