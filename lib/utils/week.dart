class Week {
  late DateTime _begin;
  late DateTime _end;

  DateTime get begin => _begin;
  DateTime get end => _end;

  Week() {
    Week currentWeek = Week.fromDate(DateTime.now());
    _begin = currentWeek.begin;
    _end = currentWeek.end;
  }

  Week.fromDate(DateTime date) {
    _begin = date.subtract(Duration(days: date.weekday - 1));
    _end = date.add(Duration(days: 7 - date.weekday));
  }

  Week next() {
    return Week.fromDate(_begin.add(const Duration(days: 7)));
  }

  Week previous() {
    return Week.fromDate(_begin.subtract(const Duration(days: 7)));
  }

  // TODO : bool belong(DateTime date)

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
