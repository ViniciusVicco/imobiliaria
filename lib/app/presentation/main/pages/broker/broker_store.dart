import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:legend_core/legend_core.dart';

class BrokerStore extends Store {
  final AppState state = AppState();

  List<BrokerPropertyEntity> properties = const <BrokerPropertyEntity>[];
  Map<String, int> statusCounts = const <String, int>{};
  String selectedPropertyStatus = '';
  UserProfileEntity? profile;
  UserProfileEntity? originalProfile;
  String? errorMessage;
  bool isSavingProfile = false;
  bool isUploadingAvatar = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final creciController = TextEditingController();
  final aboutController = TextEditingController();

  bool get hasProfileChanges {
    final original = originalProfile;
    if (original == null) return false;
    return nameController.text.trim() != original.name ||
        phoneController.text.trim() != original.phone ||
        whatsappController.text.trim() != original.whatsapp ||
        creciController.text.trim() != original.creci ||
        aboutController.text.trim() != original.about;
  }

  void setLoading() {
    errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setLoaded({
    required List<BrokerPropertyEntity> properties,
    required Map<String, int> statusCounts,
    required UserProfileEntity profile,
  }) {
    this.properties = properties;
    this.statusCounts = statusCounts;
    setProfile(profile);
    errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setProperties({
    required List<BrokerPropertyEntity> properties,
    required Map<String, int> statusCounts,
    required String status,
  }) {
    this.properties = properties;
    this.statusCounts = statusCounts;
    selectedPropertyStatus = status;
    errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setProfile(UserProfileEntity profile) {
    this.profile = profile;
    originalProfile = profile;
    nameController.text = profile.name;
    phoneController.text = profile.phone;
    whatsappController.text = profile.whatsapp;
    creciController.text = profile.creci;
    aboutController.text = profile.about;
  }

  void setProfileSaving(bool value) {
    isSavingProfile = value;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setAvatarUploading(bool value) {
    isUploadingAvatar = value;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void markFormChanged() {
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void resetProfileForm() {
    final original = originalProfile;
    if (original == null) return;
    nameController.text = original.name;
    phoneController.text = original.phone;
    whatsappController.text = original.whatsapp;
    creciController.text = original.creci;
    aboutController.text = original.about;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    creciController.dispose();
    aboutController.dispose();
    super.dispose();
  }
}
