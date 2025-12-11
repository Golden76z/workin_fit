import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/widgets/button.dart';
import 'package:workin_fit/widgets/text_input.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WorkinFitApp(),
    ),
  );
}

class WorkinFitApp extends StatelessWidget {
  const WorkinFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workin Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workin Fit',
          style: TextStyle(
            fontFamily:
                'AppFont',
            fontSize: 42,
            fontWeight: FontWeight.normal,
          ),
        ),
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'AppFont',
                fontWeight: FontWeight.w100,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),
            const AppTextInput(
              hint: 'Name',
              hasBorder: true,
              margin: EdgeInsets.symmetric(horizontal: 32),
            ),

            const SizedBox(height: 12),
            AppButton(label: 'this is a test button', onPressed: () => add(1, 2)),

            const SizedBox(height: 12),
            AppButton(label: 'test', onPressed: () => add(1, 2)),

          ],
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}

int add(int a, int b) {
  return a + b;
}