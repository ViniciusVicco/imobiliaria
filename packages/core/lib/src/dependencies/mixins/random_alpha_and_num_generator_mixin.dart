import 'dart:math';

mixin RandomStringAlphaNum {
  String generateRandomString(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }
}

