import 'dart:math';

class QuoteConstants {
  static const List<String> fitnessQuotes = [
    "The only bad workout is the one that didn't happen.",
    "Action is the foundational key to all success.",
    "Don't stop when you're tired. Stop when you're done.",
    "Your health is an investment, not an expense.",
    "Fitness is not about being better than someone else. It's about being better than you were yesterday.",
    "Motivation is what gets you started. Habit is what keeps you going.",
    "A one-hour workout is only 4% of your day. No excuses.",
    "Sweat is just fat crying.",
    "The hard part isn't getting your body in shape. The hard part is getting your mind in shape.",
    "Small steps lead to big results. Keep going!"
  ];

  static String getRandomQuote() {
    final random = Random();
    return fitnessQuotes[random.nextInt(fitnessQuotes.length)];
  }
}
