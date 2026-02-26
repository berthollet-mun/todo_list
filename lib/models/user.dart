class User {
  String id;
  String username;
  String email;
  String password;
  String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profileImage,
  });

  // Coonversion d'un User en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profileImage': profileImage,
    };
  }

  // Creation d'un User a partir d'une Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }

  // Methode pour copier un User avec certianes valeurs modifiees
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email}';
  }
}
