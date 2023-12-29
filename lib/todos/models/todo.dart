import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final List<String>? tags;
  final bool completed;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? eventId;

  Todo({
    this.id,
    this.title,
    this.description,
    this.tags,
    this.completed = false,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.eventId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        tags,
        completed,
        dueDate,
        createdAt,
        updatedAt,
        eventId,
      ];

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    bool? completed,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? eventId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventId: eventId ?? this.eventId,
    );
  }

  factory Todo.fromMap(Map<String, dynamic> data, String todoId) {
    return Todo(
      id: todoId,
      title: data['title'],
      description: data['description'],
      tags: List<String>.from(data['tags'] ?? []),
      completed: data['completed'],
      dueDate: data['dueDate']?.toDate(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      eventId: data['eventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'completed': completed,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'eventId': eventId,
    };
  }

  @override
  String toString() {
    return 'Todo { id: $id, title: $title, description: $description, tags: $tags, completed: $completed, dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt, eventId: $eventId }';
  }
}
