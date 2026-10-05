import 'package:imobiliaria/app/presentation/main/pages/widgets/profile/profile_photo_editor.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/helpers/property_image_picker_types.dart';
import 'dart:async';
import 'package:imobiliaria/app/data/users/repositories/user_profile_repository.dart';
import 'package:imobiliaria/app/data/users/failures/user_profile_failure.dart';
import 'package:imobiliaria/app/domain/users/usecases/update_user_password_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/update_user_profile_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_user_profile_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/upload_user_avatar_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_broker_properties_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_page.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_broker_edit_dialog.dart';
import 'package:legend_core/legend_core.dart';

const profile = UserProfileEntity(
  id: 'one',
  name: 'Maria Corretora',
  email: 'maria@example.com',
  phone: '63999999999',
  whatsapp: '',
  creci: '',
  about: 'Apresentacao',
  avatarUrl: '',
  brokerCode: 'B1',
  role: 'broker',
  isActive: true,
  createdAt: '2026-01-01',
);
const broker = AdminBrokerEntity(
  id: 'one',
  name: 'Maria Corretora',
  email: 'maria@example.com',
  phone: '63999999999',
  totalProperties: 1,
  brokerCode: 'B1',
);

class ProfileController extends Fake implements BrokerController {
  int avatarPicks = 0;

  @override
  Future<bool> uploadAvatar(PickedPropertyImage image) async {
    avatarPicks++;
    return false;
  }

  @override
  final store = BrokerStore()..setProfile(profile);
  @override
  String? passwordError;
  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    passwordError = 'Senha atual invalida.';
    return false;
  }

  @override
  Future<bool> saveProfile() async {
    store.setProfile(profile.copyWith(name: store.nameController.text));
    store.setProfileSaving(false);
    return true;
  }
}

class AdminController extends Fake implements AdminBrokersController {
  UserProfileUpdateEntity? saved;
  @override
  String? editError;
  @override
  Future<AdminBrokerEntity?> uploadAvatar(
    String id,
    PickedPropertyImage image,
  ) async => broker;
  @override
  Future<AdminBrokerEntity?> saveBroker(
    String id,
    UserProfileUpdateEntity profile,
  ) async {
    saved = profile;
    return broker;
  }
}

class _GetProperties extends Fake implements GetBrokerPropertiesUseCase {}

class _GetMedia extends Fake implements GetPropertyMediaFileUseCase {}

class _GetProfile extends Fake implements GetUserProfileUseCase {}

class _UpdateProfile extends Fake implements UpdateUserProfileUseCase {}

class _UploadAvatar extends Fake implements UploadUserAvatarUseCase {}

class _Navigator extends Fake implements AppNavigator {}

class _PasswordRepository extends Fake implements UserProfileRepository {
  int calls = 0;
  final response = Completer<DualResponse<Failure, UserProfileEntity>>();
  @override
  Future<DualResponse<Failure, UserProfileEntity>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    calls++;
    return response.future;
  }
}

