import 'dart:math';

import 'package:cyrel/cache/cache_data.dart';

class BaseEntity {
  const BaseEntity();

  BaseEntity.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toMap() {
    return {};
  }
}

class MagicEntity extends BaseEntity {
  late final Map<String, dynamic> _ultimateWorkaround;

  MagicEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    _ultimateWorkaround = json;
  }

  @override
  Map<String, dynamic> toMap() {
    return _ultimateWorkaround;
  }

  BaseEntity convertTo(Type k) {
    return entitiesFactory[k]!(_ultimateWorkaround);
  }
}

class BoolEntity extends BaseEntity {
  bool _b = false;

  BoolEntity.fromBool(bool b) {
    _b = b;
  }

  bool toBool() {
    return _b;
  }

  BoolEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    _b = json["bool"];
  }

  @override
  Map<String, dynamic> toMap() {
    return {"bool": _b};
  }
}

class MagicList<K extends BaseEntity> extends BaseEntity implements List<K> {
  final List<K> _list = List.empty(growable: true);

  MagicList() : super();

  MagicList.from(List<K> list) {
    _list.addAll(list);
  }

  MagicList.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    List<K> l = [];
    for (var o in json["list"]) {
      l.add(entitiesFactory[K]!(o));
    }
    _list.addAll(l);
  }

  @override
  Map<String, dynamic> toMap() {
    return {"list": _list.map((e) => e.toMap()).toList()};
  }

  @override
  K get first => _list.first;

  @override
  K get last => _list.last;

  @override
  int get length => _list.length;

  @override
  List<K> operator +(List<K> other) {
    return _list + other;
  }

  @override
  K operator [](int index) {
    return _list[index];
  }

  @override
  void operator []=(int index, K value) {
    _list[index] = value;
  }

  @override
  void add(K value) {
    _list.add(value);
  }

  @override
  void addAll(Iterable<K> iterable) {
    _list.addAll(iterable);
  }

  @override
  bool any(bool Function(K element) test) {
    return _list.any(test);
  }

  @override
  Map<int, K> asMap() {
    return _list.asMap();
  }

  @override
  List<R> cast<R>() {
    return _list.cast();
  }

  @override
  void clear() {
    _list.clear();
  }

  @override
  bool contains(Object? element) {
    return _list.contains(element);
  }

  @override
  K elementAt(int index) {
    return _list.elementAt(index);
  }

  @override
  bool every(bool Function(K element) test) {
    return _list.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(K element) toElements) {
    return _list.expand(toElements);
  }

  @override
  void fillRange(int start, int end, [K? fillValue]) {
    _list.fillRange(start, end, fillValue);
  }

  @override
  K firstWhere(bool Function(K element) test, {K Function()? orElse}) {
    return _list.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, K element) combine) {
    return _list.fold(initialValue, combine);
  }

  @override
  Iterable<K> followedBy(Iterable<K> other) {
    return _list.followedBy(other);
  }

  @override
  void forEach(void Function(K element) action) {
    _list.forEach(action);
  }

  @override
  Iterable<K> getRange(int start, int end) {
    return _list.getRange(start, end);
  }

  @override
  int indexOf(K element, [int start = 0]) {
    return _list.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(K element) test, [int start = 0]) {
    return _list.indexWhere(test, start);
  }

  @override
  void insert(int index, K element) {
    _list.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<K> iterable) {
    _list.insertAll(index, iterable);
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<K> get iterator => _list.iterator;

  @override
  String join([String separator = ""]) {
    return _list.join(separator);
  }

  @override
  int lastIndexOf(K element, [int? start]) {
    return _list.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(K element) test, [int? start]) {
    return _list.lastIndexWhere(test, start);
  }

  @override
  K lastWhere(bool Function(K element) test, {K Function()? orElse}) {
    return _list.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> map<T>(T Function(K e) toElement) {
    return _list.map(toElement);
  }

  @override
  K reduce(K Function(K value, K element) combine) {
    return _list.reduce(combine);
  }

  @override
  bool remove(Object? value) {
    return _list.remove(value);
  }

  @override
  K removeAt(int index) {
    return _list.removeAt(index);
  }

  @override
  K removeLast() {
    return _list.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(K element) test) {
    _list.removeWhere(test);
  }

  @override
  void replaceRange(int start, int end, Iterable<K> replacements) {
    _list.replaceRange(start, end, replacements);
  }

  @override
  void retainWhere(bool Function(K element) test) {
    _list.retainWhere(test);
  }

  @override
  Iterable<K> get reversed => _list.reversed;

  @override
  void setAll(int index, Iterable<K> iterable) {
    _list.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<K> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([Random? random]) {
    _list.shuffle(random);
  }

  @override
  K get single => _list.single;

  @override
  K singleWhere(bool Function(K element) test, {K Function()? orElse}) {
    return _list.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<K> skip(int count) {
    return _list.skip(count);
  }

  @override
  Iterable<K> skipWhile(bool Function(K value) test) {
    return _list.skipWhile(test);
  }

  @override
  void sort([int Function(K a, K b)? compare]) {
    _list.sort(compare);
  }

  @override
  List<K> sublist(int start, [int? end]) {
    return _list.sublist(start, end);
  }

  @override
  Iterable<K> take(int count) {
    return _list.take(count);
  }

  @override
  Iterable<K> takeWhile(bool Function(K value) test) {
    return _list.takeWhile(test);
  }

  @override
  List<K> toList({bool growable = true}) {
    return _list.toList(growable: growable);
  }

  @override
  Set<K> toSet() {
    return _list.toSet();
  }

  @override
  Iterable<K> where(bool Function(K element) test) {
    return _list.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _list.whereType();
  }

  @override
  set first(K value) {
    _list.first = value;
  }

  @override
  set last(K value) {
    _list.last = value;
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
  }
}
