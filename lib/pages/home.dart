import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; 
import '../services/birthday_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: BirthdayManager.loadBirthdays(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading birthdays'));
        }

        final birthdays = snapshot.data ?? [];
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime? nextBirthdayDate;
        Map<String, dynamic>? nextBirthday;

        for (var birthday in birthdays) {
          DateTime date;
          try {
            date = DateTime.parse(birthday["date"]);
          } catch (e) {
            print('Date parsing error: ${birthday["date"]}');
            continue;
          }

          DateTime birthdayThisYear = DateTime(now.year, date.month, date.day);

          if (birthdayThisYear.isBefore(today)) {
            birthdayThisYear = DateTime(now.year + 1, date.month, date.day);
          }

          if (nextBirthdayDate == null || birthdayThisYear.isBefore(nextBirthdayDate)) {
            nextBirthdayDate = birthdayThisYear;
            nextBirthday = birthday;
          }
        }

        String message = "";
        String birthdayboy = "Unknown";
        String title = "BIRTHDAYS APP"; // So proud of my birthday app, hope you like my code haha, Dart is insane compared to Python
        if (nextBirthday != null) {
          birthdayboy = nextBirthday["name"];
          String formattedDate = DateFormat('MMMM d', 'en_US').format(nextBirthdayDate!);
          message = "The next birthday is ${nextBirthday["name"]}'s on $formattedDate.";
        } else {
          message = "There are no upcoming birthdays.";
        }


        String imagePath = "images/$birthdayboy.png"; // image of the birthday boy!! happy birthday dude :))!

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;

              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: height * 0.20),
                      Container(
                        width: width * 1, 
                        height: 110,
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Color(0xFFFFC02E),
                            fontSize: width * 0.06, 
                            fontFamily: "gluten",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: height * 0.03), 
                      FutureBuilder<File?>(
                        future: _loadImage(imagePath),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (imageSnapshot.hasError || !imageSnapshot.hasData) {
                            return Image.asset(
                              "assets/images/default.png", // Default image if no birthday boy image :(
                              width: width * 0.5, 
                            );
                          }

                          return Image.file(
                            imageSnapshot.data!,
                            width: width * 0.5, 
                          );
                        },
                      ),
                      SizedBox(height: height * 0.03),
                      Container(
                        width: width * 0.9, 
                        padding: EdgeInsets.all(width * 0.04), 
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC02E).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: width * 0.05, 
                            fontFamily: "gluten",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: height * 0.03), 
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Load an image file from the local directory
  Future<File?> _loadImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$imagePath');
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }
}
