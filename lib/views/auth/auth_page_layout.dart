
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: child,
          ),
        ),
      ),
    );
  }
}