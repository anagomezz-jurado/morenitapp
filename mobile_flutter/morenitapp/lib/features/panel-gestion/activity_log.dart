enum ActionType { create, update, delete }

class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final ActionType action;
  final String entityName;
  final String description;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityName,
    required this.description,
    required this.createdAt,
  });
}
