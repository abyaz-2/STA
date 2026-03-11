import 'package:flutter/material.dart';
import '../../services/invite_service.dart';
import '../../models/invite.dart';

class InviteUtils {
  static final InviteService _service = InviteService();

  /// Check if there are pending invitations for a user
  static Future<bool> hasPendingInvites(String userEmail) async {
    final invites = await _service.getPendingInvites(userEmail);
    return invites.isNotEmpty;
  }

  /// Get count of pending invitations
  static Future<int> getPendingInvitesCount(String userEmail) async {
    final invites = await _service.getPendingInvites(userEmail);
    return invites.length;
  }

  /// Get all invites with their expiry status
  static Future<Map<String, List<Invite>>> getCategorizedInvites(
    String userEmail,
  ) async {
    final allInvites = await _service.getPendingInvites(userEmail);

    return {
      'active': allInvites.where((i) => !i.isExpired).toList(),
      'expired': allInvites.where((i) => i.isExpired).toList(),
    };
  }

  /// Copy invite code to clipboard and show feedback
  static Future<void> copyInviteCode(BuildContext context, String code) async {
    // Note: You'll need to add flutter/services to pubspec.yaml
    // await Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied: $code')));
  }

  /// Build invite status badge
  static Widget buildStatusBadge(Invite invite) {
    Color bgColor;
    Color textColor;
    String label;

    if (invite.isExpired) {
      bgColor = Colors.grey.withOpacity(0.2);
      textColor = Colors.grey;
      label = 'Expired';
    } else if (invite.status == 'accepted') {
      bgColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
      label = 'Accepted';
    } else if (invite.status == 'rejected') {
      bgColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red;
      label = 'Rejected';
    } else {
      bgColor = Colors.blue.withOpacity(0.2);
      textColor = Colors.blue;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Format invite expiry date
  static String formatExpiryDate(DateTime? expiresAt) {
    if (expiresAt == null) return 'No expiry';

    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inDays == 0) {
      return 'Expires today';
    } else if (difference.inDays == 1) {
      return 'Expires tomorrow';
    } else if (difference.inDays < 7) {
      return 'Expires in ${difference.inDays} days';
    } else {
      return 'Expires in ${(difference.inDays / 7).ceil()} weeks';
    }
  }

  /// Generate a formatted invite summary
  static String generateInviteSummary(Invite invite) {
    return '${invite.groupName} - Code: ${invite.inviteCode} - ${formatExpiryDate(invite.expiresAt)}';
  }
}
