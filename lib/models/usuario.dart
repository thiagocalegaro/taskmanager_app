class Usuario {
  String? id;
  String? nome;
  String? email;
  String? password;
  String? token;

  Usuario({
    this.id,
    this.nome,
    this.email,
    this.password,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password': password,
      'token': token,
    };
  }
}