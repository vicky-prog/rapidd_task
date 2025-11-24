import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool completed;
  final List<String> sharedWith;
  final String ownerId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.sharedWith,
    required this.ownerId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'],
      completed: map['completed'],
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      ownerId: map['ownerId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'sharedWith': sharedWith,
      'ownerId': ownerId,
      'createdAt': createdAt,
    };
  }

  TaskModel copyWith({
    String? title,
    bool? completed,
    List<String>? sharedWith,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      sharedWith: sharedWith ?? this.sharedWith,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }
}
