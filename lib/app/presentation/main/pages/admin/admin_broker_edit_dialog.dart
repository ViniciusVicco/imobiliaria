import '../widgets/profile/profile_photo_editor.dart';
import '../broker/helpers/property_image_picker_types.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'admin_brokers_controller.dart';

class AdminBrokerEditDialog extends StatefulWidget {
  const AdminBrokerEditDialog({
    super.key,
    required this.controller,
    required this.broker,
  });
  final AdminBrokersController controller;
  final AdminBrokerEntity broker;
  @override
  State<AdminBrokerEditDialog> createState() => _AdminBrokerEditDialogState();
}

class _AdminBrokerEditDialogState extends State<AdminBrokerEditDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.broker.name);
  late final _phone = TextEditingController(text: widget.broker.phone);
  late final _whatsapp = TextEditingController(text: widget.broker.whatsapp);
  late final _creci = TextEditingController(text: widget.broker.creci);
  late final _about = TextEditingController(text: widget.broker.about);
  late String _avatar = widget.broker.avatarUrl;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final field in [_name, _phone, _whatsapp, _creci, _about]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Editar corretor'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ProfilePhotoEditor(
                  key: ValueKey(widget.broker.id),
                  imageUrl: _avatar,
                  size: 120,
                  enabled: !_busy,
                  onUpload: _upload,
                ),
                _field('Nome completo', _name, requiredName: true),
                _field('Celular', _phone, requiredPhone: true),
                _field('WhatsApp', _whatsapp),
                _field('CRECI', _creci),
                _field('Apresentacao', _about, maxLines: 4),
                TextFormField(
                  initialValue: widget.broker.email,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  initialValue: widget.broker.brokerCode,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Codigo do corretor',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Aguarde...' : 'Salvar alteracoes'),
        ),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController field, {
    bool requiredName = false,
    bool requiredPhone = false,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: field,
      enabled: !_busy,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (requiredName && (value ?? '').trim().length < 2) {
          return 'Informe o nome completo.';
        }
        if (requiredPhone && (value ?? '').trim().isEmpty) {
          return 'Informe o celular.';
        }
        return null;
      },
    ),
  );

  Future<bool> _upload(PickedPropertyImage image) async {
    if (_busy) return false;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.controller.uploadAvatar(
      widget.broker.id,
      image,
    );
    if (!mounted) return result != null;
    setState(() {
      _busy = false;
      _error = widget.controller.editError;
      if (result != null) _avatar = result.avatarUrl;
    });
    return result != null;
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final saved = await widget.controller.saveBroker(
      widget.broker.id,
      UserProfileUpdateEntity(
        name: _name.text,
        phone: _phone.text,
        whatsapp: _whatsapp.text,
        creci: _creci.text,
        about: _about.text,
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = widget.controller.editError;
    });
    if (saved != null) Navigator.of(context).pop();
  }
}
