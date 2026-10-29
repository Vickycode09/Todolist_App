import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist/main.dart';

void main() {
  testWidgets('muestra la to-do list y agrega una tarea', (tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('To Do List'), findsOneWidget);
    expect(find.text('tarea5'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nueva tarea');
    await tester.tap(find.byTooltip('Agregar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.text('Ingresa una tarea...'), findsOneWidget);
  });

  testWidgets('edits a task from the swipe actions', (tester) async {
    await tester.pumpWidget(const TodoApp());

    await tester.drag(find.text('tarea5'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Editar tarea'), findsOneWidget);
    expect(find.byTooltip('Borrar tarea'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Editar tarea'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'cambio cancelado');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('tarea5'), findsOneWidget);
    expect(find.text('cambio cancelado'), findsNothing);

    await tester.drag(find.text('tarea5'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Editar tarea'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'tarea editada');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('tarea editada'), findsOneWidget);
    expect(find.text('tarea5'), findsNothing);
  });

  testWidgets('deletes a task from the swipe actions', (tester) async {
    await tester.pumpWidget(const TodoApp());

    await tester.drag(find.text('tarea5'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Borrar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('tarea5'), findsNothing);
  });
}
