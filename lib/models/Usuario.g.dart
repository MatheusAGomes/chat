// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      idUser: json['idUser'] as String,
      nomeUsuario: json['nomeUsuario'] as String?,
      telefoneUsuario: json['telefoneUsuario'] as String,
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'idUser': instance.idUser,
      'nomeUsuario': instance.nomeUsuario,
      'telefoneUsuario': instance.telefoneUsuario,
    };
