// lib/features/utils/models/selector_item_model.dart

class SelectorItemModel {
  final int id;
  final String name;

  const SelectorItemModel({required this.id, required this.name});

  factory SelectorItemModel.fromJson(Map<String, dynamic> json) =>
      SelectorItemModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is SelectorItemModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
