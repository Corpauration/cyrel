import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget({Key? key, required this.course, this.size = 74})
      : super(key: key);

  final CourseEntity course;
  final double size;

  @override
  Widget build(BuildContext context) {
    late Color color;

    switch (course.category) {
      case CourseCategory.DEFAULT:
        color = Colors.blue;
        break;
      case CourseCategory.cm:
        color = const Color.fromARGB(255, 196, 38, 38);
        break;
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color,
      ),
      height: max(74, size),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            course.start.toHourString(),
            style: TextStyle(
                fontSize: 11, fontFamily: "Montserrat", color: Colors.white),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                course.subject != null ? course.subject! : "",
                style: TextStyle(
                    fontSize: 11, fontFamily: "Montserrat", color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              FittedBox(
                child: Text(
                  course.teachers.join(", "),
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: "Montserrat",
                      color: Colors.white),
                ),
              ),
              FittedBox(
                child: Text(
                  course.rooms.join(", "),
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: "Montserrat",
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            course.end != null
                ? course.end!.toHourString()
                : "Fin non indiquée",
            style: TextStyle(
                fontSize: 11, fontFamily: "Montserrat", color: Colors.white),
          ),
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
      children.addAll(courses.map((c) => CourseWidget(
            course: c,
            size: 111,
          )));
    }

    return Column(
      children: children,
    );
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
  late Future<List<CourseEntity>> _schedule;

  Future<List<CourseEntity>> fetchSchedule(Week w) async {
    List<CourseEntity> courses = List.empty(growable: true);
    GroupEntity group = Api.instance
        .getData<List<GroupEntity>>("myGroups")
        .where((element) => element.referent != null)
        .first;

    courses
        .addAll(await Api.instance.schedule.getFromTo(group, w.begin, w.end));

    return courses;
  }

  changeWeek(Week w) {
    setState(() {
      week = w;
      _schedule = fetchSchedule(week);
    });
  }

  previousWeek() {
    changeWeek(week.previous());
    setState(() {
      date = week.end;
    });
  }

  nextWeek() {
    changeWeek(week.next());
    setState(() {
      date = week.begin;
    });
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

  Widget hourIndicator() {
    List<String> hourList =
        List.generate(12, (index) => (index + 8).toString().padLeft(2, '0'));
    List<Widget> children = [
      const SizedBox(
        height: 16,
      )
    ];

    for (var h in hourList) {
      children.add(Text(
        "$h -",
        style: Styles.f_13,
      ));
      children.add(const SizedBox(
        height: 74,
      ));
    }

    return Column(children: children);
  }

  @override
  void initState() {
    _schedule = fetchSchedule(week);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              if (CyrelOrientation.current == CyrelOrientation.portrait) {
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
                          child: UiScrollBar(
                        scrollController: null,
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          FutureBuilder(
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        hourIndicator(),
                                        Expanded(
                                          child: DaySchedule(
                                            courses: (snapshot.data
                                                    as List<CourseEntity>)
                                                .where((element) => element
                                                    .start
                                                    .isTheSameDate(date))
                                                .toList(),
                                            day: date,
                                          ),
                                        ),
                                      ]),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        const Color.fromARGB(255, 38, 96, 170),
                                    backgroundColor:
                                        ThemesHandler.instance.theme.card,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                            },
                            future: _schedule,
                          ),
                        ]),
                      )),
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
                      ),
                    ]));
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
