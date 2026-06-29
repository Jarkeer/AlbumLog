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

  Future<void> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/preguntas.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      jsonData.forEach((category, questionsList) {
        categorisedQuestions[category] = (questionsList as List)
            .map((q) => QuestionModel.fromJson(q))
            .toList();
      });

    } catch (e) {
      categorisedQuestions = {
        "ERROR DE CARGA": [
          QuestionModel(
            title: "Fallo técnico: $e",
            value: 0,
            min: "Error en ruta o sintaxis",
            max: "Avisa para corregir",
          )
        ]
      };
    } finally {
      isLoading = false;
      notifyListeners();
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

   
    final String encodedSubject = Uri.encodeComponent('Evaluación QA - Proyecto AlbumLog');
    final String encodedBody = Uri.encodeComponent(emailBody.toString());

    
    final Uri emailLaunchUri = Uri.parse(
      'mailto:javieralonso1702@gmail.com?subject=$encodedSubject&body=$encodedBody'
    );

    try {
      bool opened = await launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception("No se pudo abrir la app de correo");
    }
    } catch (e) {
      debugPrint('Error crítico: No se pudo abrir el cliente de correo. $e');
    }
  }
}