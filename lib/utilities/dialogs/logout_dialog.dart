import 'package:flutter/material.dart';
import 'package:sport_app/utilities/dialogs/generic_dialog.dart';
import 'package:sport_app/app_theme.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  final theme = Theme.of(context);

  return showGenericDialog(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Yes': true,
      'No': false,
    },
    titleStyle: theme.textTheme.headlineMedium?.copyWith(
      color: AthleticEnergyTheme.primaryRed,
    ),
    buttonStyle: TextButton.styleFrom(
      foregroundColor: AthleticEnergyTheme.primaryRed,
      textStyle: theme.textTheme.titleMedium,
    ),
  ).then(
    (value) => value ?? false,
  );
}
