// password_generator.dart

import 'dart:math';

String generateRandomPassword() {
  // Lista de caracteres especiais
  List<String> specialChars = [
    '!',
    '@',
    '#',
    '\$',
    '%',
    '&',
    '*',
    '-',
    '_',
    '=',
    '+'
  ];

  // Lista de letras maiúsculas
  List<String> uppercaseChars = List.generate(
      26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  // Lista de letras minúsculas
  List<String> lowercaseChars = List.generate(
      26, (index) => String.fromCharCode('a'.codeUnitAt(0) + index));

  // Lista de números
  List<String> numbers = List.generate(10, (index) => index.toString());

  // Gerar uma senha aleatória com 12 caracteres
  String password = '';
  Random random = Random();
  for (int i = 0; i < 12; i++) {
    int choice = random.nextInt(4);
    switch (choice) {
      case 0:
        password += specialChars[random.nextInt(specialChars.length)];
        break;
      case 1:
        password += uppercaseChars[random.nextInt(uppercaseChars.length)];
        break;
      case 2:
        password += lowercaseChars[random.nextInt(lowercaseChars.length)];
        break;
      case 3:
        password += numbers[random.nextInt(numbers.length)];
        break;
    }
  }
  return password;
}
