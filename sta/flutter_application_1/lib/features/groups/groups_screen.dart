import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../services/storage_service.dart';
import '../../services/profile_service.dart';
import '../invites/send_invite_dialog.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groups = StorageService.getGroups();
    });
  }

  void _createGroup() {
    final controller = TextEditingController();
    const accent = Color(0xFF8BC34A);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final currentUser = ProfileService().getCurrentUser();
                  final userId = currentUser?.id ?? 'mock_user123';

                  final newGroup = Group(
                    ownerId: userId,
                    name: controller.text,
                    memberIds: [userId],
                  );

                  await StorageService.addGroup(newGroup);
                  _loadGroups();
                }
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showGroupDetails(Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Members:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...group.memberIds.map(
                (id) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(id == 'mock_user123' ? 'You' : id),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Invite Member'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => SendInviteDialog(
                      groupId: group.id,
                      groupName: group.name,
                      inviterId: group.ownerId,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Groups')),
      body: _groups.isEmpty
          ? const Center(child: Text("You aren't in any groups yet."))
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.group)),
                    title: Text(group.name),
                    subtitle: Text('${group.memberIds.length} members'),
                    onTap: () => _showGroupDetails(group),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _createGroup,
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
