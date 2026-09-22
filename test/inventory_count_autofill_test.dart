import 'package:app_movil_sistema/features/inventory_count/presentation/inventory_count_autofill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fills only blank physical counts with the expected stock', () {
    final suggestions = InventoryCountAutofill.blankFieldsWithExpectedStock(
      {1: '', 2: '4', 3: '  '},
      {1: 4, 2: 5, 3: 0},
    );

    expect(suggestions, {1: '4', 3: '0'});
  });

  test('does not replace a corrected physical count', () {
    final suggestions = InventoryCountAutofill.blankFieldsWithExpectedStock(
      {10: '4'},
      {10: 5},
    );

    expect(suggestions, isEmpty);
  });
}
