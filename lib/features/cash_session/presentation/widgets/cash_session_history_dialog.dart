import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

void openCashSessionHistoryDialog(BuildContext context, List<CashSession> sessions) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .82,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(children: [
              const Icon(Icons.history_rounded),
              const SizedBox(width: 10),
              const Expanded(child: Text('Historial de cajas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20))),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
            ]),
          ),
          Expanded(
            child: sessions.isEmpty
                ? const Center(child: Text('No hay sesiones de caja registradas.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _CashSessionHistoryCard(session: sessions[index]),
                  ),
          ),
        ]),
      ),
    ),
  );
}

class _CashSessionHistoryCard extends StatelessWidget {
  const _CashSessionHistoryCard({required this.session});
  final CashSession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final closed = session.status == 'CLOSED';
    final color = closed ? scheme.outline : AppColors.successDark;
    final date = DateFormat('dd/MM/yyyy · HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: .24))),
      ),
      child: ExpansionTile(
        shape: const Border(), collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(closed ? Icons.lock_outline_rounded : Icons.lock_open_rounded, color: color)),
        title: Row(children: [
          Expanded(child: Text('Caja #${session.id}', style: const TextStyle(fontWeight: FontWeight.w800))),
          _StatusPill(label: closed ? 'Cerrada' : 'Abierta', color: color),
        ]),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text('${date.format(session.openedAt)} · ${_user(session.openedByName)}')),
        children: [
          const Divider(height: 20),
          _Detail(icon: Icons.lock_open_rounded, label: 'Apertura', value: date.format(session.openedAt)),
          _Detail(icon: Icons.person_outline_rounded, label: 'Abrió la caja', value: _user(session.openedByName)),
          _Detail(icon: Icons.payments_outlined, label: 'Monto de apertura', value: _money(session.openingAmount)),
          if (session.openingComment?.trim().isNotEmpty == true) _Detail(icon: Icons.comment_outlined, label: 'Comentario de apertura', value: session.openingComment!.trim()),
          if (closed) ...[
            const Divider(height: 22),
            _Detail(icon: Icons.lock_rounded, label: 'Cierre', value: session.closedAt == null ? 'Sin registrar' : date.format(session.closedAt!)),
            _Detail(icon: Icons.person_outline_rounded, label: 'Cerró la caja', value: _user(session.closedByName)),
            _Detail(icon: Icons.calculate_outlined, label: 'Monto esperado', value: _money(session.expectedAmount)),
            _Detail(icon: Icons.point_of_sale_outlined, label: 'Monto contado', value: _money(session.closingAmount)),
            _Detail(icon: Icons.compare_arrows_rounded, label: 'Diferencia', value: _money(session.difference), valueColor: (session.difference ?? 0) == 0 ? AppColors.successDark : scheme.error),
            if (session.closingComment?.trim().isNotEmpty == true) _Detail(icon: Icons.comment_outlined, label: 'Comentario de cierre', value: session.closingComment!.trim()),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(99)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon; final String label; final String value; final Color? valueColor;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 17, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 8), Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w700, color: valueColor))),
    ]),
  );
}

String _user(String? name) => name?.trim().isNotEmpty == true ? name!.trim() : 'Usuario no disponible';
String _money(num? value) => 'S/ ${(value ?? 0).toStringAsFixed(2)}';
