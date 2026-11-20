abstract class BaseEntity {
  final String id;
  late final DateTime createdAt;
  late final DateTime updatedAt;

  BaseEntity({required this.id, DateTime? createdAt, DateTime? updatedAt}) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Entity ID cannot be empty.');
    }

    final now = DateTime.now();

    this.createdAt = createdAt ?? now;
    this.updatedAt = updatedAt ?? now;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BaseEntity &&
            runtimeType == other.runtimeType &&
            id == other.id);
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);
}
