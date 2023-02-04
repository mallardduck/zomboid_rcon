import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zomboid_rcon/servers/servers.dart';

class AddEditServerPage extends ConsumerStatefulWidget {
  final String title;

  final Server? editServer;

  const AddEditServerPage({super.key, required this.title, this.editServer});

  @override
  ConsumerState<AddEditServerPage> createState() => _AddEditServerPageState();
}

class _AddEditServerPageState extends ConsumerState<AddEditServerPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    late final String nameValue;
    late final String ipValue;
    int portValue = 16260;
    late final String passwordValue;
    Server? widgetServer = widget.editServer;

    return Consumer(
      builder: (context, ref, child) {
        ServerNotifier notifier = ref.read(serversProvider.notifier);


        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // TODO: Add padding here...
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter a server name',
                    ),
                    initialValue: (widgetServer != null) ?widgetServer.name : '',
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a server name';
                      }
                      nameValue = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter the servers IP address',
                    ),
                    initialValue: (widgetServer != null) ?widgetServer.address : '',
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid server IP';
                      }
                      ipValue = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Enter the servers RCON port number',
                    ),
                    initialValue: (widgetServer != null) ? widgetServer.port.toString() : portValue.toString(),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid server IP';
                      }
                      portValue = int.parse(value);
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter the servers RCON password',
                    ),
                    initialValue: (widgetServer != null) ?widgetServer.password : '',
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the RCON password';
                      }
                      passwordValue = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          _formKey.currentState?.save();
                          if (widgetServer != null) {
                            notifier.updateServer(widgetServer.copyWith(
                              name: nameValue,
                              address: ipValue,
                              port: portValue,
                              password: passwordValue,
                            ));
                          } else {
                            notifier.addServer(Server(
                              name: nameValue,
                              address: ipValue,
                              port: portValue,
                              password: passwordValue,
                            ));
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}