import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/widgets/login_form.dart';

void main() {
  testWidgets(
    'submits credentials and preserves fields across loading rebuilds',
    (tester) async {
      final submissions = <(String, String)>[];
      var isLoading = false;
      late StateSetter rebuild;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 460,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    rebuild = setState;
                    return LoginForm(
                      isLoading: isLoading,
                      onSubmit: (email, password) {
                        submissions.add((email, password));
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).first,
        'broker@example.com',
      );
      await tester.enterText(find.byType(TextField).last, 'secret');
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is FilledButton),
      );
      expect(submissions, [('broker@example.com', 'secret')]);

      rebuild(() => isLoading = true);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.byWidgetPredicate((widget) => widget is FilledButton),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).enabled,
        isFalse,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).last).enabled,
        isFalse,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      rebuild(() => isLoading = false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'broker@example.com',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'secret',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.showKeyboard(find.byType(TextField).last);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submissions, [
        ('broker@example.com', 'secret'),
        ('broker@example.com', 'secret'),
      ]);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [390.0, 800.0, 1440.0]) {
    testWidgets('login form fits width $width with enlarged text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 900),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: LoginForm(isLoading: false, onSubmit: (_, _) {}),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(TextField), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
}
