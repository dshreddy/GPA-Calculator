class Course {
  int semester;
  String code;
  String title;
  String category;
  double credits;
  String grade;
  final Map<String, int> gradePointMap = {
    "S": 10, "A": 9, "B": 8, "C": 7, "D": 6, "E": 4,
    "U": 0, "W": 0, "I": 0, "Y": 0, "N": 0, "P": 0, "F": 0,
  };

  Course({
    required this.semester,
    required this.code,
    required this.title,
    required this.category,
    required this.credits,
    required this.grade,
  });

  double getGradePoints() {
    return gradePointMap[grade] as double;
  }

  bool isPassFailCourse() {
    return grade == "P" || grade == "F" || grade == "Y" || grade == "N";
  }
}