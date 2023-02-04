import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/servers/servers.dart';

import '../../terminal/pages/rcon.dart';
import 'add_edit_server.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: const ServersListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditServerPage(title: "Add Server")),
          );
        },
        tooltip: 'Add Server',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}

class ServersListView extends ConsumerWidget {
  const ServersListView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Server> servers = ref.watch(serversProvider);

    int index = 0;
    return ListView(
      children: [
        ...servers.map((server) {
          index++;
          return ListTile(
            title: Text("$index - ${server.name}"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditServerPage(
                      title: "Edit Server",
                      editServer: server,
                  )),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RconPage(server: server)),
              );
            },
            onLongPress: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirm Delete Server?'),
                  content: const Text('Are you sure you want to delete this server item?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(serversProvider.notifier).removeServer(server.id);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                )
            ),
          );
        })
      ],
    );
  }
  
}