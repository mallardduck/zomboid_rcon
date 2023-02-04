import 'package:zomboid_rcon/servers/models/server.dart';

class ServersRepo {
  final List<Server> _servers = [];

  List<Server> getServers() => _servers;

  void addServer(Server server) => _servers.add(server);
}