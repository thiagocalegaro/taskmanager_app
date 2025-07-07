class Usuario {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? imagePath;

  Usuario({
    this.id,
    this.username,
    this.email,
    this.password,
    this.imagePath,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      imagePath: map['image_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'image_path': imagePath,
    };
  }
  Usuario copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? imagePath,
  }) {
    return Usuario(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}