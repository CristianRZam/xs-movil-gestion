import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';

class SaleModel extends Sale {
  const SaleModel({
    super.id,
    required super.saleNumber,
    super.orderId,
    super.discount,
    super.status,
    super.createdBy,
    super.createdByName,
    required super.items,
    required super.payments,
  });
  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: _int(json['id']),
    saleNumber: json['saleNumber'] as String? ?? '',
    orderId: _int(json['orderId']),
    discount: _double(json['discount']),
    status: json['status'] as String?,
    createdBy: _int(json['createdBy']),
    createdByName: json['createdByName'] as String?,
    items: (json['items'] as List<dynamic>? ?? []).map((e) {
      final v = e as Map<String, dynamic>;
      return SaleItem(
        productId: _int(v['productId']) ?? 0,
        productName: v['productName'] as String?,
        quantity: _double(v['quantity']),
        unitPrice: _double(v['unitPrice']),
        discount: _double(v['discount']),
      );
    }).toList(),
    payments: (json['payments'] as List<dynamic>? ?? []).map((e) {
      final v = e as Map<String, dynamic>;
      return SalePayment(
        paymentMethod: v['paymentMethod'] as String? ?? '',
        amount: _double(v['amount']),
        reference: v['reference'] as String?,
      );
    }).toList(),
  );
  factory SaleModel.fromEntity(Sale sale) => SaleModel(
    id: sale.id,
    saleNumber: sale.saleNumber,
    orderId: sale.orderId,
    discount: sale.discount,
    status: sale.status,
    createdBy: sale.createdBy,
    createdByName: sale.createdByName,
    items: sale.items,
    payments: sale.payments,
  );
  Map<String, dynamic> toJson() => {
    'saleNumber': saleNumber,
    'orderId': orderId,
    'discount': discount,
    'items': items
        .map(
          (i) => {
            'productId': i.productId,
            'quantity': i.quantity,
            'unitPrice': i.unitPrice,
            'discount': i.discount,
          },
        )
        .toList(),
    'payments': payments
        .map(
          (p) => {
            'paymentMethod': p.paymentMethod,
            'amount': p.amount,
            'reference': p.reference,
          },
        )
        .toList(),
  };
}

int? _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value');
double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
