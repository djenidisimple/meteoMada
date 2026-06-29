import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppTheme.accentBlue),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!,
                style: AppTheme.poppins(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}
