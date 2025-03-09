import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpa_calc/screens/show_gpa_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../gpa_calculator/course.dart';
import '../process_pdf/process_extracted_text.dart';

class UploadPDFScreen extends StatefulWidget {
  const UploadPDFScreen({super.key});

  @override
  _UploadPDFScreenState createState() => _UploadPDFScreenState();
}

class _UploadPDFScreenState extends State<UploadPDFScreen> {
  List<Course> _displayedCourses = [];

  Future<void> pickAndExtractPDF(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      List<int> bytes = result.files.single.bytes!;
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      setState(() {
        _displayedCourses = ProcessExtractedText().processText(text);
      });
    }

    if(_displayedCourses.isEmpty) {
      Alert(
          context: context,
        title: "OOPS!",
        desc: "Something Went Wrong While Uploading The File",
        buttons: [
          DialogButton(
              child: const Text("OK"),
              onPressed: () => {
                Navigator.pop(context)
              }
          ),
        ]
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("GPA Calculator"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This tool is still in development stage.",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height:10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => {
                      pickAndExtractPDF(context)
                    },
                    child: const Text("Select PDF"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addCourse,
                    child: const Text("Add Course"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowGPAScreen(courses: _displayedCourses))
                      )
                    },
                    child: const Text("Calculate GPA"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _displayedCourses.isEmpty
                    ? const Center(child: Text("No courses available"))
                    : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Semester")),
                      DataColumn(label: Text("Code")),
                      DataColumn(label: Text("Title")),
                      DataColumn(label: Text("Category")),
                      DataColumn(label: Text("Credits")),
                      DataColumn(label: Text("Grade")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: _displayedCourses.asMap().entries.map((entry) {
                      int index = entry.key;
                      Course course = entry.value;
                      return DataRow(cells: [
                        DataCell(Text(course.semester.toString())),
                        DataCell(Text(course.code)),
                        DataCell(Text(course.title)),
                        DataCell(Text(course.category)),
                        DataCell(Text(course.credits.toString())),
                        DataCell(Text(course.grade)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editCourse(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCourse(index),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCourse() {
    TextEditingController semesterController = TextEditingController();
    TextEditingController codeController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController creditsController = TextEditingController();
    TextEditingController gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Semester", semesterController),
              _buildTextField("Course Code", codeController),
              _buildTextField("Title", titleController),
              _buildTextField("Category", categoryController),
              _buildTextField("Credits", creditsController),
              _buildTextField("Grade", gradeController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _displayedCourses.add(Course(
                    semester: int.tryParse(semesterController.text) ?? 0,
                    code: codeController.text,
                    title: titleController.text,
                    category: categoryController.text,
                    credits: double.tryParse(creditsController.text) ?? 0.0,
                    grade: gradeController.text.toUpperCase(),
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _editCourse(int index) {
    Course course = _displayedCourses[index];
    TextEditingController semesterController = TextEditingController(text: course.semester.toString());
    TextEditingController codeController = TextEditingController(text: course.code);
    TextEditingController titleController = TextEditingController(text: course.title);
    TextEditingController categoryController = TextEditingController(text: course.category);
    TextEditingController creditsController = TextEditingController(text: course.credits.toString());
    TextEditingController gradeController = TextEditingController(text: course.grade);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Semester", semesterController),
              _buildTextField("Course Code", codeController),
              _buildTextField("Title", titleController),
              _buildTextField("Category", categoryController),
              _buildTextField("Credits", creditsController),
              _buildTextField("Grade", gradeController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _displayedCourses[index] = Course(
                    semester: int.tryParse(semesterController.text) ?? 0,
                    code: codeController.text,
                    title: titleController.text,
                    category: categoryController.text,
                    credits: double.tryParse(creditsController.text) ?? 0.0,
                    grade: gradeController.text.toUpperCase(),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(int index) {
    setState(() {
      _displayedCourses.removeAt(index);
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
