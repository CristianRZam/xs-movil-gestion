import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashSessionCard extends StatelessWidget {

  final CashSession session;

  final VoidCallback onClose;

  const CashSessionCard({
    super.key,
    required this.session,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final theme = Theme.of(context);

    final dateFormat =
    DateFormat("dd/MM/yyyy HH:mm");

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: theme.cardColor,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(
          color:
          AppColors.primary.withValues(
            alpha: .15,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 15,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color:
                  AppColors.primary
                      .withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: const Icon(
                  Icons.point_of_sale_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Caja abierta",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Desde ${dateFormat.format(session.openedAt)}",
                      style: TextStyle(
                        color:
                        theme.textTheme
                            .bodySmall
                            ?.color,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: Colors.green
                      .withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(30),
                ),

                child: const Text(
                  "ABIERTA",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _InfoRow(
            icon: Icons.attach_money_rounded,
            title: "Monto de apertura",
            value:
            "S/ ${session.openingAmount.toStringAsFixed(2)}",
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.person_outline,
            title: "Usuario",
            value:
            "${session.openedByName}",
          ),

          if (session.openingComment != null &&
              session.openingComment!.isNotEmpty) ...[

            const SizedBox(height: 12),

            _InfoRow(
              icon:
              Icons.description_outlined,
              title: "Comentario",
              value:
              session.openingComment!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {

  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Icon(
          icon,
          size: 20,
          color:
          theme.iconTheme.color,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style:
                theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}