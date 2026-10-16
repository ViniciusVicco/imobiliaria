import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/widgets/property_responsible_dropdown.dart';

const admin = AdminBrokerEntity(
  id: 'admin',
  name: 'Ana',
  email: '',
  phone: '',
  totalProperties: 0,
  role: 'admin',
);
const broker = AdminBrokerEntity(
  id: 'broker',
  name: 'Bruno',
  email: '',
  phone: '',
  totalProperties: 0,
);

void main() {
  for (final isNew in [true, false]) {
    testWidgets('default selection does not transfer ownership (new=$isNew)', (
      tester,
    ) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              child: PropertyResponsibleDropdown(
                brokers: const [admin, broker],
                value: null,
                currentName: null,
                isNew: isNew,
                onChanged: changes.add,
              ),
            ),
          ),
        ),
      );
      expect(changes, isEmpty);
      expect(
        find.text(isNew ? 'Voce (admin)' : 'Sem responsavel'),
        findsWidgets,
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ana (admin)').last);
      await tester.pumpAndSettle();
      expect(changes, ['admin']);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'inactive current responsible remains visible without implicit reassignment',
    (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyResponsibleDropdown(
              brokers: const [admin],
              value: 'inactive',
              currentName: 'Original',
              isNew: false,
              onChanged: changes.add,
            ),
          ),
        ),
      );
      expect(find.text('Original (indisponivel)'), findsOneWidget);
      expect(changes, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
