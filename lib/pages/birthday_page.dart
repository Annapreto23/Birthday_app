import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../services/birthday_manager.dart'; //my birthday manager that I struggled to code despite its short length haha

class BirthdayPage extends StatefulWidget {
  @override
  _BirthdayPageState createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _birthdays = [];

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    try {
      List<Map<String, dynamic>> birthdays = await BirthdayManager.loadBirthdays();
      setState(() {
        _birthdays = birthdays;
      });
    } catch (e) {
      print('Error loading birthdays: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory('${directory.path}/images');
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }
    final fileName = '${_nameController.text}.png';
    final path = '${imagesDirectory.path}/$fileName';
    final image = await imageFile.readAsBytes();
    final file = File(path);
    await file.writeAsBytes(image);
    return path;
  }

  void _submit() async {
    if (_nameController.text.isNotEmpty && _selectedDate != null) {
      try {
        List<Map<String, dynamic>> birthdays = List.from(_birthdays);
        String? imagePath;
        if (_selectedImage != null) {
          imagePath = await _saveImage(_selectedImage!);
        }
        birthdays.add({
          'name': _nameController.text,
          'date': _selectedDate!.toIso8601String(),
          'image': imagePath,
        });
        await BirthdayManager.saveBirthdays(birthdays);
        _loadBirthdays(); // Reload birthdays after adding (very important... black screen if missing!!)

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Birthday added successfully!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _resetForm(); // Reset the form
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error saving birthday: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add birthday.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name and select a date')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _selectedDate = null;
      _selectedImage = null;
    });
  }

  Future<void> _deleteBirthday(int index) async {
    try {
      List<Map<String, dynamic>> birthdays = List.from(_birthdays);
      final birthday = birthdays[index];
      if (birthday['image'] != null) {
        final imageFile = File(birthday['image']);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      birthdays.removeAt(index);
      await BirthdayManager.saveBirthdays(birthdays);
      _loadBirthdays(); // Reload birthdays after deleting
    } catch (e) {
      print('Error deleting birthday: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete birthday.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Manage Birthdays',
          style: TextStyle(
            fontFamily: "gluten",
            color: Color(0xFFFFC02E),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFFFFC02E)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate == null
                  ? 'Select date'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: TextStyle(fontSize: 15, color: Color(0xFFFFC02E))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                textStyle: TextStyle(fontSize: 18, color: Color(0xFFFFC02E)), 
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image', style: TextStyle(color: Color(0xFFFFC02E))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            SizedBox(height: 20),
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit',
                style: TextStyle(color: Colors.black), 
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFC02E), 
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                textStyle: TextStyle(fontSize: 18, color: Color(0xFF000000)), 
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _birthdays.length,
                itemBuilder: (context, index) {
                  final birthday = _birthdays[index];
                  return ListTile(
                    leading: birthday['image'] != null
                        ? Image.file(File(birthday['image']), width: 50, height: 50)
                        : null,
                    title: Text(birthday['name']),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(birthday['date']))),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteBirthday(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
