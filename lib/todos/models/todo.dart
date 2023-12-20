class Todo {
  final String? id;
  final String title;
  final String? description;
  final bool completed;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  factory Todo.fromMap(Map<String, dynamic> data, String documentId) {
    return Todo(
      id: documentId,
      title: data['title'],
      description: data['description'],
      completed: data['completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  @override
  String toString() {
    return 'Todo { id: $id, title: $title, description: $description, completed: $completed }';
  }
}
