import 'package:flutter_test/flutter_test.dart';
import 'package:fancy_todo/main.dart';

void main() {
  testWidgets('App loads and shows title', (tester) async {
    await tester.pumpWidget(const FancyTodoApp());
    expect(find.text('Fancy TODO'), findsOneWidget);
  });
}
