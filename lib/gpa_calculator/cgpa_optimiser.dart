import 'course.dart';

class CGPAOptimiser {
  final Map<String, double> _electiveCatReqCredits = {
    "PME": 0, "SME": 0, "GCE": 0, "HSE": 0, "OE": 0
  };
  List<Course> courses = [];
  Map<int, List<Course>> _semesterCourses = {};
  List<Course> _finalCourses = [];
  double _CGPA = 0.0;
  double _totalReqCredits = 0;

  CGPAOptimiser(this.courses, int total, int pme, int gce, int sme, int hse, int oe) {
    for (Course course in courses) {
      // Ensure the semester list is initialized before adding courses
      _semesterCourses.putIfAbsent(course.semester, () => []);
      _semesterCourses[course.semester]!.add(course);
    }
    _totalReqCredits = total.toDouble();
    _electiveCatReqCredits["PME"] = pme.toDouble();
    _electiveCatReqCredits["GCE"] = gce.toDouble();
    _electiveCatReqCredits["SME"] = sme.toDouble();
    _electiveCatReqCredits["HSE"] = hse.toDouble();
    _electiveCatReqCredits["OE"] = oe.toDouble();

    if(_checkCreditsReq()) {
      _calculateMAXCGPA();
    }
  }

  bool _checkCreditsReq() {
    double totalCredits = 0;
    Map<String, double> catCredits = {
      "PME": 0,
      "GCE": 0,
      "SME": 0,
      "HSE": 0,
      "OE": 0
    };
    for(Course course in courses) {
      totalCredits += course.credits;
      if(catCredits.containsKey(course.category)) catCredits[course.category] = (catCredits[course.category] ?? 0) +  course.credits;
    }
    return totalCredits >= _totalReqCredits && _areElectiveCreditsMet(catCredits);
  }

  void _calculateMAXCGPA() {
    double totalCredits = 0;
    double weightedGradePoints = 0;

    List<Course> allCourses = courses;
    allCourses = _removeDuplicateFailedCourses(allCourses);

    // Process Core Courses (excluding electives)
    for (var course in allCourses) {
      if (_isElective(course)) continue;
      if(course.isPassFailCourse()) continue;
      double gradePoint = course.getGradePoints();
      double credits = course.credits;
      totalCredits += credits;
      weightedGradePoints += gradePoint * credits;
    }

    // Get all electives
    List<Course> electives = allCourses.where((c) => _isElective(c)).toList();

    // Recursively find the best subset of electives
    _findBestElectiveSubset([], electives, 0, {}, totalCredits, weightedGradePoints, _totalReqCredits);
  }

  void _findBestElectiveSubset(List<Course> subset, List<Course> electives, int i, Map<String, double> catCredits, double totalCredits, double weightedGradePoints, double totalReqCredits) {
    if (i == electives.length) {
      // Check if all required credits are met
      if (_areElectiveCreditsMet(catCredits) && totalCredits >= totalReqCredits) {
        double currCGPA = weightedGradePoints / totalCredits;
        if (currCGPA > _CGPA) {
          _CGPA = currCGPA;
          _finalCourses = List.of(subset); // Save the best selection
        }
      }
      return;
    }

    // Don't pick the current elective
    _findBestElectiveSubset(subset, electives, i + 1, Map.of(catCredits), totalCredits, weightedGradePoints, totalReqCredits);

    // Pick the current elective
    Course current = electives[i];
    if(current.isPassFailCourse()) {
      totalReqCredits -= current.credits;
      Map<String, double> newCatCredits = Map.of(catCredits);
      newCatCredits[current.category] = (newCatCredits[current.category] ?? 0) + current.credits;
      _findBestElectiveSubset([...subset, current], electives, i + 1, newCatCredits, totalCredits, weightedGradePoints, totalReqCredits);
    } else {
      totalCredits = current.credits + totalCredits;
      weightedGradePoints = weightedGradePoints + (current.getGradePoints() * current.credits);
      Map<String, double> newCatCredits = Map.of(catCredits);
      newCatCredits[current.category] = (newCatCredits[current.category] ?? 0) + current.credits;
      _findBestElectiveSubset([...subset, current], electives, i + 1, newCatCredits, totalCredits, weightedGradePoints, totalReqCredits);
    }
  }

  bool _areElectiveCreditsMet(Map<String, double> catCredits) {
    for (var category in _electiveCatReqCredits.keys) {
      if ((catCredits[category] ?? 0) < _electiveCatReqCredits[category]!) {
        return false;
      }
    }
    return true;
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
    return _electiveCatReqCredits.containsKey(course.category);
  }

  double getOptimizedCGPA() => _CGPA;
  List<Course> getOptimizedCourseList() => _finalCourses;
}
