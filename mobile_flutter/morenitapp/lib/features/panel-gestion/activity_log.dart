enum ActionType { create, update, delete }

class ActivityLog {
  final int? id;
  final String userId;
  final String userName;
  final ActionType action;
  final String entityName;
  final String description;
  final DateTime createdAt;

  ActivityLog({
    this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityName,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_name': userName,
    'action': action.name,
    'entity_name': entityName,
    'description': description,
  };

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      action: ActionType.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => ActionType.update,
      ),
      entityName: json['entity_name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
