// lib/shared/widgets/no_connection_banner.dart

import 'package:flutter/material.dart';

/// Content widget for the "no internet" Material Banner.
///
/// Designed to be embedded inside [MaterialBanner.content]. Renders an amber
/// warning icon and a short message describing the connectivity loss.
class NoConnectionBanner extends StatelessWidget {
  const NoConnectionBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.wifi_off_outlined, color: Colors.amber.shade800, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: Colors.amber.shade900,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
