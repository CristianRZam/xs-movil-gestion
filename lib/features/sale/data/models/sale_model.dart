import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';

class SaleModel extends Sale {
  const SaleModel({
    super.id,
    required super.saleNumber,
    super.orderId,
    super.orderNumber,
    super.notes,
    super.discount,
    super.packagingCharge,
    super.deliveryCharge,
    super.status,
    super.createdBy,
    super.createdByName,
    super.cancellationReason,
    super.cancelledBy,
    super.cancelledByName,
    super.cancelledAt,
    super.createdAt,
    super.itemCount,
    super.totalQuantity,
    super.totalAmount,
    required super.items,
    required super.payments,
  });
  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: _int(json['id']),
    saleNumber: json['saleNumber'] as String? ?? '',
    orderId: _int(json['orderId']),
    orderNumber: json['orderNumber'] as String?,
    notes: json['notes'] as String?,
    discount: _double(json['discount']),
    packagingCharge: _double(json['packagingCharge']),
    deliveryCharge: _double(json['deliveryCharge']),
    status: json['status'] as String?,
    createdBy: _int(json['createdBy']),
    createdByName: json['createdByName'] as String?,
    cancellationReason: json['cancellationReason'] as String?,
    cancelledBy: _int(json['cancelledBy']),
    cancelledByName: json['cancelledByName'] as String?,
    cancelledAt: _date(json['cancelledAt']),
    createdAt: _date(json['createdAt']),
    itemCount: _int(json['itemCount']),
    totalQuantity: json['totalQuantity'] == null ? null : _double(json['totalQuantity']),
    totalAmount: json['total'] == null ? null : _double(json['total']),
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
    payments: _payments(json),
  );
  factory SaleModel.fromEntity(Sale sale) => SaleModel(
    id: sale.id,
    saleNumber: sale.saleNumber,
    orderId: sale.orderId,
    orderNumber: sale.orderNumber,
    notes: sale.notes,
    discount: sale.discount,
    packagingCharge: sale.packagingCharge,
    deliveryCharge: sale.deliveryCharge,
    status: sale.status,
    createdBy: sale.createdBy,
    createdByName: sale.createdByName,
    cancellationReason: sale.cancellationReason,
    cancelledBy: sale.cancelledBy,
    cancelledByName: sale.cancelledByName,
    cancelledAt: sale.cancelledAt,
    createdAt: sale.createdAt,
    itemCount: sale.itemCount,
    totalQuantity: sale.totalQuantity,
    totalAmount: sale.totalAmount,
    items: sale.items,
    payments: sale.payments,
  );
  Map<String, dynamic> toJson() => {
    'saleNumber': saleNumber,
    'orderId': orderId,
    'notes': notes,
    'discount': discount,
    'packagingCharge': packagingCharge,
    'deliveryCharge': deliveryCharge,
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
            if (p.receivedAmount != null) 'receivedAmount': p.receivedAmount,
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

List<SalePayment> _payments(Map<String, dynamic> json) {
  final payments = json['payments'] as List<dynamic>? ?? const [];
  if (payments.isNotEmpty) {
    return payments.map((entry) {
      final value = entry as Map<String, dynamic>;
      return SalePayment(
        paymentMethod: value['paymentMethod'] as String? ?? '',
        amount: _double(value['amount']),
        receivedAmount:
            value['receivedAmount'] == null ? null : _double(value['receivedAmount']),
        changeAmount:
            value['changeAmount'] == null ? null : _double(value['changeAmount']),
        reference: value['reference'] as String?,
      );
    }).toList();
  }
  return (json['paymentMethods'] as List<dynamic>? ?? const [])
      .map((method) => SalePayment(paymentMethod: '$method', amount: 0))
      .toList();
}

DateTime? _date(dynamic value) => value == null ? null : DateTime.tryParse('$value');
