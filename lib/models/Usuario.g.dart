// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      nomeUsuario: json['nomeUsuario'] as String?,
      telefoneUsuario: json['telefoneUsuario'] as String,
      imagemUrl: json['imagemUrl'] as String?,
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'nomeUsuario': instance.nomeUsuario,
      'telefoneUsuario': instance.telefoneUsuario,
      'imagemUrl': instance.imagemUrl,
    };
