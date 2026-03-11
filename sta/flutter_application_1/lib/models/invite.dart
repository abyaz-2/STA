import 'package:uuid/uuid.dart';

class Invite {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterId;
  final String inviteeEmail;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final String? inviteCode;

  Invite({
    String? id,
    required this.groupId,
    required this.groupName,
    required this.inviterId,
    required this.inviteeEmail,
    DateTime? createdAt,
    this.expiresAt,
    this.status = 'pending',
    this.inviteCode,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'inviterId': inviterId,
      'inviteeEmail': inviteeEmail,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'inviteCode': inviteCode,
    };
  }

  factory Invite.fromMap(Map<String, dynamic> map) {
    return Invite(
      id: map['id'],
      groupId: map['groupId'],
      groupName: map['groupName'],
      inviterId: map['inviterId'],
      inviteeEmail: map['inviteeEmail'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : null,
      status: map['status'] ?? 'pending',
      inviteCode: map['inviteCode'],
    );
  }

  Invite copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? inviterId,
    String? inviteeEmail,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
    String? inviteCode,
  }) {
    return Invite(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      inviterId: inviterId ?? this.inviterId,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
