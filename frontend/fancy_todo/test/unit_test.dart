import 'package:flutter_test/flutter_test.dart';
import 'package:fancy_todo/models/todo.dart';

void main() {
  test('Todo serialization roundtrip', () {
    final t = Todo(id: '1', title: 'X', priority: 2);
    final j = t.toJson();
    final t2 = Todo.fromJson(j);
    expect(t2.title, 'X');
    expect(t2.priority, 2);
  });
}
