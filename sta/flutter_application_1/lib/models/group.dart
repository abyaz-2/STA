import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String ownerId;
  final String name;
  final List<String> memberIds;

  Group({
    String? id,
    required this.ownerId,
    required this.name,
    this.memberIds = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'memberIds': memberIds,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      ownerId: map['ownerId'],
      name: map['name'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }
}
