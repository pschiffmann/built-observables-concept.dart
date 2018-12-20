import 'dart:math';

import 'package:collection/collection.dart';

class ManagedList<E> extends DelegatingList<E> {
  ManagedList(this._notifyChange) : super([]);

  final void Function() _notifyChange;

  @override
  set first(E value) {
    super.first = value;
    _notifyChange();
  }

  @override
  set last(E value) {
    super.last = value;
    _notifyChange();
  }

  @override
  set length(int newLength) {
    super.length = newLength;
    _notifyChange();
  }

  @override
  void add(E value) {
    super.add(value);
    _notifyChange();
  }

  @override
  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    _notifyChange();
  }

  @override
  List<T> cast<T>() => List.castFrom(this);

  @override
  void clear() {
    super.clear();
    _notifyChange();
  }

  @override
  void fillRange(int start, int end, [E fillValue]) {
    super.fillRange(start, end, fillValue);
    _notifyChange();
  }

  @override
  void insert(int index, E element) {
    super.insert(index, element);
    _notifyChange();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    super.insertAll(index, iterable);
    _notifyChange();
  }

  @override
  bool remove(Object value) {
    final result = super.remove(value);
    _notifyChange();
    return result;
  }

  @override
  E removeAt(int index) {
    final result = super.removeAt(index);
    _notifyChange();
    return result;
  }

  @override
  E removeLast() {
    final result = super.removeLast();
    _notifyChange();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    super.removeRange(start, end);
    _notifyChange();
  }

  @override
  void removeWhere(bool Function(E) test) {
    super.removeWhere(test);
    _notifyChange();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    super.replaceRange(start, end, iterable);
    _notifyChange();
  }

  @override
  void retainWhere(bool Function(E) test) {
    super.retainWhere(test);
    _notifyChange();
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    super.setAll(index, iterable);
    _notifyChange();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    super.setRange(start, end, iterable, skipCount);
    _notifyChange();
  }

  @override
  void shuffle([Random random]) {
    super.shuffle(random);
    _notifyChange();
  }

  @override
  void sort([Comparator<E> compare]) {
    super.sort(compare);
    _notifyChange();
  }

  @override
  void operator []=(int index, E value) {
    super[index] = value;
    _notifyChange();
  }
}

class ManagedMap<K, V> extends DelegatingMap<K, V> {
  ManagedMap(this._notifyChange) : super({});

  final void Function() _notifyChange;

  @override
  void operator []=(K key, V value) {
    super[key] = value;
    _notifyChange();
  }

  @override
  void addAll(Map<K, V> other) {
    super.addAll(other);
    _notifyChange();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    super.addEntries(entries);
    _notifyChange();
  }

  @override
  void clear() {
    super.clear();
    _notifyChange();
  }

  @override
  Map<K2, V2> cast<K2, V2>() => Map.castFrom(this);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    if (containsKey(key)) return this[key];
    final result = this[key] = ifAbsent();
    _notifyChange();
    return result;
  }

  @override
  V remove(Object key) {
    final result = super.remove(key);
    _notifyChange();
    return result;
  }

  @override
  void removeWhere(bool test(K key, V value)) {
    super.removeWhere(test);
    _notifyChange();
  }

  @override
  V update(K key, V Function(V) update, {V Function() ifAbsent}) {
    final result = super.update(key, update, ifAbsent: ifAbsent);
    _notifyChange();
    return result;
  }

  @override
  void updateAll(V Function(K, V) update) {
    super.updateAll(update);
    _notifyChange();
  }
}
