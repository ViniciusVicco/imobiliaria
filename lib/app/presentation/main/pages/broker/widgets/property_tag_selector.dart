import 'package:flutter/material.dart';
import '../property_tag_catalog.dart';

class PropertyTagSelector extends StatefulWidget {
  const PropertyTagSelector({
    super.key,
    required this.catalog,
    required this.selected,
    required this.onChanged,
    required this.isAdmin,
  });
  final PropertyTagCatalog catalog;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool isAdmin;
  @override
  State<PropertyTagSelector> createState() => _PropertyTagSelectorState();
}

class _PropertyTagSelectorState extends State<PropertyTagSelector> {
  List<PropertyTag>? tags;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await widget.catalog.load(admin: widget.isAdmin);
      if (mounted)
        setState(() {
          tags = result;
          failed = false;
        });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  Future<void> edit([PropertyTag? tag]) async {
    final label = TextEditingController(text: tag?.label ?? '');
    final slug = TextEditingController(text: tag?.slug ?? '');
    final description = TextEditingController(text: tag?.description ?? '');
    var active = tag?.isActive ?? true;
    final value = await showDialog<PropertyTag>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(tag == null ? 'Nova tag' : 'Editar tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: label,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                if (tag == null)
                  TextField(
                    controller: slug,
                    decoration: const InputDecoration(
                      labelText: 'Identificador (letras minusculas e hifens)',
                    ),
                  ),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Descricao'),
                ),
                SwitchListTile(
                  title: const Text('Ativa'),
                  value: active,
                  onChanged: (v) => update(() => active = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (label.text.trim().isEmpty ||
                    !RegExp(
                      r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
                    ).hasMatch(slug.text.trim()))
                  return;
                Navigator.pop(
                  context,
                  PropertyTag(
                    slug: slug.text.trim(),
                    label: label.text.trim(),
                    description: description.text.trim(),
                    isActive: active,
                    sortOrder: tag?.sortOrder ?? 0,
                  ),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    label.dispose();
    slug.dispose();
    description.dispose();
    if (value == null) return;
    try {
      await widget.catalog.save(value, isNew: tag == null);
      await load();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nao foi possivel salvar a tag. Verifique o identificador e tente novamente.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = tags;
    if (failed)
      return TextButton(
        onPressed: load,
        child: const Text(
          'Nao foi possivel carregar as tags. Tentar novamente',
        ),
      );
    if (available == null) return const LinearProgressIndicator();
    final visible = available
        .where((t) => t.isActive || widget.selected.contains(t.slug))
        .toList();
    final known = available.map((t) => t.slug).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags do imovel'),
        Wrap(
          spacing: 8,
          children: [
            for (final tag in visible)
              FilterChip(
                label: Text(
                  tag.isActive ? tag.label : '${tag.label} (inativa)',
                ),
                selected: widget.selected.contains(tag.slug),
                onSelected: (selected) {
                  final next = {...widget.selected};
                  selected ? next.add(tag.slug) : next.remove(tag.slug);
                  widget.onChanged(next);
                },
              ),
            for (final slug in widget.selected.difference(known))
              InputChip(
                label: Text('$slug (inativa)'),
                onDeleted: () =>
                    widget.onChanged({...widget.selected}..remove(slug)),
              ),
          ],
        ),
        if (widget.isAdmin)
          ExpansionTile(
            title: const Text('Gerenciar tags'),
            children: [
              for (final tag in available)
                ListTile(
                  title: Text(tag.label),
                  subtitle: Text(
                    tag.isActive ? tag.slug : '${tag.slug} - inativa',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => edit(tag),
                ),
              TextButton.icon(
                onPressed: () => edit(),
                icon: const Icon(Icons.add),
                label: const Text('Nova tag'),
              ),
            ],
          ),
      ],
    );
  }
}
