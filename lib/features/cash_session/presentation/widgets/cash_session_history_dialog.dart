import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void openCashSessionHistoryDialog(
    BuildContext context,
    List<CashSession> sessions,
    ) {

  final theme =
  Theme.of(context);

  showDialog(

    context: context,

    builder: (_) {

      return Dialog(

        backgroundColor:
        theme.cardColor,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),

        child: SizedBox(

          width: 430,
          height: 620,

          child: Column(

            children: [

              Container(

                padding:
                const EdgeInsets.all(18),

                decoration:
                const BoxDecoration(
                  color:
                  Colors.blue,
                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.history_rounded,
                      color:
                      Colors.white,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "Historial de cajas",
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () =>
                          Navigator.pop(
                            context,
                          ),

                      icon:
                      const Icon(
                        Icons.close,
                        color:
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(

                child: sessions.isEmpty

                    ? const Center(
                  child: Text(
                    "No hay sesiones registradas",
                  ),
                )

                    : ListView.separated(

                  padding:
                  const EdgeInsets.all(
                    16,
                  ),

                  itemCount:
                  sessions.length,

                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                    height: 12,
                  ),

                  itemBuilder:
                      (_, index) {

                    final session =
                    sessions[index];

                    return _CashSessionHistoryCard(
                      session:
                      session,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CashSessionHistoryCard
    extends StatelessWidget {

  final CashSession session;

  const _CashSessionHistoryCard({
    required this.session,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    final isClosed =
        session.status == "CLOSED";

    final color =
    isClosed
        ? Colors.grey
        : Colors.green;

    final formatter =
    DateFormat(
      "dd/MM/yyyy HH:mm",
    );

    return Card(

      elevation: 0,

      margin:
      EdgeInsets.zero,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),

        side: BorderSide(
          color:
          color.withValues(
            alpha: .15,
          ),
        ),
      ),

      child: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(
              children: [

                CircleAvatar(
                  backgroundColor:
                  color.withValues(
                    alpha: .10,
                  ),

                  child:
                  Icon(
                    isClosed
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    color:
                    color,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Caja #${session.id}",
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        session.status,
                        style:
                        TextStyle(
                          color:
                          color,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  "S/ ${session.openingAmount.toStringAsFixed(2)}",
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _HistoryRow(
              title: "Apertura",
              value:
              formatter.format(
                session.openedAt,
              ),
            ),

            if (session.closedAt != null)
              _HistoryRow(
                title: "Cierre",
                value:
                formatter.format(
                  session.closedAt!,
                ),
              ),

            if (session.closingAmount != null)
              _HistoryRow(
                title: "Contado",
                value:
                "S/ ${session.closingAmount!.toStringAsFixed(2)}",
              ),

            if (session.expectedAmount != null)
              _HistoryRow(
                title: "Esperado",
                value:
                "S/ ${session.expectedAmount!.toStringAsFixed(2)}",
              ),

            if (session.difference != null)
              _HistoryRow(
                title: "Diferencia",
                value:
                "S/ ${session.difference!.toStringAsFixed(2)}",
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {

  final String title;
  final String value;

  const _HistoryRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 6,
      ),

      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style:
              Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ),

          Text(
            value,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}