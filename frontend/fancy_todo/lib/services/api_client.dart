import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/todo.dart';

class ApiClient {
  // Update for your environment
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'https://todo-api-carmen.azurewebsites.net';
  // final String baseUrl;
  // ApiClient({this.baseUrl = 'https:///todo-api-carmen.azurewebsites.net'});

  Future<List<Todo>> listTodos() async {
    final resp = await http.get(Uri.parse('$baseUrl/api/todos'));
    if (resp.statusCode != 200) throw Exception('Failed to list todos');
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Todo.fromJson(e)).toList();
  }

  Future<Todo> create(Todo t) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toJson()),
    );
    if (resp.statusCode != 201) throw Exception('Failed to create');
    return Todo.fromJson(jsonDecode(resp.body));
  }

  Future<Todo> update(Todo t) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/todos/${t.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toJson()),
    );
    if (resp.statusCode != 200) throw Exception('Failed to update');
    return Todo.fromJson(jsonDecode(resp.body));
  }

  Future<void> delete(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/api/todos/$id'));
    if (resp.statusCode != 204) throw Exception('Failed to delete');
  }
}
