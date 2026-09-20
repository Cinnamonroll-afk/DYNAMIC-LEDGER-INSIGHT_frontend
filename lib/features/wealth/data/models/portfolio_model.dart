class PortfolioModel {
  final String id;
  final String userId;
  final String name;
  final int icon;
  final String note;
  final double? targetGoal;
  final DateTime createdAt;
  final double totalValue;
  final double change;
  final double changePercent;
  final String currentTrend;
  final bool isArchived;

  const PortfolioModel({
    required this.id,
    required this.userId,
    required this.name,
    this.icon = 0,
    this.note = '',
    this.targetGoal,
    required this.createdAt,
    this.totalValue = 0.0,
    this.change = 0.0,
    this.changePercent = 0.0,
    this.currentTrend = 'up',
    this.isArchived = false,
  });

  factory PortfolioModel.fromMap(Map<String, dynamic> map, String id) {
    return PortfolioModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      icon: map['icon'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      targetGoal: (map['target_goal'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      totalValue: (map['total_value'] as num?)?.toDouble() ?? 0.0,
      change: (map['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (map['change_percent'] as num?)?.toDouble() ?? 0.0,
      currentTrend: map['current_trend'] as String? ?? 'up',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'icon': icon,
      'note': note,
      'target_goal': targetGoal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PortfolioModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? icon,
    String? note,
    double? targetGoal,
    DateTime? createdAt,
    double? totalValue,
    double? change,
    double? changePercent,
    String? currentTrend,
    bool? isArchived,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      note: note ?? this.note,
      targetGoal: targetGoal ?? this.targetGoal,
      createdAt: createdAt ?? this.createdAt,
      totalValue: totalValue ?? this.totalValue,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      currentTrend: currentTrend ?? this.currentTrend,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
