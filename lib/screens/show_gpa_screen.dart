import 'package:flutter/material.dart';
import '../gpa_calculator/gpa_calculator.dart';
import '../gpa_calculator/course.dart';
import '../gpa_calculator/cgpa_optimiser.dart'; // Import CGPAOptimiser

class ShowGPAScreen extends StatefulWidget {
  final List<Course> courses;
  const ShowGPAScreen({super.key, required this.courses});

  @override
  _ShowGPAScreenState createState() => _ShowGPAScreenState();
}

class _ShowGPAScreenState extends State<ShowGPAScreen> {
  double? optimizedCGPA;
  List<Course>? optimizedCourses;

  void _showOptimisationDialog() {
    TextEditingController totalController = TextEditingController();
    TextEditingController pmeController = TextEditingController();
    TextEditingController gceController = TextEditingController();
    TextEditingController smeController = TextEditingController();
    TextEditingController hseController = TextEditingController();
    TextEditingController oeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Credit Requirements"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Total Credits", totalController),
              _buildTextField("PME Credits", pmeController),
              _buildTextField("GCE Credits", gceController),
              _buildTextField("SME Credits", smeController),
              _buildTextField("HSE Credits", hseController),
              _buildTextField("OE Credits", oeController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _optimiseCGPA(
                  int.tryParse(totalController.text) ?? 0,
                  int.tryParse(pmeController.text) ?? 0,
                  int.tryParse(gceController.text) ?? 0,
                  int.tryParse(smeController.text) ?? 0,
                  int.tryParse(hseController.text) ?? 0,
                  int.tryParse(oeController.text) ?? 0,
                );
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Optimise"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  void _optimiseCGPA(int total, int pme, int gce, int sme, int hse, int oe) {
    CGPAOptimiser optimiser = CGPAOptimiser(widget.courses, total, pme, gce, sme, hse, oe);
    setState(() {
      optimizedCGPA = optimiser.getOptimizedCGPA();
      optimizedCourses = optimiser.getOptimizedCourseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    GPACalculator calculator = GPACalculator(widget.courses);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("GPA Summary")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CGPA: ${calculator.CGPA.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Semester-wise GPA:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Column(
                children: calculator.semesterGPA.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Semester ${entry.key}", style: const TextStyle(fontSize: 16)),
                        Text(entry.value.toStringAsFixed(2), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showOptimisationDialog,
                child: const Text("Optimise"),
              ),
              if (optimizedCGPA != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Optimized CGPA: ${optimizedCGPA!.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Optimized Courses:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: optimizedCourses!.length,
                    itemBuilder: (context, index) {
                      Course course = optimizedCourses![index];
                      return ListTile(
                        title: Text(course.title),
                        subtitle: Text("Credits: ${course.credits}, Grade: ${course.grade}"),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
