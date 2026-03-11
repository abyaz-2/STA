import 'package:flutter/material.dart';
import '../../models/invite.dart';
import '../../services/invite_service.dart';

class SendInviteDialog extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String inviterId;

  const SendInviteDialog({
    required this.groupId,
    required this.groupName,
    required this.inviterId,
    super.key,
  });

  @override
  State<SendInviteDialog> createState() => _SendInviteDialogState();
}

class _SendInviteDialogState extends State<SendInviteDialog> {
  final TextEditingController _emailController = TextEditingController();
  final InviteService _inviteService = InviteService();
  bool _isLoading = false;
  Invite? _sentInvite;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvite() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invite = await _inviteService.createInvite(
        groupId: widget.groupId,
        groupName: widget.groupName,
        inviterId: widget.inviterId,
        inviteeEmail: _emailController.text.trim(),
      );

      setState(() {
        _sentInvite = invite;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite sent to ${_emailController.text}!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending invite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invite Member',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Invite someone to join "${widget.groupName}"',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_sentInvite == null) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendInvite,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send Invite'),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Invite Sent!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Invite Code: ${_sentInvite!.inviteCode}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SelectableText(_inviteService.generateDeepLink(_sentInvite!.inviteCode ?? '')),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Share this link with the person you want to invite.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _emailController.clear();
                        setState(() => _sentInvite = null);
                      },
                      child: const Text('Send Another'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
