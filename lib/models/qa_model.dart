class QuestionModel{
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
      title: json['titulo'],
      value: (json['valor'] as num).toDouble(),
      min: json['min'],
      max: json['max'],
    );
  }
}