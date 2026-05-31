import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.color = const Color(0xFF208e60),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      color: isDark
          ? Colors.grey[900] // Fondo oscuro para modo dark
          : theme.cardColor, // Usa el default en modo light
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono dentro de un círculo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),

            // Valor principal
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Título
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),

            // Subtítulo
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardCard(
        icon: Icons.shopping_cart,
        title: "Ventas",
        value: "\$12,500",
        subtitle: "Hoy",
        color: const Color(0xFF208e60),
      ),
      DashboardCard(
        icon: Icons.people,
        title: "Clientes",
        value: "230",
        subtitle: "Registrados",
        color: const Color(0xFF2E86AB),
      ),
      DashboardCard(
        icon: Icons.inventory,
        title: "Inventario",
        value: "58",
        subtitle: "Productos bajos",
        color: const Color(0xFFF39C12),
      ),
      DashboardCard(
        icon: Icons.attach_money,
        title: "Ingresos",
        value: "\$85,000",
        subtitle: "Este mes",
        color: const Color(0xFF8E44AD),
      ),
    ];

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isSmallScreen ? 1.0 : 1.1,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}
