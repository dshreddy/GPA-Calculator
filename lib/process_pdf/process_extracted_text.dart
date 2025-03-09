import '../gpa_calculator/course.dart';
import 'process_semester_grade_card.dart';
import 'process_cumulative_grade_card.dart';

class ProcessExtractedText {
  List<Course> processText(String extractedText) {
    List<String> lines = extractedText.split('\n');
    if(lines.length>=13) {
      if(lines[10].startsWith("CUMULATIVE GRADE CARD") || lines[11].startsWith("CUMULATIVE GRADE CARD")) {
        return ProcessCumulativeGradeCard().processText(lines);
      } else if(lines[12].startsWith("GRADE CARD- Semester") || lines[13].startsWith("GRADE CARD- Semester")) {
        return ProcessSemesterGradeCard().processText(lines);
      }
    }
    return [];
  }
}