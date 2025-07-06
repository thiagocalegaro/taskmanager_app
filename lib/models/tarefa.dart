// models/tarefa.dart
import 'package:flutter/material.dart';
import 'package:task_manager/models/usuario.dart';

class Tarefa {
  final int? id;
  final String nome;
  final String categoria;
  final String? descricao;
  final DateTime data;
  bool isCompleted;
  bool isExpanded;
  final Usuario usuario; // ✅ MODIFICADO: Agora guarda o objeto Usuario inteiro

  Tarefa({
    this.id,
    required this.nome,
    required this.categoria,
    this.descricao,
    required this.data,
    this.isCompleted = false,
    this.isExpanded = false,
    required this.usuario, // ✅ MODIFICADO: Agora é um parâmetro obrigatório
  });

  // O método toMap "desmonta" o objeto para o formato do banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      // ✅ IMPORTANTE: Extrai apenas o ID do usuário para salvar na coluna 'usuario_id'
      'usuario_id': usuario.id,
    };
  }
  Tarefa copyWith({
    int? id,
    String? nome,
    String? categoria,
    String? descricao,
    DateTime? data,
    bool? isCompleted,
    bool? isExpanded,
    Usuario? usuario,
  }) {
    return Tarefa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      isCompleted: isCompleted ?? this.isCompleted,
      isExpanded: isExpanded ?? this.isExpanded,
      usuario: usuario ?? this.usuario,
    );
  }
}