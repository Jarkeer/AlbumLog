import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/qa_viewmodel.dart';

class QaScreen extends StatelessWidget {
  const QaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qaVM = Provider.of<QaViewModel>(context);

    if (qaVM.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Beta Testing QA'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Por favor, califica los siguientes aspectos de la aplicación (0 a 5 estrellas):',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          

          ...qaVM.categorisedQuestions.entries.map((categoryEntry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryEntry.key.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...categoryEntry.value.asMap().entries.map((questionEntry) {
                  int index = questionEntry.key;
                  var question = questionEntry.value;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.star_border, color: Colors.grey),
                              Expanded(
                                child: Slider(
                                  value: question.value,
                                  min: 0,
                                  max: 5,
                                  divisions: 5,
                                  activeColor: Colors.deepPurple,
                                  inactiveColor: Colors.grey[700],
                                  label: '${question.value.toInt()} estrellas',
                                  onChanged: (newValue) {
                                    qaVM.updateAnswer(categoryEntry.key, index, newValue);
                                  },
                                ),
                              ),
                              const Icon(Icons.star, color: Colors.amber),
                            ],
                          ),
                          Text("Min: ${question.min}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          Text("Max: ${question.max}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(color: Colors.deepPurple),
              ],
            );
          }),
          
          
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('ENVIAR RESULTADOS', style: TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: () {
              qaVM.submitFeedback();
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}