import 'package:flutter/material.dart';

class CashSessionSummaryCard
    extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const CashSessionSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 12,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 24,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}