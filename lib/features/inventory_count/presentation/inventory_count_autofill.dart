class InventoryCountAutofill {
  const InventoryCountAutofill._();

  /// Returns only the blank count fields that can safely receive the expected
  /// stock. Existing values are physical counts entered by the user.
  static Map<int, String> blankFieldsWithExpectedStock(
    Map<int, String> currentValues,
    Map<int, int> expectedStocks,
  ) {
    final suggestions = <int, String>{};

    for (final entry in expectedStocks.entries) {
      if ((currentValues[entry.key] ?? '').trim().isEmpty) {
        suggestions[entry.key] = entry.value.toString();
      }
    }

    return suggestions;
  }
}
