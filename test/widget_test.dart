import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist/main.dart';

void main() {
  testWidgets('permite escribir y agregar tareas sin cambiar el diseño', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('To Do List'), findsOneWidget);
    expect(find.text('Ingresa una tarea...'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isFalse);
    expect(find.byIcon(Icons.add), findsOneWidget);

    for (final task in ['tarea5', 'tarea1', 'tarea4', 'tarea2', 'tarea3']) {
      expect(find.text(task), findsOneWidget);
    }

    await tester.enterText(find.byType(TextField), '  nueva tarea  ');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('nueva tarea'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

    await tester.enterText(find.byType(TextField), 'tarea por Enter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('tarea por Enter'), findsOneWidget);

    await tester.drag(find.text('tarea5'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Editar tarea'), findsOneWidget);
    expect(find.byTooltip('Borrar tarea'), findsOneWidget);
  });

  testWidgets('editar abre un cuadro y borrar elimina la tarea', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());

    await tester.drag(find.text('tarea5'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'tarea editada');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('tarea editada'), findsOneWidget);
    expect(find.text('tarea5'), findsNothing);

    await tester.drag(find.text('tarea editada'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Borrar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('tarea editada'), findsNothing);
  });
}
