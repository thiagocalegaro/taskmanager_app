class Usuario {
  final int? id;
  final String? username;
  final String? email;
  final String? password;

  Usuario({
    this.id,
    this.username,
    this.email,
    this.password,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }
  Usuario copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
  }) {
    return Usuario(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}