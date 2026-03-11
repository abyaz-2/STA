import 'package:hive_flutter/hive_flutter.dart';
import '../models/invite.dart';
import 'dart:math';

class InviteService {
  static const String _invitesBoxName = 'invites';
  late Box<Map> _invitesBox;

  static final InviteService _instance = InviteService._internal();

  InviteService._internal();

  factory InviteService() {
    return _instance;
  }

  Future<void> init() async {
    _invitesBox = await Hive.openBox<Map>(_invitesBoxName);
  }

  /// Generate a unique 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Create and send an invite
  Future<Invite> createInvite({
    required String groupId,
    required String groupName,
    required String inviterId,
    required String inviteeEmail,
    Duration expiryDuration = const Duration(days: 7),
  }) async {
    final invite = Invite(
      groupId: groupId,
      groupName: groupName,
      inviterId: inviterId,
      inviteeEmail: inviteeEmail,
      expiresAt: DateTime.now().add(expiryDuration),
      status: 'pending',
      inviteCode: _generateInviteCode(),
    );

    await _invitesBox.put(invite.id, invite.toMap());
    return invite;
  }

  /// Get all pending invites for a user (as invitee)
  Future<List<Invite>> getPendingInvites(String userEmail) async {
    final invites = <Invite>[];
    for (var value in _invitesBox.values) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      if (invite.inviteeEmail == userEmail && invite.status == 'pending' && !invite.isExpired) {
        invites.add(invite);
      }
    }
    return invites;
  }

  /// Get all invites sent by a specific user (for group management)
  Future<List<Invite>> getInvitesSentByUser(String userId, {String? groupId}) async {
    final invites = <Invite>[];
    for (var value in _invitesBox.values) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      if (invite.inviterId == userId) {
        if (groupId == null || invite.groupId == groupId) {
          invites.add(invite);
        }
      }
    }
    return invites;
  }

  /// Get invite by code
  Future<Invite?> getInviteByCode(String code) async {
    for (var value in _invitesBox.values) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      if (invite.inviteCode == code && invite.status == 'pending' && !invite.isExpired) {
        return invite;
      }
    }
    return null;
  }

  /// Accept an invite
  Future<void> acceptInvite(String inviteId) async {
    final value = _invitesBox.get(inviteId);
    if (value != null) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      final updatedInvite = invite.copyWith(status: 'accepted');
      await _invitesBox.put(inviteId, updatedInvite.toMap());
    }
  }

  /// Reject an invite
  Future<void> rejectInvite(String inviteId) async {
    final value = _invitesBox.get(inviteId);
    if (value != null) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      final updatedInvite = invite.copyWith(status: 'rejected');
      await _invitesBox.put(inviteId, updatedInvite.toMap());
    }
  }

  /// Cancel an invite (by sender)
  Future<void> cancelInvite(String inviteId) async {
    await _invitesBox.delete(inviteId);
  }

  /// Get all invites for a specific group with any status
  Future<List<Invite>> getGroupInvites(String groupId) async {
    final invites = <Invite>[];
    for (var value in _invitesBox.values) {
      final invite = Invite.fromMap(Map<String, dynamic>.from(value));
      if (invite.groupId == groupId) {
        invites.add(invite);
      }
    }
    return invites;
  }

  /// Generate a shareable deep link for an invite
  String generateDeepLink(String inviteCode) {
    return 'staapp://invite/$inviteCode';
  }

  /// Generate a shareable URL for an invite
  String generateShareableUrl(String inviteCode) {
    return 'https://staapp.example.com/invite/$inviteCode';
  }
}
