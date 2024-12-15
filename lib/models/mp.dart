// model/mp.dart

class Mp {
  final String club;
  final String districtName;
  final String educationLevel;
  final int numberOfVotes;
  final String? profession;
  final String voivodeship;

  Mp({
    required this.club,
    required this.districtName,
    required this.educationLevel,
    required this.numberOfVotes,
    this.profession,
    required this.voivodeship,
  });

  @override
  String toString() {
    String base =
        "Był w klubie $club, został wybrany z okręgu $districtName znajdującym się w woj. $voivodeship, miał wykształcenie $educationLevel";

    if (numberOfVotes != 0) {
      base += ", otrzymał $numberOfVotes głosów";
    }

    if (profession == null) {
      base += " Podczas tej kadencji poseł nie pełnił żadnej profesji.";
    } else {
      base += " Podczas tej kadencji poseł miał profesję $profession.";
    }

    return base;
  }

  // Factory constructor to create Mp from JSON
  factory Mp.fromJson(Map<String, dynamic> json) {
    return Mp(
      club: json['club'] ?? 'Brak danych',
      districtName: json['districtName'] ?? 'Brak danych',
      educationLevel: json['educationLevel'] ?? 'Brak danych',
      numberOfVotes: json['numberOfVotes'] ?? 0,
      profession: json['profession'],
      voivodeship: json['voivodeship'] ?? 'Brak danych',
    );
  }
}