void main() {
  test(
    'password controller validates before request and prevents duplicate sends',
    () async {
      final repository = _PasswordRepository();
      final controller = BrokerController(
        store: BrokerStore()..setProfile(profile),
        getBrokerProperties: _GetProperties(),
        getPropertyMediaFile: _GetMedia(),
        getUserProfile: _GetProfile(),
        updateUserProfile: _UpdateProfile(),
        updateUserPassword: UpdateUserPasswordUseCase(repository: repository),
        uploadUserAvatar: _UploadAvatar(),
        navigator: _Navigator(),
      );
      for (final input in [
        ('', 'Password123', 'Password123'),
        ('old', 'short', 'short'),
        ('old', 'Password123', 'different'),
      ]) {
        expect(
          await controller.changePassword(
            currentPassword: input.$1,
            newPassword: input.$2,
            newPasswordConfirmation: input.$3,
          ),
          isFalse,
        );
        expect(controller.passwordError, isNotNull);
      }
      expect(repository.calls, 0);
      final pending = controller.changePassword(
        currentPassword: 'old',
        newPassword: 'Password123',
        newPasswordConfirmation: 'Password123',
      );
      expect(
        await controller.changePassword(
          currentPassword: 'old',
          newPassword: 'Password123',
          newPasswordConfirmation: 'Password123',
        ),
        isFalse,
      );
      expect(repository.calls, 1);
      repository.response.complete(
        ErrorResponse(UserProfileFailure('Senha atual invalida.')),
      );
      expect(await pending, isFalse);
      expect(controller.passwordError, 'Senha atual invalida.');
      expect(controller.store.nameController.text, profile.name);
      controller.store.dispose();
    },
  );

  test('avatar updates preserve dirty fields; cancel keeps new avatar', () {
    final store = BrokerStore()..setProfile(profile);
    store.nameController.text = 'Unsaved name';
    store.phoneController.text = 'New phone';
    store.setAvatar('https://example.com/current?v=2');
    expect(store.nameController.text, 'Unsaved name');
    expect(store.phoneController.text, 'New phone');
    expect(store.hasProfileChanges, isTrue);
    store.resetProfileForm();
    expect(store.nameController.text, profile.name);
    expect(store.profile!.avatarUrl, 'https://example.com/current?v=2');
    expect(store.hasProfileChanges, isFalse);
    store.dispose();
  });

  for (final size in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets('profile renders and saves at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = ProfileController();
      controller.store.nameController.addListener(
        controller.store.markFormChanged,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ValueListenableBuilder<AppStateEnum>(
                valueListenable: controller.store.state,
                builder: (_, state, child) =>
                    BrokerProfileTab(controller: controller),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      final addPhoto = find.widgetWithText(TextButton, 'Adicionar foto');
      await tester.ensureVisible(addPhoto);
      await tester
          .widget<ProfilePhotoEditor>(find.byType(ProfilePhotoEditor))
          .onUpload(
            const PickedPropertyImage(
              fileName: 'photo.png',
              mimeType: 'image/png',
              contentBase64: '',
            ),
          );
      await tester.pump();
      expect(controller.avatarPicks, 1);
      controller.store.setAvatar('https://example.com/photo.png');
      controller.store.setAvatarUploading(true);
      await tester.pump();
      final sending = find.widgetWithText(TextButton, 'Enviando foto...');
      expect(tester.widget<TextButton>(sending).onPressed, isNull);
      controller.store.setAvatarUploading(false);
      await tester.pump();
      expect(find.widgetWithText(TextButton, 'Alterar foto'), findsOneWidget);
      final save = find.ancestor(
        of: find.text('SALVAR ALTERACOES'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.enterText(find.byType(TextFormField).first, 'Nome alterado');
      await tester.pump();
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(controller.store.hasProfileChanges, isFalse);
      expect(controller.store.profile!.name, 'Nome alterado');
      expect(tester.takeException(), isNull);
    });

    testWidgets('admin edits fields and avatar without losing draft at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AdminController();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AdminBrokerEditDialog(
                    controller: controller,
                    broker: broker,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Texto pendente',
      );
      await tester
          .widget<ProfilePhotoEditor>(find.byType(ProfilePhotoEditor))
          .onUpload(
            const PickedPropertyImage(
              fileName: 'photo.png',
              mimeType: 'image/png',
              contentBase64: '',
            ),
          );
      await tester.pumpAndSettle();
      expect(find.text('Texto pendente'), findsOneWidget);
      final email = tester.widget<TextFormField>(
        find.byType(TextFormField).at(5),
      );
      expect(email.initialValue, 'maria@example.com');
      await tester.tap(find.text('Salvar alteracoes'));
      await tester.pumpAndSettle();
      expect(controller.saved!.name, 'Texto pendente');
      expect(find.byType(AdminBrokerEditDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('password error stays in dialog and fields remain intact', (
    tester,
  ) async {
    final controller = ProfileController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BrokerPasswordDialog(controller: controller)),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'incorrect');
    await tester.enterText(find.byType(TextField).at(1), 'NewPassword123');
    await tester.enterText(find.byType(TextField).at(2), 'NewPassword123');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Senha atual invalida.'), findsOneWidget);
    expect(find.text('NewPassword123'), findsNWidgets(2));
    expect(find.byType(BrokerPasswordDialog), findsOneWidget);
  });
}
