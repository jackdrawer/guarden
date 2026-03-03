import 'package:flutter/material.dart';
import '../errors/app_errors.dart';
import '../theme/app_colors.dart';

class ErrorSnackBar extends StatelessWidget {
  final AppError error;
  final VoidCallback? onAction;
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;

  const ErrorSnackBar({
    super.key,
    required this.error,
    this.onAction,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.of(context).neumorphicShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.of(context).error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.userMessage,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (error.action != null && onAction != null)
                TextButton(
                  onPressed: () {
                    controller?.close();
                    onAction!();
                  },
                  child: Text(
                    error.action!.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.of(context).primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.of(context).textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  controller?.close();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
  BuildContext context,
  AppError error, {
  VoidCallback? onAction,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

  late ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;

  final snackBar = SnackBar(
    content: Builder(
      builder: (context) {
        return ErrorSnackBar(
          error: error,
          onAction: onAction,
          controller: controller,
        );
      },
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    duration: Duration(
      seconds: error.action != null && onAction != null ? 6 : 4,
    ),
    behavior: SnackBarBehavior.floating,
  );

  controller = scaffoldMessenger.showSnackBar(snackBar);
  return controller;
}
