enum Feeling { great, good, neutral, tired, exhausted }

extension FeelingX on Feeling {
  String get label => switch (this) {
    Feeling.great => 'Great',
    Feeling.good => 'Good',
    Feeling.neutral => 'Neutral',
    Feeling.tired => 'Tired',
    Feeling.exhausted => 'Exhausted',
  };

  String get api => name; // lowercase
}
