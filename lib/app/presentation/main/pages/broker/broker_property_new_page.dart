import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_properties_controller.dart';
import 'package:legend_core/legend_core.dart';

class BrokerPropertyNewPage extends StatefulWidget {
  const BrokerPropertyNewPage({super.key});

  @override
  State<BrokerPropertyNewPage> createState() => _BrokerPropertyNewPageState();
}

class _BrokerPropertyNewPageState
    extends
        StateController<
          MainModule,
          BrokerPropertyNewPage,
          BrokerPropertiesController
        > {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final wasCreated = await controller.createDraftAndOpenForm(replace: true);
      if (!wasCreated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.store.errorMessage ??
                  'Nao foi possivel criar o rascunho.',
            ),
          ),
        );
        Module.get<MainModule>().navigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
