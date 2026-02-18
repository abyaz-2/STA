import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription.dart';

class StorageService {
  static const String boxName = "subscriptions";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static List<Subscription> getSubscriptions() {
    final box = Hive.box(boxName);
    return box.values
        .map((e) => Subscription.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addSubscription(Subscription sub) async {
    final box = Hive.box(boxName);
    await box.put(sub.id, sub.toMap());
  }

  static Future<void> deleteSubscription(String id) async {
    final box = Hive.box(boxName);
    await box.delete(id);
  }
}
