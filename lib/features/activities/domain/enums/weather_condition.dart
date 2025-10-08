enum WeatherCondition { sunny, cloudy, rainy, windy, storm, snow }

extension WeatherConditionX on WeatherCondition {
  String get label => switch (this) {
    WeatherCondition.sunny => 'Sunny',
    WeatherCondition.cloudy => 'Cloudy',
    WeatherCondition.rainy => 'Rainy',
    WeatherCondition.windy => 'Windy',
    WeatherCondition.storm => 'Storm',
    WeatherCondition.snow => 'Snow',
  };
  String get api => name; // lowercase
}
