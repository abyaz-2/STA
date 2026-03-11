import 'package:flutter/material.dart';
import '../../models/invite.dart';
import '../../services/invite_service.dart';

class InviteManagementScreen extends StatefulWidget {
  const InviteManagementScreen({super.key});

  @override
  State<InviteManagementScreen> createState() => _InviteManagementScreenState();
}

class _InviteManagementScreenState extends State<InviteManagementScreen> {
  final InviteService _inviteService = InviteService();
  late Future<List<Invite>> _pendingInvites;

  @override
  void initState() {
    super.initState();
    _loadPendingInvites();
  }

  void _loadPendingInvites() {
    setState(() {
      _pendingInvites = _inviteService.getPendingInvites(
        'current_user@example.com',
      );
    });
  }

  Future<void> _acceptInvite(Invite invite) async {
    try {
      // Accept the invite
      await _inviteService.acceptInvite(invite.id);

      // Add user to the group
      // You would need to implement this in your group management logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Joined ${invite.groupName}!')));

      _loadPendingInvites();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accepting invite: $e')));
    }
  }

  Future<void> _rejectInvite(Invite invite) async {
    try {
      await _inviteService.rejectInvite(invite.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invite rejected')));
      _loadPendingInvites();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rejecting invite: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Invitations')),
      body: FutureBuilder<List<Invite>>(
        future: _pendingInvites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final invites = snapshot.data ?? [];

          if (invites.isEmpty) {
            return const Center(child: Text('No pending invitations'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
                  title: Text(invite.groupName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'From: ${invite.inviterId}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Code: ${invite.inviteCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => _rejectInvite(invite),
                          tooltip: 'Reject',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.green,
                          ),
                          onPressed: () => _acceptInvite(invite),
                          tooltip: 'Accept',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
