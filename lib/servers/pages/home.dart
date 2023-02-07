import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/servers/pages/add_edit_server.dart';
import 'package:zomboid_rcon/servers/servers.dart';
import 'package:zomboid_rcon/terminal/pages/rcon.dart';

Null Function() _launchForm(BuildContext context) {
  return () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditServerPage(title: "Add Server")),
    );
  };
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: PlatformText(title),
        trailingActions: <Widget>[
          PlatformIconButton(
            onPressed: _launchForm(context),
            icon: Icon(PlatformIcons(context).add),
          )
        ],
      ),
      body: const ServersListView(),
      iosContentPadding: true
    );
  }
}

class ServersListView extends ConsumerWidget {
  const ServersListView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Server> servers = ref.watch(serversProvider);

    if (servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlatformText('No Servers Yet!'),
            PlatformTextButton(
              onPressed: _launchForm(context),
              child: PlatformText('Add Server'),
            ),
          ],
        ),
      );
    }

    var children = _buildListItems(context, ref, servers);
    return PlatformWidget(
      material: (_, __) => ListView(children: children),
      cupertino: (_, __) => CupertinoListSection(children: children),
    );
  }

  List<PlatformWidget> _buildListItems(BuildContext context, WidgetRef ref, List<Server> servers) {
    int index = 0;
    return servers.map((server) {
      index++;
      return _buildListItem(context, ref, index, server);
    }).toList();
  }

  PlatformWidget _buildListItem(BuildContext context, WidgetRef ref, int index, Server server) {
    return PlatformWidget(
      material: (_, __) => ListTile(
        title: Text("$index - ${server.name}"),
        subtitle: Text("${server.address} - ${server.port}"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditServerPage(
              title: "Edit Server",
              editServer: server,
            )));
          },
        ),
        onTap: _onServerTap(context, server),
        onLongPress: _onServerLongPress(context, ref, server),
      ),
      cupertino: (_, __) => CupertinoListTile(
        title: Text("$index - ${server.name}"),
        onTap: _onServerTap(context, server),
        trailing: CupertinoButton(
          onPressed: () => _showActionSheet(context, ref, server),
          child: const Icon(CupertinoIcons.ellipsis_vertical),
        ),
        subtitle: Text("${server.address} - ${server.port}"),
      ),
    );
  }

  Null Function() _onServerTap(context, Server server) {
    return () {
      PageRoute pageRoute;
      if (Platform.isIOS | Platform.isMacOS) {
        pageRoute = CupertinoPageRoute(builder: (context) => RconPage(serverConfig: server));
      } else {
        pageRoute = MaterialPageRoute(builder: (context) => RconPage(serverConfig: server));
      }
      Navigator.push(context, pageRoute);
    };
  }

  Future<String?> Function() _onServerLongPress(context, ref, server) {
    return () => showPlatformDialog<String>(
        context: context,
        builder: (BuildContext context) => PlatformAlertDialog(
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
    );
  }

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void _showActionSheet(BuildContext context, WidgetRef ref, server) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) => AddEditServerPage(
                title: "Edit Server",
                editServer: server,
              )));
            },
            child: const Text('Edit Server'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _onServerLongPress(context, ref, server)();
            },
            child: const Text('Delete Server'),
          ),
        ],
      ),
    );
  }
}