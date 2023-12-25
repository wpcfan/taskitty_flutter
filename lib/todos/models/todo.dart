class Todo {
  final String? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Todo.fromMap(Map<String, dynamic> data, String todoId) {
    return Todo(
      id: todoId,
      title: data['title'],
      description: data['description'],
      completed: data['completed'],
      dueDate: data['dueDate']?.toDate(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Todo { id: $id, title: $title, description: $description, completed: $completed, dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
