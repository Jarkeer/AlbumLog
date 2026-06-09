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
        "🚨 ERROR DE CARGA": [
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

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'javieralonso1702@gmail.com', 
      queryParameters: {
        'subject': 'Evaluación QA - Proyecto AlbumLog', 
        'body': emailBody.toString(), 
      },
    );

    try {
      // Forzamos la apertura directa como aplicación externa
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error crítico: No se pudo abrir el cliente de correo. $e');
    }
  }
}