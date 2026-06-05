import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import '../models/qa_model.dart';


class QaViewModel extends ChangeNotifier {
  Map<String, List<QuestionModel>> categorisedQuestions = {};
  bool isLoading = true;

  QaViewModel() {
    loadQuestions();
  }

  // Recupero las preguntas desde el JSON
  Future<void> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/qa_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      jsonData.forEach((category, questionsList) {
        categorisedQuestions[category] = (questionsList as List)
            .map((q) => QuestionModel.fromJson(q))
            .toList();
      });

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error cargando el JSON: $e");
    }
  }

  void updateAnswer(String category, int index, double newValue) {
    categorisedQuestions[category]![index].value = newValue;
    notifyListeners();
  }

  Future<void> submitFeedback() async {
    StringBuffer emailBody = StringBuffer();
    emailBody.writeln("Resultados Beta Testing - AlbumLog\n");

    categorisedQuestions.forEach((category, questions) {
      emailBody.writeln("--- Categoria: ${category.toUpperCase()} ---");
      for (var q in questions) {
        emailBody.writeln(q.title);
        emailBody.writeln("Calificación: ${q.value.toInt()} estrellas\n");
      }
    });

   
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'profesor@utalca.cl', 
      queryParameters: {
        'subject': 'Evaluación QA - Proyecto AlbumLog',
        'body': emailBody.toString(),
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      print('No se pudo abrir el cliente de correo');
    }
  }
}