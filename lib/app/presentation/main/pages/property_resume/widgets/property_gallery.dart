import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'property_photo.dart';

class PropertyGallery extends StatefulWidget {
  const PropertyGallery({
    super.key,
    required this.images,
    required this.desktop,
  });
  final List<String> images;
  final bool desktop;
  @override
  State<PropertyGallery> createState() => _PropertyGalleryState();
}

class _PropertyGalleryState extends State<PropertyGallery> {
  int _index = 0;
  void _open(int index) => showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (_) =>
        PropertyPhotoViewer(images: widget.images, initialIndex: index),
  );
  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) {
      return const AspectRatio(
        aspectRatio: 4 / 3,
        child: PropertyPhoto(url: ''),
      );
    }
    if (!widget.desktop || images.length == 1) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (_, index) => Material(
                child: InkWell(
                  onTap: () => _open(index),
                  child: PropertyPhoto(url: images[index]),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: FilledButton.icon(
                onPressed: () => _open(_index),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('${_index + 1}/${images.length} · Ver fotos'),
              ),
            ),
          ],
        ),
      );
    }
    final count = images.length.clamp(0, 5);
    return AspectRatio(
      aspectRatio: 1.4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PropertyGalleryTile(
              url: images.first,
              onPressed: () => _open(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) => GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: count - 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count <= 3 ? 1 : 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: count == 2
                      ? constraints.maxHeight
                      : (constraints.maxHeight - 8) / 2,
                ),
                itemBuilder: (_, index) => PropertyGalleryTile(
                  url: images[index + 1],
                  onPressed: () => _open(index + 1),
                  overlay: index == count - 2
                      ? '${images.length > count ? '+${images.length - count}\n' : ''}Mostrar todas as fotos'
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyGalleryTile extends StatelessWidget {
  const PropertyGalleryTile({
    super.key,
    required this.url,
    required this.onPressed,
    this.overlay,
  });
  final String url;
  final String? overlay;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    child: InkWell(
      onTap: onPressed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PropertyPhoto(url: url),
          if (overlay != null)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(overlay!, textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class PropertyPhotoViewer extends StatefulWidget {
  const PropertyPhotoViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });
  final List<String> images;
  final int initialIndex;
  @override
  State<PropertyPhotoViewer> createState() => _PropertyPhotoViewerState();
}

class _PropertyPhotoViewerState extends State<PropertyPhotoViewer> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  void _move(int delta) {
    final next = (_index + delta).clamp(0, widget.images.length - 1);
    _pages.animateToPage(
      next,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _move(1),
      },
      child: Focus(
        autofocus: true,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('${_index + 1} / ${widget.images.length}'),
                  ),
                  IconButton(
                    tooltip: 'Fechar fotos',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: widget.images.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (_, index) => InteractiveViewer(
                    child: PropertyPhoto(
                      url: widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Foto anterior',
                    onPressed: _index > 0 ? () => _move(-1) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: 'Próxima foto',
                    onPressed: _index < widget.images.length - 1
                        ? () => _move(1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
