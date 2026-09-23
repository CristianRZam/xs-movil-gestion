import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filters products by name and code', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: ProductSelectorSheet(products: [_coffee, _juice]),
          ),
        ),
      ),
    );

    expect(find.text('Café americano'), findsOneWidget);
    expect(find.text('Jugo de naranja'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'JUG-002');
    await tester.pump();

    expect(find.text('Café americano'), findsNothing);
    expect(find.text('Jugo de naranja'), findsOneWidget);
  });
}

const _coffee = Product(
  id: 1,
  code: 'CAF-001',
  name: 'Café americano',
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
