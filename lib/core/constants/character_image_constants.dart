/// Maps character IDs to their image asset paths.
abstract final class CharacterImageConstants {
  static const Map<String, String> characterImagePaths = <String, String>{
    'young_investor': 'assets/images/young.png',
    'middle_aged': 'assets/images/middle_age.png',
    'pre_retirement': 'assets/images/grandma.png',
    'entrepreneur': 'assets/images/entrepreneur.png',
    'inheritor': 'assets/images/inheritor.png',
  };

  static String? getImagePathForCharacter(String characterId) =>
      characterImagePaths[characterId];
}
