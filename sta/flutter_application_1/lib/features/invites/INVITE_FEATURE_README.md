# Invite Feature Documentation

## Overview

The invite feature allows group owners to invite other users to join their groups via email invitations. The system includes:

- **Invite Model** - Stores invitation data with unique codes
- **Invite Service** - Manages invite creation, acceptance, and rejection
- **Send Invite Dialog** - UI for sending group invitations
- **Invite Management Screen** - UI for viewing and responding to pending invitations

## Key Features

### 1. Create and Send Invitations
```dart
final inviteService = InviteService();
final invite = await inviteService.createInvite(
  groupId: 'group123',
  groupName: 'My Group',
  inviterId: 'user123',
  inviteeEmail: 'friend@example.com',
  expiryDuration: const Duration(days: 7),
);
```

The system generates a unique 6-character invite code for each invitation.

### 2. Generate Shareable Links
```dart
// Deep link (for mobile app)
final deepLink = inviteService.generateDeepLink(invite.inviteCode);  
// staapp://invite/ABC123

// Web link
final webLink = inviteService.generateShareableUrl(invite.inviteCode);
// https://staapp.example.com/invite/ABC123
```

### 3. Accept/Reject Invitations
```dart
// Accept an invitation
await inviteService.acceptInvite(inviteId);

// Reject an invitation
await inviteService.rejectInvite(inviteId);
```

### 4. Query Invitations
```dart
// Get pending invites for a user
final pending = await inviteService.getPendingInvites('user@example.com');

// Get invites by invite code
final invite = await inviteService.getInviteByCode('ABC123');

// Get all invites for a group
final groupInvites = await inviteService.getGroupInvites('group123');

// Get invites sent by a user
final sent = await inviteService.getInvitesSentByUser('user123');
```

## Integration Points

### In Groups Screen
The `SendInviteDialog` is triggered when a group owner taps the "Invite Member" button:

```dart
showDialog(
  context: context,
  builder: (context) => SendInviteDialog(
    groupId: group.id,
    groupName: group.name,
    inviterId: group.ownerId,
  ),
);
```

### In Home Screen
You can add a new tab or navigation item to show pending invitations:

```dart
const InviteManagementScreen(),
```

Add to navigation destinations:
```dart
NavigationDestination(
  icon: Icon(Icons.mail_outlined),
  selectedIcon: Icon(Icons.mail),
  label: 'Invites',
),
```

## Invite Lifecycle

1. **Created** - Group owner sends invite to email address
2. **Pending** - Invitation waiting for recipient to respond
3. **Accepted** - User accepted and joined the group
4. **Rejected** - User declined the invitation
5. **Expired** - Invitation expired (default 7 days)
6. **Cancelled** - Group owner revoked the invitation

## Invite Data Storage

Invitations are stored in Hive with the following fields:
- `id` - Unique identifier
- `groupId` - Reference to group
- `groupName` - Group name for display
- `inviterId` - ID of user who sent invite
- `inviteeEmail` - Email of recipient
- `createdAt` - Creation timestamp
- `expiresAt` - Expiration timestamp (optional)
- `status` - Current status (pending/accepted/rejected/expired)
- `inviteCode` - Unique 6-character code

## Next Steps to Complete Integration

1. **Deep Link Handling**: Implement deep link parsing in your app initialization to handle `staapp://invite/{code}` URLs

2. **Firebase/Supabase Integration**: Replace the email-based system with your backend:
   ```dart
   // Instead of storing locally, send to backend
   await _supabase.from('invites').insert(invite.toMap());
   ```

3. **Email Notifications**: Send actual emails to invitees with invitation links

4. **User Management**: Update the Group model to reflect membership changes when invites are accepted

5. **Add Invites Tab**: Add an invites/mail tab to the home screen navigation bar for easy access

## Customization

### Change Invite Code Length
In `invite_service.dart`, modify the `_generateInviteCode()` method:
```dart
String _generateInviteCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();  // Change 6 to 8
}
```

### Change Default Expiry Duration
Update the `createInvite()` call:
```dart
expiryDuration: const Duration(days: 30),  // Change expiry time
```

### Customize Invite Dialog
Edit `send_invite_dialog.dart` to add more fields like:
- Custom message to include with invite
- Role selection
- Expiry date picker
