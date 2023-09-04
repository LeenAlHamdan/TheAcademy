class Question {
  String id;

  String text;
  List<Choice> choices;

  Question({
    required this.id,
    required this.text,
    required this.choices,
  });
}

class Choice {
  String id;
  String text;

  bool? isTrueAnswer;

  Choice({
    required this.id,
    required this.text,
    required this.isTrueAnswer,
  });
}
