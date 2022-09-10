import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget({Key? key, required this.course}) : super(key: key);

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: Colors.blue,
      child: Column(children: [
        Text(
          course.subject != null ? course.subject! : "",
        ),
      ]),
    );
  }
}

class DaySchedule extends StatelessWidget {
  const DaySchedule({Key? key, required this.courses, required this.day})
      : super(key: key);

  final List<CourseEntity> courses;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    late List<Widget> children = [
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          "${WeekDay.name(day.weekday)} ${day.toDayString()}",
          style: Styles.f_18,
          textAlign: TextAlign.center,
        ),
      )
    ];

    if (courses.isEmpty) {
      children.add(Text(
        "Aucun cours",
        style: Styles.f_18,
        textAlign: TextAlign.center,
      ));
    } else {
      children.addAll(courses.map((c) => CourseWidget(course: c)));
    }

    Widget view = Column(
      children: children,
    );

    return UiScrollBar(scrollController: null, child: view);
  }
}

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  Week week = Week();
  DateTime date = DateTime.now();

  changeWeek(Week w) {
    setState(() {
      week = w;
      date = week.begin;
    });
  }

  previousWeek() {
    changeWeek(week.previous());
  }

  nextWeek() {
    changeWeek(week.next());
  }

  changeDay(DateTime d) {
    setState(() {
      date = d;

      if (week.begin.isAfter(date)) {
        previousWeek();
      } else if (week.end.isBefore(date)) {
        nextWeek();
      }
    });
  }

  previousDay() {
    changeDay(date.subtract(const Duration(days: 1)));
  }

  nextDay() {
    changeDay(date.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            BoxButton(
                onTap: previousWeek,
                child: SizedBox(
                    width: 28,
                    child: SvgPicture.asset("assets/svg/arrow_left.svg",
                        height: 28))),
            Container(
              width: 180,
              alignment: Alignment.center,
              child: Text(
                week.toString(),
                textAlign: TextAlign.center,
                style: Styles.f_24,
              ),
            ),
            BoxButton(
                onTap: nextWeek,
                child: SizedBox(
                    width: 28,
                    child: SvgPicture.asset("assets/svg/arrow_right.svg",
                        height: 28))),
          ]),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight >
                  (screenRatio * constraints.maxWidth)) {
                return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(children: [
                      SizedBox(
                        width: 24,
                        height: double.infinity,
                        child: BoxButton(
                          onTap: previousDay,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/arrow_left.svg",
                              height: 26,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Column(children: [
                        Expanded(
                            child: DaySchedule(
                          courses: [],
                          day: date,
                        )),
                      ])),
                       SizedBox(
                        width: 24,
                        height: double.infinity,
                        child: BoxButton(
                          onTap: nextDay,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/arrow_right.svg",
                              height: 26,
                            ),
                          ),
                        ),
                      ),]));
              } else {
                return Container(
                  color: Colors.amber,
                );
              }
            },
          ),
        )
      ],
    );
  }
}
