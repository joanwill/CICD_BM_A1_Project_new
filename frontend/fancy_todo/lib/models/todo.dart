class Todo {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final int priority;
  final DateTime? due;
  final String? pk;

  Todo(
      {required this.id,
      required this.title,
      this.description,
      this.isDone = false,
      this.priority = 1,
      this.due,
      this.pk = 'hotpartition'});

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
      id: j['Id'] ?? j['id'],
      title: j['Title'] ?? j['title'],
      description: j['Description'] ?? j['description'],
      isDone: j['IsDone'] ?? j['isDone'] ?? false,
      priority: j['Priority'] ?? j['priority'] ?? 1,
      due: j['Due'] != null ? DateTime.tryParse(j['Due']) : null,
      pk: j['Pk'] ?? j['pk']);

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Title': title,
        'Description': description,
        'IsDone': isDone,
        'Priority': priority,
        'Due': due?.toIso8601String(),
        'Pk': pk,
      };

  Todo copyWith(
          {String? title,
          String? description,
          bool? isDone,
          int? priority,
          DateTime? due,
          String pk = 'hotpartition'}) =>
      Todo(
          id: id,
          title: title ?? this.title,
          description: description ?? this.description,
          isDone: isDone ?? this.isDone,
          priority: priority ?? this.priority,
          due: due ?? this.due,
          pk: pk);
}
