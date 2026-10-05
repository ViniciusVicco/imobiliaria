import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';

class PropertyResponsibleDropdown extends StatelessWidget {
  const PropertyResponsibleDropdown({
    super.key,
    required this.brokers,
    required this.value,
    required this.onChanged,
    required this.currentName,
    required this.isNew,
  });
  final List<AdminBrokerEntity> brokers;
  final String? value;
  final String? currentName;
  final bool isNew;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedBroker = brokers.any((broker) => broker.id == value);
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(isNew ? 'Voce (admin)' : 'Sem responsavel'),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Responsavel pelo anuncio',
        helperText: isNew
            ? 'Sem outra escolha, o anuncio fica vinculado a voce.'
            : 'Selecione outra pessoa apenas para transferir o anuncio.',
      ),
      items: <DropdownMenuItem<String>>[
        if (value == null)
          DropdownMenuItem<String>(
            value: null,
            enabled: false,
            child: Text(isNew ? 'Voce (admin)' : 'Sem responsavel'),
          ),
        if (value != null && !hasSelectedBroker)
          DropdownMenuItem<String>(
            value: value,
            enabled: false,
            child: Text(
              '${currentName ?? 'Responsavel atual'} (indisponivel)',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ...brokers.map(
          (broker) => DropdownMenuItem<String>(
            value: broker.id,
            child: Text(
              '${broker.name}${broker.role == 'admin' ? ' (admin)' : ''}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
