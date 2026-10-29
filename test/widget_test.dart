import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist/main.dart';

void main() {
  testWidgets('permite deslizar y muestra acciones', (tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('To Do List'), findsOneWidget);
    expect(find.text('Ingresa una tarea...'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(find.byIcon(Icons.add), findsOneWidget);

    for (final task in ['tarea5', 'tarea1', 'tarea4', 'tarea2', 'tarea3']) {
      expect(find.text(task), findsOneWidget);
    }

    await tester.tap(find.byIcon(Icons.add));
    await tester.drag(find.text('tarea5'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('tarea5'), findsOneWidget);
    expect(find.byTooltip('Editar tarea'), findsOneWidget);
    expect(find.byTooltip('Borrar tarea'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Borrar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('tarea5'), findsOneWidget);
    expect(find.byTooltip('Editar tarea'), findsOneWidget);
    expect(find.byTooltip('Borrar tarea'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsNothing);
  });
}
