import '../gpa_calculator/course.dart';

class ProcessCumulativeGradeCard{
  List<Course> _courses = [];

  List<Course> processText(lines) {

    int currentSemester = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.startsWith("Semester")) {
        // Extract semester number
        List<String> parts = line.split(' ');
        if (parts.length > 1) {
          currentSemester = int.tryParse(parts[1]) ?? 0;
        }
      } else if (currentSemester > 0 && _isCourseCode(line)) {
        // Extract course details
        String courseCode = line;
        int x = _findCreditsIndex(lines, i + 1);

        if (x == -1) continue; // Skip if credits not found

        String title = _extractCourseTitle(lines, i + 1, i + x - 1);
        String category = lines[i + x].trim();
        double credits = double.tryParse(lines[i + x + 1].trim()) ?? 0.0;
        String grade = lines[i + x + 2].trim();

        Course c = Course(
          semester: currentSemester,
          code: courseCode,
          title: title,
          category: category,
          credits: credits,
          grade: grade,
        );

        _courses.add(c);
        i += x + 2; // Skip processed lines
      }
    }
    return _courses;
  }

  bool _isCourseCode(String line) {
    return RegExp(r'^[A-Z]{2,}[0-9]+').hasMatch(line);
  }

  int _findCreditsIndex(List<String> lines, int startIndex) {
    for (int j = startIndex; j < lines.length; j++) {
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(lines[j].trim())) {
        return j - startIndex; // Return relative index from `i`
      }
    }
    return -1; // Not found
  }

  String _extractCourseTitle(List<String> lines, int start, int end) {
    return lines.sublist(start, end + 1).map((e) => e.trim()).join(' ');
  }
}