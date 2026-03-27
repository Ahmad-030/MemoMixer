// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body {
    font-family: -apple-system, sans-serif;
    padding: 24px;
    line-height: 1.7;
    color: #1a1a2e;
    font-size: 15px;
  }
  h1 { font-size: 24px; margin-bottom: 8px; }
  h2 { font-size: 18px; margin-top: 28px; margin-bottom: 8px; color: #FF6B6B; }
  p { margin-bottom: 12px; }
  .date { color: #999; font-size: 13px; margin-bottom: 24px; }
</style>
</head>
<body>
<h1>Privacy Policy</h1>
<p class="date">Last updated: January 1, 2025</p>

<p>MemoMixer ("we", "our", or "us") is committed to protecting your privacy.
This Privacy Policy explains how we handle your information when you use our app.</p>

<h2>1. Data We Collect</h2>
<p>MemoMixer stores all your notes — including photos, audio recordings, captions,
and tags — <strong>locally on your device</strong>. We do not collect, transmit,
or store any personal data on our servers.</p>

<h2>2. Permissions</h2>
<p>The app requests the following permissions:</p>
<p><strong>Camera</strong> – To capture photos for your notes.<br>
<strong>Microphone</strong> – To record audio notes.<br>
<strong>Photo Library</strong> – To pick existing photos from your gallery.<br>
<strong>Storage</strong> – To save and read media files on your device.</p>

<h2>3. Third-Party Services</h2>
<p>MemoMixer does not use any third-party analytics, advertising, or tracking services.</p>

<h2>4. Data Security</h2>
<p>All your notes are stored in your device's internal storage and/or
SharedPreferences. We recommend keeping your device secured with a PIN or
biometric lock.</p>

<h2>5. Children's Privacy</h2>
<p>MemoMixer is not directed to children under 13. We do not knowingly collect
personal information from children under 13.</p>

<h2>6. Changes to This Policy</h2>
<p>We may update this Privacy Policy from time to time. Changes will be reflected
in the app with an updated date at the top of this page.</p>

<h2>7. Contact Us</h2>
<p>If you have any questions about this Privacy Policy, please contact us at:
<br><strong>dev@memomixer.app</strong></p>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadHtmlString(_html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}