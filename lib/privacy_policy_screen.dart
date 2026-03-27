// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF9F8FF))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) =>
            setState(() => _loadingProgress = progress / 100),
        onPageFinished: (_) =>
            setState(() => _loading = false),
      ))
      ..loadFlutterAsset('assets/privacy_policy.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12111A),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) _buildLoader(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF12111A),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B6B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      bottom: _loading
          ? PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: LinearProgressIndicator(
          value: _loadingProgress,
          backgroundColor: Colors.white.withOpacity(0.06),
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFFFF6B6B),
          ),
          minHeight: 2,
        ),
      )
          : null,
    );
  }

  Widget _buildLoader() {
    return Container(
      color: const Color(0xFFF9F8FF),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                strokeWidth: 2.5,
                backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF6B6B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading…',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF12111A).withOpacity(0.4),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}