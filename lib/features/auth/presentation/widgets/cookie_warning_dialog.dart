import 'package:flutter/material.dart';

/// Dialog that shows when there are browser cookie issues with Google Sign-In
class CookieWarningDialog extends StatelessWidget {
  const CookieWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cookie Settings Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Google Sign-In requires third-party cookies to be enabled in your browser settings.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions to enable cookies:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildBrowserInstructions(),
          const SizedBox(height: 16),
          const Text(
            'After enabling cookies, please try signing in again.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Return true to indicate retry
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildBrowserInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrowserInstruction(
          'Chrome',
          '1. Click the three dots menu ⋮\n'
          '2. Select Settings\n'
          '3. Go to Privacy and security\n'
          '4. Select Cookies and other site data\n'
          '5. Select "Allow all cookies"',
        ),
        const SizedBox(height: 8),
        _buildBrowserInstruction(
          'Firefox',
          '1. Click the menu button ☰\n'
          '2. Select Settings\n'
          '3. Select Privacy & Security\n'
          '4. Under "Enhanced Tracking Protection", choose "Standard"',
        ),
        const SizedBox(height: 8),
        _buildBrowserInstruction(
          'Safari',
          '1. Go to Safari menu > Preferences\n'
          '2. Select Privacy tab\n'
          '3. Uncheck "Prevent cross-site tracking"',
        ),
      ],
    );
  }

  Widget _buildBrowserInstruction(String browser, String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          browser,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(instructions, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Shows the cookie warning dialog and returns true if the user wants to retry
Future<bool> showCookieWarningDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CookieWarningDialog(),
  );
  
  return result ?? false;
} 