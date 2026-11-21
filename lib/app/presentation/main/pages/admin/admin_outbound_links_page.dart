import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/widgets/admin/admin_layout.dart';
import 'package:intl/intl.dart';
import 'package:legend_core/legend_core.dart';

class AdminOutboundLinksPage extends StatefulWidget {
  const AdminOutboundLinksPage({super.key});

  @override
  State<AdminOutboundLinksPage> createState() => _AdminOutboundLinksPageState();
}

class _AdminOutboundLinksPageState extends State<AdminOutboundLinksPage> {
  int _page = 1;
  late Future<Map<String, dynamic>> _result = _load();

  Future<Map<String, dynamic>> _load() async {
    final response = await Module.get<MainModule>().injector
        .get<RestClient>()
        .get<Map<String, dynamic>>(
          '/admin/outbound-links/clicks',
          queryParameters: <String, dynamic>{'page': _page, 'pageSize': 25},
        );
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('Nao foi possivel carregar os cliques.');
    }
    return response.data!;
  }

  void _changePage(int value) {
    setState(() {
      _page = value;
      _result = _load();
    });
  }

  @override
  Widget build(BuildContext context) => AdminLayout(
    title: 'Cliques e leads',
    currentRoute: MainRoutes.adminOutboundLinks,
    child: FutureBuilder<Map<String, dynamic>>(
      future: _result,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nao foi possivel carregar os cliques.'),
                TextButton(
                  onPressed: () => _changePage(_page),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data!;
        final items = (data['items'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        final total = data['total'] as int? ?? 0;
        return DSPageLayoutContainer(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$total cliques registrados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text('Pagina $_page'),
                    IconButton(
                      tooltip: 'Pagina anterior',
                      onPressed: _page > 1
                          ? () => _changePage(_page - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: 'Proxima pagina',
                      onPressed: _page * 25 < total
                          ? () => _changePage(_page + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Nenhum clique registrado.'))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: DSSpacing.sm),
                        itemBuilder: (context, index) =>
                            _ClickCard(item: items[index]),
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _ClickCard extends StatelessWidget {
  const _ClickCard({required this.item});
  final Map<String, dynamic> item;

  static const _sourceLabels = <String, String>{
    'header_instagram': 'Instagram do cabecalho',
    'header_youtube': 'YouTube do cabecalho',
    'home_video': 'Video da pagina inicial',
    'home_whatsapp': 'WhatsApp da pagina inicial',
    'home_property_whatsapp': 'WhatsApp do destaque',
    'property_instagram': 'Instagram do imovel',
    'property_whatsapp': 'WhatsApp do imovel',
  };

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(
      item['createdAt'] as String? ?? '',
    )?.toLocal();
    final user = item['userName'] as String?;
    final email = item['userEmail'] as String?;
    final property = item['propertyTitle'] as String?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sourceLabels[item['source']] ??
                        (item['source'] as String? ?? ''),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (item['leadId'] != null) const Chip(label: Text('Lead')),
              ],
            ),
            Text(
              date == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(date),
            ),
            SelectableText(item['targetUrl'] as String? ?? ''),
            Text(
              'Usuario: ${user == null ? 'Anonimo' : '$user (${email ?? item['userId']}) — ${item['userRole']}'}',
            ),
            if (property != null)
              Text('Imovel: $property (${item['propertyId']})'),
          ],
        ),
      ),
    );
  }
}
