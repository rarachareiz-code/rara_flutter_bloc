import 'dart:convert';

import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  Item copyWith(
      {String? id, String? title, bool? isDone, DateTime? createdAt}) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, title, isDone, createdAt];
}
