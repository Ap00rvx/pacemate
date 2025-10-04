class WishMessage {
  static String getMessage() {
    final time = DateTime.now().hour;
    if (time < 12) {
      return 'Good morning🔥';
    } else if (time < 17) {
      return 'Good afternoon 🌞';
    } else {
      return 'Good evening 🌚';
    }
  }
}
