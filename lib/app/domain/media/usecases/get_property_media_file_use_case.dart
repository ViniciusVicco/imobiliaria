import 'dart:typed_data';

import 'package:imobiliaria/app/data/media/repositories/media_repository.dart';
import 'package:legend_core/legend_core.dart';

class GetPropertyMediaFileUseCase {
  GetPropertyMediaFileUseCase({required this.repository});

  final MediaRepository repository;

  Future<DualResponse<Failure, Uint8List>> call({required String mediaId}) {
    return repository.getFile(mediaId: mediaId);
  }
}
