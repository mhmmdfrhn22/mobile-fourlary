class UserModel {
  final int id;
  final String username;
  final int roleId;
  final String? token;

  UserModel({
    required this.id,
    required this.username,
    required this.roleId,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'] ?? json['id'],
      username: json['user']['username'] ?? json['username'],
      roleId: json['user']['role_id'] ?? json['role_id'],
      token: json['token'],
    );
  }
}