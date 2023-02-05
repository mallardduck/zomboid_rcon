import 'dart:io';

import 'package:source_server/source_server.dart';

class ZomboidServer implements RconSocket, QuerySocket {
  /// The address used for the connection.
  final dynamic address;

  /// The port used for the connection.
  final int port;

  /// Timeout to wait for the remote server reply.
  final Duration timeout;

  final QuerySocket _querySocket;

  RconSocket? _rconSocket;

  ZomboidServer._(
      this.address,
      this.port,
      this._querySocket,
      this._rconSocket,
      this.timeout,
      );

  /// Connects to the remote server using the server query protocol
  /// and the rcon protocol if the password was specified.
  /// This throws a [SocketException] if the authentication with the remote server failed.
  static Future<ZomboidServer> connect(
      dynamic address,
      int port, {
        String? password,
        Duration timeout = const Duration(seconds: 30),
      }) async {
    final querySocket = await QuerySocket.connect(address, port);
    RconSocket? rconSocket;
    if (password != null) {
      rconSocket = await RconSocket.connect(address, port).timeout(timeout);
      final result = await rconSocket.authenticate(password).timeout(timeout);
      if (!result) {
        querySocket.close();
        rconSocket.close();
        throw RconAuthenticationException(rconSocket.errorMessage ?? '');
      }
    }
    return ZomboidServer._(address, port, querySocket, rconSocket, timeout);
  }

  /// Authenticates to the remote server.
  /// Throws a [RconAuthenticationException] if the authentication fails.
  /// Can be used to connected to the rcon without specifying the password in [connect].
  @override
  Future<bool> authenticate(String password) async {
    if (_rconSocket != null) {
      return true;
    }
    _rconSocket = await RconSocket.connect(address, port).timeout(timeout);
    final result = await _rconSocket!.authenticate(password).timeout(timeout);
    if (!result) {
      _rconSocket!.close();
      throw RconAuthenticationException(_rconSocket!.errorMessage ?? '');
    }
    return true;
  }

  @override
  void close() {
    _querySocket.close();
    _rconSocket?.close();
  }

  @override
  Future<String> command(String command) {
    if (_rconSocket == null) {
      throw const RconException(
        'Cannot send an RCON command while not authenticated!',
      );
    }
    return _rconSocket!.command(command).timeout(timeout);
  }

  @override
  Stream<String> get commandStream {
    assert(_rconSocket != null);
    return _rconSocket!.commandStream;
  }

  @override
  String? get errorMessage => _rconSocket?.errorMessage;

  @override
  Future<ServerInfo> getInfo() {
    // TODO: implement getInfo
    throw UnimplementedError();
  }

  @override
  Future<List<QueryPlayer>> getPlayers() {
    // TODO: implement getPlayers
    throw UnimplementedError();
  }

  @override
  Future<List<ServerRule>> getRules() {
    // TODO: implement getRules
    throw UnimplementedError();
  }
}