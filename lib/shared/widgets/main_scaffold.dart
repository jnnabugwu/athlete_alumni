import 'package:flutter/material.dart';
import 'app_footer.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: body),
          const AppFooter(),
        ],
      ),
    );
  }
} 