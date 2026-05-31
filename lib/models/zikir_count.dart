class ZikirCount {
  final String id;
  final String name;
  final int count;
  final int target;
  final DateTime createdAt;

  const ZikirCount({
    required this.id,
    required this.name,
    required this.count,
    required this.target,
    required this.createdAt,
  });

  ZikirCount copyWith({
    String? id,
    String? name,
    int? count,
    int? target,
    DateTime? createdAt,
  }) {
    return ZikirCount(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
