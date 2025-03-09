import 'course.dart';

class GPACalculator{
  List<Course> courses = [];
  Map<int, List<Course>> _semesterCourses = {};
  double CGPA = 0.0;
  Map<int, double> semesterGPA = {};

  GPACalculator(this.courses) {
    for (Course course in courses) {
      // Ensure the semester list is initialized before adding courses
      _semesterCourses.putIfAbsent(course.semester, () => []);
      _semesterCourses[course.semester]!.add(course);
    }
    _calculateSGPA();
    _calculateCGPA();
  }

  // All the courses done in the semester (even courses with U/I/W) will be considered for SGPA calculation
  void _calculateSGPA() {
    _semesterCourses.forEach((semester, courses) {
      double totalCredits = 0;
      double weightedGradePoints = 0;

      for (var course in courses) {
        if(course.isPassFailCourse()) continue;
        double gradePoint = course.getGradePoints();
        double credits = course.credits;
        totalCredits += credits;
        weightedGradePoints += gradePoint * credits;
      }

      semesterGPA[semester] = totalCredits > 0 ? weightedGradePoints / totalCredits : 0.0;
    });
  }

  void _calculateCGPA() {
    double totalCredits = 0;
    double weightedGradePoints = 0;

    List<Course> allCourses = courses;
    allCourses = _removeDuplicateFailedCourses(allCourses);

    for (var course in allCourses) {
      if(course.isPassFailCourse()) continue;
      double gradePoint = course.getGradePoints();
      double credits = course.credits;
      if(gradePoint == 0 && _isElective(course)) {
        // Electives with fail grade will be ignored in CGPA calculation
        continue;
      }
      totalCredits += credits;
      weightedGradePoints += gradePoint * credits;
    }

    CGPA = totalCredits > 0 ? weightedGradePoints / totalCredits : 0.0;
  }


  List<Course> _removeDuplicateFailedCourses(List<Course> courses) {
    Map<String, Course> uniqueCourses = {};

    for (var curr in courses) {
      if (uniqueCourses.containsKey(curr.code)) {
        Course prev = uniqueCourses[curr.code]!;
        // Keep the course with the higher grade
        if (prev.getGradePoints() < curr.getGradePoints()) {
          uniqueCourses[curr.code] = curr;
        }
      } else {
        // First occurrence of the course
        uniqueCourses[curr.code] = curr;
      }
    }

    return uniqueCourses.values.toList();
  }

  bool _isElective(Course course) {
    List<String> electives = ["PME", "GCE", "SME", "HSE", "OE"];
    return electives.contains(course.category);
  }

  double getSGPA(int semester) => semesterGPA[semester] ?? 0.0;
  double getCGPA() => CGPA;
}