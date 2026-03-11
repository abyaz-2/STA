/// Example Usage of the Invite Service
/// 
/// This file demonstrates how to use the InviteService in your app.
/// You can reference these examples for integration.

import 'package:flutter/material.dart';
import '../../services/invite_service.dart';
import '../../models/invite.dart';

class InviteServiceExamples {
  final InviteService _inviteService = InviteService();

  /// Example 1: Send an invitation
  Future<void> example1_SendInvitation() async {
    final invite = await _inviteService.createInvite(
      groupId: 'family-expenses',
      groupName: 'Family Expenses',
      inviterId: 'john@example.com',
      inviteeEmail: 'jane@example.com',
      expiryDuration: const Duration(days: 14),
    );

    print('Invite created with code: ${invite.inviteCode}');
    print('Deep link: ${_inviteService.generateDeepLink(invite.inviteCode!)}');
  }

  /// Example 2: Get pending invites for a user
  Future<void> example2_GetPendingInvites() async {
    final pendingInvites = await _inviteService.getPendingInvites('user@example.com');

    for (var invite in pendingInvites) {
      print('${invite.groupName} from ${invite.inviterId}');
      print('  Code: ${invite.inviteCode}');
      print('  Status: ${invite.status}');
    }
  }

  /// Example 3: Accept an invitation
  Future<void> example3_AcceptInvite(String inviteId) async {
    await _inviteService.acceptInvite(inviteId);
    print('Invite accepted!');
    // TODO: Add user to group in your group management logic
  }

  /// Example 4: Reject an invitation
  Future<void> example4_RejectInvite(String inviteId) async {
    await _inviteService.rejectInvite(inviteId);
    print('Invite rejected!');
  }

  /// Example 5: Find invite by code
  Future<void> example5_FindInviteByCode(String code) async {
    final invite = await _inviteService.getInviteByCode(code);

    if (invite != null) {
      print('Found invite for group: ${invite.groupName}');
    } else {
      print('Invite not found or expired');
    }
  }

  /// Example 6: Get all invites sent by a user (for group management)
  Future<void> example6_GetSentInvites(String userId) async {
    final sentInvites = await _inviteService.getInvitesSentByUser(userId);

    print('${sentInvites.length} invites sent');
    for (var invite in sentInvites) {
      print('  - ${invite.inviteeEmail} to ${invite.groupName} (${invite.status})');
    }
  }

  /// Example 7: Get all invites for a specific group
  Future<void> example7_GetGroupInvites(String groupId) async {
    final groupInvites = await _inviteService.getGroupInvites(groupId);

    print('Group has ${groupInvites.length} total invitations');
    for (var invite in groupInvites) {
      print('  - ${invite.inviteeEmail}: ${invite.status}');
    }
  }

  /// Example 8: Cancel an invite (by group owner)
  Future<void> example8_CancelInvite(String inviteId) async {
    await _inviteService.cancelInvite(inviteId);
    print('Invite cancelled and removed');
  }

  /// Example 9: Generate shareable links for UI
  void example9_GenerateLinks(String inviteCode) {
    final deepLink = _inviteService.generateDeepLink(inviteCode);
    final webLink = _inviteService.generateShareableUrl(inviteCode);

    print('Deep Link: $deepLink');
    print('Web Link: $webLink');

    // Use these in your UI:
    // - Display as QR code
    // - Share via messaging app
    // - Display as clickable link
  }

  /// Example 10: Check if invite is expired
  Future<void> example10_CheckExpiry() async {
    final invites = await _inviteService.getPendingInvites('user@example.com');

    for (var invite in invites) {
      if (invite.isExpired) {
        print('${invite.groupName} invite has expired');
      } else {
        print('${invite.groupName} is still valid');
      }
    }
  }
}

/// Usage in Widget:
class InviteExampleWidget extends StatelessWidget {
  const InviteExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final examples = InviteServiceExamples();
        await examples.example1_SendInvitation();
      },
      child: const Text('Send Invite'),
    );
  }
}
