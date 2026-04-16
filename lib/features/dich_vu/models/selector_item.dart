// lib/features/dich_vu/models/selector_item.dart

class SelectorItem {
  final int id;
  final String name;

  const SelectorItem({required this.id, required this.name});

  factory SelectorItem.fromJson(Map<String, dynamic> json) {
    return SelectorItem(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  SelectorItem copyWith({int? id, String? name}) {
    return SelectorItem(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  String toString() => name;
}