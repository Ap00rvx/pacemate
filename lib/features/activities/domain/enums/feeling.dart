enum Feeling {
  excellent,
  good,
  okay,
  tired,
  exhausted,
  injured,
  motivated,
  relaxed,
}

extension FeelingX on Feeling {
  String get label => switch (this) {
    Feeling.excellent => 'Excellent',
    Feeling.good => 'Good',
    Feeling.okay => 'Okay',
    Feeling.tired => 'Tired',
    Feeling.exhausted => 'Exhausted',
    Feeling.injured => 'Injured',
    Feeling.motivated => 'Motivated',
    Feeling.relaxed => 'Relaxed',
  };

  String get api => name; // lowercase
}
