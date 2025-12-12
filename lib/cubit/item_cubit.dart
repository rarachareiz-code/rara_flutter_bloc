import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../repository/item_repository.dart';

class ItemCubit extends Cubit<List<Item>> {
  final ItemRepository repository;
  final _uuid = const Uuid();

  ItemCubit({required this.repository}) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final items = await repository.loadItems();
    // ensure sorted by createdAt desc
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(items);
  }

  Future<void> add(String title) async {
    final newItem = Item(
      id: _uuid.v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
    );
    final next = [newItem, ...state];
    emit(next);
    await repository.saveItems(next);
  }

  Future<void> toggleDone(String id) async {
    final next = state.map((e) {
      if (e.id == id) return e.copyWith(isDone: !e.isDone);
      return e;
    }).toList();
    emit(next);
    await repository.saveItems(next);
  }

  Future<void> delete(String id) async {
    final next = state.where((e) => e.id != id).toList();
    emit(next);
    await repository.saveItems(next);
  }

  Future<void> updateTitle(String id, String title) async {
    final next = state.map((e) {
      if (e.id == id) return e.copyWith(title: title);
      return e;
    }).toList();
    emit(next);
    await repository.saveItems(next);
  }

  Future<void> clearAll() async {
    emit([]);
    await repository.clear();
  }
}
