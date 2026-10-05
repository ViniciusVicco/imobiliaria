import 'package:imobiliaria/app/data/media/repositories/media_repository.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';
import 'package:legend_core/legend_core.dart';

class SetPropertyCoverUseCase {
  SetPropertyCoverUseCase({required this.repository});

  final MediaRepository repository;

  Future<DualResponse<Failure, PropertyMediaEntity>> call({
    required String mediaId,
  }) {
    return repository.setCover(mediaId: mediaId);
  }
}
