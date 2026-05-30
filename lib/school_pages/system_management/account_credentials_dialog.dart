import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the one-time login credentials for a newly created account.
///
/// The temporary password is only ever returned once by the server and is not
/// stored anywhere, so the staff member must copy/share it now. The new user
/// should change it on first login.
Future<void> showNewAccountCredentialsDialog(
  BuildContext context, {
  required String title,
  required String email,
  String? tempPassword,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final shareText = tempPassword == null
          ? 'Email: $email'
          : 'Email: $email\nTemporary password: $tempPassword';
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share these login details with the user. The temporary '
              'password is shown only once — copy it now. The user should '
              'change it after signing in.',
            ),
            const SizedBox(height: 16),
            _CredentialRow(label: 'Email', value: email),
            if (tempPassword != null) ...[
              const SizedBox(height: 8),
              _CredentialRow(label: 'Temp password', value: tempPassword),
            ],
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: shareText));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Credentials copied.')),
                );
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
