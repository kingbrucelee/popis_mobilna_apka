class Mp {
  final String club;
  final String districtName;
  final String educationLevel;
  final int numberOfVotes;
  final String? profession;
  final String voivodeship;
  final String? birthDate;
  final String firstName; // Dodane pole
  final String lastName; // Dodane pole

  Mp({
    required this.club,
    required this.districtName,
    required this.educationLevel,
    required this.numberOfVotes,
    this.profession,
    required this.voivodeship,
    this.birthDate,
    required this.firstName, // Dodane w konstruktorze
    required this.lastName, // Dodane w konstruktorze
  });

  @override
  String toString() {
    // Możemy zwrócić np. samo imię i nazwisko
    return "$firstName $lastName";
  }

  factory Mp.fromJson(Map<String, dynamic> json) {
    return Mp(
      club: json['club'] ?? 'Brak danych',
      districtName: json['districtName'] ?? 'Brak danych',
      educationLevel: json['educationLevel'] ?? 'Brak danych',
      numberOfVotes: json['numberOfVotes'] ?? 0,
      profession: json['profession'],
      voivodeship: json['voivodeship'] ?? 'Brak danych',
      birthDate: json['birthDate'],
      firstName: json['firstName'] ?? 'Nieznane imię', // Dopasuj do API
      lastName: json['lastName'] ?? 'Nieznane nazwisko', // Dopasuj do API
    );
  }
}
