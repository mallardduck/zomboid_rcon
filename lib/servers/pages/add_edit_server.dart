import 'package:enough_platform_widgets/enough_platform_widgets.dart';
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

PlatformTextFormField _preparePlatformTextFormField({
  String? initialValue,
  FormFieldValidator<String>? validator,
  required String fieldName,
  required String placeholder,
  MaterialTextFormFieldData Function(MaterialTextFormFieldData ctx)? materialExtra,
  CupertinoTextFormFieldData Function(CupertinoTextFormFieldData ctx)? cupertinoExtra,
}) {
  materialExtra ??= (ctx) => ctx;
  cupertinoExtra ??= (ctx) => ctx;
  return PlatformTextFormField(
    initialValue: initialValue,
    validator: validator,
    material: (_, __) => materialExtra!.call(MaterialTextFormFieldData(
      decoration: InputDecoration(
        hintText: placeholder,
      ),
    )),
    cupertino: (_, __) => cupertinoExtra!.call(CupertinoTextFormFieldData(
      prefix: Text(fieldName),
      placeholder: placeholder,
    )),
  );
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

        return PlatformScaffold(
          appBar: PlatformAppBar(
            title: PlatformText(widget.title),
          ),
          iosContentPadding: true,
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // TODO: Add padding here...
                children: <Widget>[
                  _preparePlatformTextFormField(
                    initialValue: (widgetServer != null) ?widgetServer.name : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a server name';
                      }
                      nameValue = value;
                      return null;
                    },
                    fieldName: 'Name',
                    placeholder: 'Enter a server name',
                  ),
                  _preparePlatformTextFormField(
                    initialValue: (widgetServer != null) ?widgetServer.address : '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid server IP';
                      }
                      ipValue = value;
                      return null;
                    },
                    fieldName: 'Address',
                    placeholder: 'Enter the servers IP'
                  ),
                  _preparePlatformTextFormField(
                    initialValue: (widgetServer != null) ? widgetServer.port.toString() : portValue.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid server IP';
                      }
                      portValue = int.parse(value);
                      return null;
                    },
                    fieldName: 'Port',
                    placeholder: 'Enter the RCON port number',
                    materialExtra: (MaterialTextFormFieldData ctx) {
                      return MaterialTextFormFieldData(
                        decoration: ctx.decoration,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      );
                    },
                    cupertinoExtra: (CupertinoTextFormFieldData ctx) {
                      return CupertinoTextFormFieldData(
                        prefix: ctx.prefix,
                        placeholder: ctx.placeholder,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      );
                    },
                  ),
                  _preparePlatformTextFormField(
                    initialValue: (widgetServer != null) ?widgetServer.password : '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the RCON password';
                      }
                      passwordValue = value;
                      return null;
                    },
                    fieldName: 'Password',
                    placeholder: 'Enter the RCON admin password',
                  ),
                  Row(
                    children: [
                      PlatformTextButton(
                        onPressed: () => Navigator.pop(context),
                        child: PlatformText('Cancel'),
                      ),
                      PlatformTextButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
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
                        child: PlatformText('Submit'),
                      )
                    ],
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