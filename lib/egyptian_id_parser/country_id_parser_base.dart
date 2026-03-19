import 'package:baiomy/egyptian_id_parser/repo/repo.dart';
import 'impl/impl.dart';
import 'models/models.dart';

class BaiomyEgyptianIdParser {
  final IdParser idParser = EgyptID();
  final String id;

  BaiomyEgyptianIdParser(this.id);

  // Direct accessors for the ID information
  String get birthDate => idParser.extractBirthDate(id);
  String get governorate => idParser.extractGovernorate(id);
  String get gender => idParser.extractGender(id);
  Age get age => idParser.calculateAge(id);
}
