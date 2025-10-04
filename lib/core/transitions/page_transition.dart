import 'package:flutter/material.dart';

Widget defaultPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final slideAnimation = Tween<Offset>(
    begin: const Offset(0.1, 0), 
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  ));

  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );

  return FadeTransition(
    opacity: fadeAnimation,
    child: SlideTransition(
      position: slideAnimation,
      child: child,
    ),
  );
}
