import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Usuario.g.dart';

@JsonSerializable()
class Usuario {
  String idUser;
  String? nomeUsuario;
  String telefoneUsuario;

  Usuario({
    required this.idUser,
    this.nomeUsuario,
    required this.telefoneUsuario,
  });
  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}
