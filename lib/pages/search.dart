import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //intl package
import 'package:path_provider/path_provider.dart'; // For directory access
import '../services/birthday_manager.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? selectedName; // selected name
  DateTime? selectedBirthday; // selected birthday
  File? _selectedImage; // selected image file

  List<Map<String, dynamic>> _birthdays = [];

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    List<Map<String, dynamic>> birthdays = await BirthdayManager.loadBirthdays();
    setState(() {
      _birthdays = birthdays;
    });
  }

  // get names
  List<String> getNames() {
    return _birthdays.map((birthday) => birthday["name"].toString()).toList();
  }

  // update birthday and load the corresponding image
  void updateBirthday(String name) async {
    for (var birthday in _birthdays) {
      if (birthday["name"] == name) {
        setState(() {
          selectedBirthday = DateTime.parse(birthday["date"]);
        });
        await _loadImage(birthday["image"]);
        return;
      }
    }

    // If the selected name has no birthday date
    setState(() {
      selectedBirthday = null;
      _selectedImage = null;
    });
  }

  Future<void> _loadImage(String? imagePath) async {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        setState(() {
          _selectedImage = file;
        });
      } else {
        setState(() {
          _selectedImage = null; // Image not found
        });
      }
    } else {
      setState(() {
        _selectedImage = null; // No image path provided
      });
    }
  }

  // Fformat the selected birthday date
  String getFormattedDate(DateTime? date) {
    if (date == null) return "Unknown date";
    return DateFormat('MMMM d', 'en_US').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Find a birthday',
          style: TextStyle(
            fontFamily: "gluten",
            color: Color(0xFFFFC02E),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          // Formatted date for the selected birthday
          String formattedSelectedDate = getFormattedDate(selectedBirthday);

          return SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  // Background
                  Stack(
                    children: [
                      Transform(
                        transform: Matrix4.translationValues(200, -0, 0)..rotateZ(0),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme1.png',
                          width: width * 0.6, 
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(0, 300, 0)..rotateZ(45),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme2.png',
                          width: width * 0.6,
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(40, 300, 0)..rotateZ(50),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme3.png',
                          width: width * 0.6,
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(-0, 650, 0)..rotateZ(50),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme3.png',
                          width: width * 0.4,
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(-20, 200, 0)..rotateZ(50),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme3.png',
                          width: width * 0.3,
                        ),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(150, 450, 0)..rotateZ(0),
                        origin: const Offset(0, 0),
                        child: Image.asset(
                          'assets/images/forme1.png',
                          width: width * 0.6,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: 100),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              hint: Text(
                                'Select a name',
                                style: TextStyle(
                                  fontFamily: "gluten",
                                  color: Color(0xFFFFC02E),
                                ),
                              ),
                              value: selectedName,
                              items: getNames().map((name) {
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: "gluten",
                                      color: Color(0xFFFFC02E),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedName = value;
                                  if (selectedName != null) {
                                    updateBirthday(selectedName!);
                                  }
                                });
                              },
                              dropdownColor: Color(0x00b3a6a4),
                              iconEnabledColor: Color(0xFFFFC02E),
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      if (selectedBirthday != null)
                        Text(
                          'The birthday of $selectedName is on $formattedSelectedDate.',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "gluten",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFC02E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (_selectedImage != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.file(
                            _selectedImage!,
                            width: width * 0.5, // % 
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if the image cannot be loaded
                              return Image.asset(
                                "assets/images/default.png", // Default image
                                width: width * 0.5,
                              );
                            },
                          ),
                        ),
                        // Fallback if no birthday
                      if (_selectedImage == null && selectedName != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            "assets/images/default.png", // Default image 
                            width: width * 0.5,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
