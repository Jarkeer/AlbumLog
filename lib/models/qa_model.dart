class QuestionModel {
  String title;
  double value;
  String min;
  String max;

  QuestionModel({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      title: json['titulo']?.toString() ?? "Pregunta sin título (Revisa el JSON)",
      value: ((json['valor'] ?? 0) as num).toDouble(),
      min: json['min']?.toString() ?? "0",
      max: json['max']?.toString() ?? "5",
    );
  }
}