import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class InterpelationDetails {
  final String title;
  final String sentDate;
  final String receiptDate;
  final List<String> from;
  final List<Reply> replies;

  InterpelationDetails({
    required this.title,
    required this.sentDate,
    required this.receiptDate,
    required this.from,
    required this.replies,
  });

  factory InterpelationDetails.fromJson(Map<String, dynamic> json) {
    return InterpelationDetails(
      title: json['title'] as String,
      sentDate: json['sentDate'] as String,
      receiptDate: json['receiptDate'] as String,
      from: List<String>.from(json['from'] ?? []),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Reply.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Reply {
  final String from;
  final String receiptDate;
  final List<Attachment> attachments;

  Reply({
    required this.from,
    required this.receiptDate,
    required this.attachments,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      from: json['from'] as String,
      receiptDate: json['receiptDate'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Attachment {
  final String url;
  final String name;

  Attachment({
    required this.url,
    required this.name,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['URL'] as String,
      name: json['name'] as String,
    );
  }
}

/// Struktura pomocnicza na detale posła (dodajemy photoUrl).
class MPDetails {
  final int id;
  final String accusativeName;
  final String profession;
  final String photoUrl;
  final String club;

  MPDetails({
    required this.id,
    required this.accusativeName,
    required this.profession,
    required this.photoUrl,
    required this.club,
  });
}

class InterpelationController {
  final String baseUrl = 'https://api.sejm.gov.pl/sejm';

  /// Zwracamy Mapę z głównymi danymi o interpelacji i listą MPDetails
  Future<Map<String, dynamic>> getInterpelationDetails(
    int term,
    int num,
  ) async {
    final url = Uri.parse('$baseUrl/term$term/interpellations/$num');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Pobranie tablicy wartości z pola "from"
      final List<String> fromList = List<String>.from(json['from'] ?? []);

      if (fromList.isNotEmpty) {
        print('Tablica wartości z pola "from": $fromList');
      } else {
        print('Pole "from" jest puste.');
      }

      // Pobranie szczegółów posłów w postaci listy MPDetails
      List<MPDetails> mpDetailsList = [];
      for (var id in fromList) {
        final mpDetails = await fetchMPDetails(term, int.parse(id));
        if (mpDetails != null) {
          mpDetailsList.add(mpDetails);
        }
      }

      // ### Dodane z Pliku 1 ###
      List<String?> fileUrls = [];
      List<String?> htmls = [];

      for (var reply in json['replies']) {
        // Obsługa załączników
        if (reply['attachments'] != null) {
          for (var attachment in reply['attachments']) {
            fileUrls.add(attachment['URL']);
          }
        } else {
          fileUrls.add(null);
        }

        // Obsługa linków HTML
        if (reply['links'] != null && reply['links'].length > 1) {
          htmls.add(reply['links'][1]['href']);
        } else {
          htmls.add(null);
        }
      }
      var textContent = '';
      try {
        if (htmls.isNotEmpty && htmls[0] != null) {
          final responseHtml = await http.get(Uri.parse(htmls[0]!));
          final document = parse(responseHtml.body);
          textContent = document.body!.text;
        }
      } catch (e) {
        print(e);
      }
      // ### Koniec Dodanych ###

      return {
        'title': json['title'],
        'sentDate': json['sentDate'],
        'response': json['replies'].isNotEmpty
            ? '${textContent}' // Możesz dostosować format odpowiedzi
            : 'Brak odpowiedzi',
        'attachments': fileUrls.where((url) => url != null).toList(),
        'mpDetails': mpDetailsList, // lista posłów
      };
    } else {
      throw Exception('Nie udało się pobrać szczegółów interpelacji.');
    }
  }

  /// Zwracamy MPDetails zamiast samego printa.
  Future<MPDetails?> fetchMPDetails(int term, int id) async {
    final url = Uri.parse('https://api.sejm.gov.pl/sejm/term$term/MP/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final mpJson =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final accusativeName =
          mpJson['accusativeName'] as String? ?? 'Brak danych';
      final profession = mpJson['profession'] as String? ?? 'Brak danych';
      final club = mpJson['club'] as String? ??
          'Brak danych'; // Dodane pobieranie pola 'club'
      // URL do zdjęcia posła
      final photoUrl = 'https://api.sejm.gov.pl/sejm/term$term/MP/$id/photo';

      // Wyświetlenie w konsoli
      print('Poseł ID $id: $accusativeName, zawód: $profession');

      return MPDetails(
        id: id,
        accusativeName: accusativeName,
        profession: profession,
        photoUrl: photoUrl,
        club: club,
      );
    } else {
      print('Nie udało się pobrać szczegółów dla posła o ID $id.');
      return null;
    }
  }
}
