import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';

@immutable
class Server {
  Server({
    String? id,
    required this.name,
    required this.address,
    required this.port,
    required this.password,
  }) {
    this.id = id ?? const Uuid().v4();
  }

  late final String id;
  final String name;
  final String address;
  final int port;
  final String password;

  Server copyWith({String? id, String? name, String? address, int? port, String? password}) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      password: password ?? this.password,
    );
  }
}