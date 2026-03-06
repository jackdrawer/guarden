import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class InfoDetailSection {
  final String title;
  final String body;

  const InfoDetailSection({
    required this.title,
    required this.body,
  });
}

class InfoDetailScreen extends StatelessWidget {
  final String title;
  final List<InfoDetailSection> sections;

  const InfoDetailScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.of(context).textSecondary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(color: AppColors.of(context).textPrimary),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = sections[index];
          return NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.body,
                  style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
