import 'package:meteomada/repositories/prevision_repository.dart';
import 'package:meteomada/repositories/condition_marine_repository.dart';

class CacheService {
  final PrevisionRepository _previsionRepository = PrevisionRepository();
  final ConditionMarineRepository _conditionMarineRepository =
      ConditionMarineRepository();

  Future<bool> previsionValide(String villeId) async {
    return _previsionRepository.cacheValide(villeId);
  }

  Future<void> nettoyerPrevisionsExpirees(String villeId) async {
    await _previsionRepository.supprimerVieillesPrevisions(villeId);
  }

  Future<bool> conditionMarineValide(String villeId) async {
    final condition =
        await _conditionMarineRepository.getConditionMarine(villeId);
    return condition != null;
  }
}
