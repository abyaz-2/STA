import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription.dart';
import '../models/group.dart';

class StorageService {
  static const String boxName = "subscriptions";
  static const String groupsBoxName = "groups";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
    await Hive.openBox(groupsBoxName);
  }

  // ── Subscriptions ────────────────────────────────────────────
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

  // ── Groups ───────────────────────────────────────────────────
  static List<Group> getGroups() {
    final box = Hive.box(groupsBoxName);
    return box.values
        .map((e) => Group.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addGroup(Group group) async {
    final box = Hive.box(groupsBoxName);
    await box.put(group.id, group.toMap());
  }

  static Future<void> deleteGroup(String id) async {
    final box = Hive.box(groupsBoxName);
    await box.delete(id);
  }

  static Future<void> updateGroup(Group group) async {
    final box = Hive.box(groupsBoxName);
    await box.put(group.id, group.toMap());
  }
}
