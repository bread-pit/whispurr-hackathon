class UserModel {
  final String id;
  final String name;
  final String email;
  final String mood; // 'happy', 'sad', 'okay', or 'awful'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mood,
  });

  // A simple method to update the user data without changing every field
  UserModel copyWith({
    String? name,
    String? mood,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      mood: mood ?? this.mood,
    );
  }
}