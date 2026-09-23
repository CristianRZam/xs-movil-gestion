import 'package:flutter/material.dart';

class ProductSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ProductSummaryCard({
    super.key,

    required this.title,

    required this.value,

    required this.icon,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 8),

          Text(
            value,

            style: TextStyle(
              fontSize: 22,

              fontWeight: FontWeight.bold,

              color: color,
            ),
          ),

          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
