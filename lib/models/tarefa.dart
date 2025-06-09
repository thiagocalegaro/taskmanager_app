// models/tarefa.dart
import 'package:flutter/material.dart';

class Tarefa {
  String nome;
  String categoria;
  String? descricao; // Description can be optional
  DateTime data;
  bool isCompleted;
  bool isExpanded; // To handle UI expansion state

  Tarefa({
    required this.nome,
    required this.categoria,
    this.descricao,
    required this.data,
    this.isCompleted = false,
    this.isExpanded = false,
  });
}