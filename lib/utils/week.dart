class Week {
  late DateTime _begin;
  late DateTime _end;

  DateTime get begin => _begin;
  DateTime get end => _end;

  DateTime _midnight(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  Week.fromDate(DateTime date) {
    _begin = _midnight(date.subtract(Duration(days: date.weekday - 1)));
    _end = _midnight(date.add(Duration(days: 8 - date.weekday)))
        .subtract(const Duration(microseconds: 1));
  }

  Week() {
    Week currentWeek = Week.fromDate(DateTime.now());
    _begin = currentWeek.begin;
    _end = currentWeek.end;
  }

  Week next() {
    return Week.fromDate(_begin.add(const Duration(days: 7)));
  }

  Week previous() {
    return Week.fromDate(_begin.subtract(const Duration(days: 7)));
  }

  bool belong(DateTime date) {
    return date.isAfter(_begin) && date.isBefore(_end);
  }

  @override
  String toString() {
    String formatNum(int a) {
      return a.toString().padLeft(2, '0');
    }

    String formatDay(var day) {
      return "${formatNum(day.day)}/${formatNum(day.month)}";
    }

    return "${formatDay(_begin)} - ${formatDay(_end)}";
  }
}

class WeekDay {
  String name(int day) {
    switch (day) {
      case 0: return "Dimanche";
      case 1: return "Lundi";
      case 2: return "Mardi";
      case 3: return "Mercredi";
      case 4: return "Jeudi";
      case 5: return "Vendredi";
      case 6: return "Samedi";
      default : return "";
    }
  }
}
