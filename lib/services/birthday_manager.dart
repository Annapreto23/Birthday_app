import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BirthdayManager {
  static const _key = 'birthdays';

  static Future<void> saveBirthdays(List<Map<String, dynamic>> birthdays) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(birthdays);
    await prefs.setString(_key, encodedData);
  }

  static Future<List<Map<String, dynamic>>> loadBirthdays() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_key);
    if (encodedData == null) return [];
    final decodedData = jsonDecode(encodedData) as List;
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }
}

