class AppUser {
  final String id;
  final String name;
  final String avatarUrl;

  const AppUser({required this.id, required this.name, required this.avatarUrl});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'avatar_url': avatarUrl};

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(id: json['id'] as String, name: json['name'] as String, avatarUrl: json['avatar_url'] as String);
  }
}
