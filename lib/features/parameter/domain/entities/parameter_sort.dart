import 'parameter.dart';

/// Mantiene el orden configurado para cada código de parámetro sin mezclar
/// colecciones distintas. Los empates quedan estables por su identificador.
List<T> sortParametersByOrderNumber<T extends Parameter>(Iterable<T> values) {
  final sorted = List<T>.from(values);
  sorted.sort((first, second) {
    final byOrder = first.orderNumber.compareTo(second.orderNumber);
    if (byOrder != 0) return byOrder;
    return first.parameterId.compareTo(second.parameterId);
  });
  return sorted;
}
