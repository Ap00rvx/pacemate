import 'package:flutter/material.dart';

class CommonOverlay extends StatefulWidget {
  const CommonOverlay({super.key});

  @override
  State<CommonOverlay> createState() => _CommonOverlayState();
}

class _CommonOverlayState extends State<CommonOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
