import 'package:app_movil_sistema/features/parameter/domain/entities/parameter.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('delegates search to the paginated catalog', (tester) async {
    String? search;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: ProductSelectorSheet(
              products: const [_coffee, _juice],
              onSearchChanged: (value) => search = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cafe americano'), findsOneWidget);
    expect(find.text('Jugo de naranja'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'JUG-002');
    await tester.pump(const Duration(milliseconds: 350));

    expect(search, 'JUG-002');
    // El filtrado final se realiza en backend para respetar la paginacion.
    expect(find.text('Cafe americano'), findsOneWidget);
    expect(find.text('Jugo de naranja'), findsOneWidget);
  });

  testWidgets('sends category and availability filters', (tester) async {
    List<int>? categoryIds;
    bool? availableOnly;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: ProductSelectorSheet(
              products: const [_coffee],
              categories: const [_beverages],
              onFiltersChanged: (categories, available) {
                categoryIds = categories;
                availableOnly = available;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bebidas'));
    await tester.pump();
    expect(categoryIds, [1]);
    expect(availableOnly, isFalse);

    await tester.tap(find.text('Disponibles'));
    await tester.pump();
    expect(categoryIds, isEmpty);
    expect(availableOnly, isTrue);
  });
}

const _beverages = Parameter(
  id: 1,
  parameterId: 1,
  parentParameterId: null,
  name: 'Bebidas',
  shortName: 'Bebidas',
  active: true,
);

const _coffee = Product(
  id: 1,
  code: 'CAF-001',
  name: 'Cafe americano',
  categoryId: 1,
  nameCategory: 'Bebidas',
  unitMeasureId: 1,
  nameUnitMeasure: 'Unidad',
  valuationMethodId: 1,
  nameValuationMethod: 'Promedio',
  manageVariants: false,
  basePrice: 7,
  baseCost: 3,
  totalStock: 10,
  reservedStock: 0,
  active: true,
  deleted: false,
);

const _juice = Product(
  id: 2,
  code: 'JUG-002',
  name: 'Jugo de naranja',
  categoryId: 1,
  nameCategory: 'Bebidas',
  unitMeasureId: 1,
  nameUnitMeasure: 'Unidad',
  valuationMethodId: 1,
  nameValuationMethod: 'Promedio',
  manageVariants: false,
  basePrice: 9,
  baseCost: 4,
  totalStock: 8,
  reservedStock: 0,
  active: true,
  deleted: false,
);
