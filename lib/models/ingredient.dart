/// Data model representing a single ingredient.
class Ingredient {
  final String name;
  final String? quantity;
  final String? unit;

  const Ingredient({
    required this.name,
    this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
      };

  @override
  String toString() {
    final parts = <String>[];
    if (quantity != null) parts.add(quantity!);
    if (unit != null) parts.add(unit!);
    parts.add(name);
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}
