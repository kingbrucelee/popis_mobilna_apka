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
      from: List<String>.from(json['from'] ?? []), // Konwersja na List<String>
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Reply.fromJson(e))
          .toList() ??
          [], // Konwersja na List<Reply>
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



class InterpelationController {
  final String baseUrl = 'https://api.sejm.gov.pl/sejm';

  Future<Map<String, dynamic>> getInterpelationDetails(int term, int num) async {
    final url = Uri.parse('$baseUrl/term$term/interpellations/$num');
    final response = await http.get(url);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      print(json);

      List<String?> fileUrls = [];
      List<String?> htmls = [];

      for (var reply in json['replies']) {
        // Handle attachments
        if (reply['attachments'] != null) {
          for (var attachment in reply['attachments']) {
            fileUrls.add(attachment['URL']);
          }
        } else {
          fileUrls.add(null);
        }

        // Handle HTML links
        if (reply['links'] != null && reply['links'].length > 1) {
          htmls.add(reply['links'][1]['href']);
        } else {
          htmls.add(null);
        }
      }
      var textContent = '';
      try{
        final response = await http.get(Uri.parse(htmls[0]!));
        final document = parse(response.body);
        textContent = document.body!.text;
      } catch (e) {
        print(e);
      }

      //return [fileUrls, htmls];

      return {
        'title': json['title'],
        'sentDate': json['sentDate'],
        //authors': json['from'].map<String>((author) => author['name']).toList(),
        'response': json['replies'].isNotEmpty
            ? '${textContent}\nOdpowiedź w załączniku:\n${fileUrls.where((url) => url != null).join(', ')}'
            : 'Brak odpowiedzi',
      };
    } else {
      throw Exception('Nie udało się pobrać szczegółów interpelacji.');
    }
  }
}
