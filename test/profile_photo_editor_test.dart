import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/helpers/property_image_picker_types.dart';
import 'package:imobiliaria/app/presentation/main/pages/widgets/profile/profile_photo_editor.dart';

const photo = PickedPropertyImage(
  fileName: 'photo.png',
  mimeType: 'image/png',
  contentBase64:
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);

void main() {
  testWidgets(
    'preview appears before upload completes and survives confirmed URL',
    (tester) async {
      final upload = Completer<bool>();
      var url = '';
      var calls = 0;
      late StateSetter refresh;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                refresh = setState;
                return ProfilePhotoEditor(
                  imageUrl: url,
                  pickImage: () async => photo,
                  onUpload: (_) async {
                    calls++;
                    final saved = await upload.future;
                    refresh(
                      () => url = 'https://unavailable.invalid/avatar?v=2',
                    );
                    return saved;
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Adicionar foto'));
      await tester.pump();
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
      final provider =
          tester.widget<Image>(find.byType(Image)).image as MemoryImage;
      expect(provider.bytes, base64Decode(photo.contentBase64));
      expect(find.text('Enviando foto...'), findsOneWidget);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      expect(calls, 1);
      upload.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Alterar foto'), findsOneWidget);
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
      refresh(() {});
      await tester.pump();
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
      // An unrelated external update clears the old local preview.
      refresh(() => url = '');
      await tester.pump();
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed replacement restores the last confirmed local photo', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePhotoEditor(
            imageUrl: '',
            pickImage: () async => photo,
            onUpload: (_) async => ++calls == 1,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Adicionar foto'));
    await tester.pumpAndSettle();
    final first = tester.widget<Image>(find.byType(Image)).image;
    await tester.tap(find.text('Alterar foto'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(tester.widget<Image>(find.byType(Image)).image, first);
    expect(
      find.text('Não foi possível salvar a foto. Tente novamente.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel does not upload and exceptions release the editor', (
    tester,
  ) async {
    var calls = 0;
    var fail = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePhotoEditor(
            imageUrl: '',
            pickImage: () async {
              if (fail) throw StateError('Cannot read file');
              return null;
            },
            onUpload: (_) async {
              calls++;
              return true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Adicionar foto'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byType(Image), findsNothing);
    fail = true;
    await tester.tap(find.text('Adicionar foto'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível atualizar a foto. Tente novamente.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('upload completion after disposal is safe', (tester) async {
    final upload = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePhotoEditor(
            imageUrl: '',
            pickImage: () async => photo,
            onUpload: (_) => upload.future,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Adicionar foto'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    upload.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
