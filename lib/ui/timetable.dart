import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget(
      {Key? key,
      required this.course,
      this.time = 1,
      this.top = false,
      this.bottom = false})
      : super(key: key);

  final CourseEntity course;
  final double time;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    late Color color;
    TextStyle style = time >= 1.4 ? Styles.f_13nt : Styles.f_10nt;
    String subject =
        course.subject != null ? course.subject! : course.category.name;
    String teachers = course.teachers.join(", ");
    String rooms = course.rooms.join(", ");

    switch (course.category) {
      case CourseCategory.cm:
        color = const Color.fromARGB(255, 196, 38, 38);
        break;
      case CourseCategory.td:
        color = const Color.fromARGB(255, 38, 38, 196);
        break;
      case CourseCategory.accueil:
        color = const Color.fromARGB(255, 38, 196, 38);
        break;
      case CourseCategory.examens:
        color = const Color.fromARGB(255, 38, 196, 196);
        break;
      case CourseCategory.indisponibilite:
        color = const Color.fromARGB(255, 56, 56, 56);
        break;
      case CourseCategory.reunions:
        color = const Color.fromARGB(255, 100, 56, 196);
        break;
      case CourseCategory.manifestation:
        color = const Color.fromARGB(255, 196, 100, 56);
        break;
      case CourseCategory.projetEncadreTutore:
        color = const Color.fromARGB(255, 196, 56, 196);
        break;
      case CourseCategory.DEFAULT:
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: (top ? 1 : 0), bottom: (bottom ? 1 : 0)),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color,
      ),
      height: max(72, 72 * time) - (top ? 1 : 0) - (bottom ? 1 : 0),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            course.start.toHourString(),
            style: style,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
              FittedBox(
                child: Text(
                  teachers.isEmpty ? "Pas de professeur indiqué" : teachers,
                  style: style,
                ),
              ),
              FittedBox(
                child: Text(
                  rooms.isEmpty ? "Pas de salle indiquée" : rooms,
                  style: style,
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
            style: style,
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

  List<Widget> viewBuilder() {
    List<Widget> res = [];
    double temp;
    bool top = false;
    bool bottom = false;

    temp =
        ((courses[0].start.hour - 8) * 60 + courses[0].start.minute) ~/ 15 / 4;

    res.add(SizedBox(height: temp * 72));

    for (int i = 0; i < courses.length; i++) {
      if (i == 0) {
        top = false;
      } else {
        top = (courses[i - 1].end != null
            ? courses[i - 1].end!.difference(courses[i].start).inMinutes >= 0
            : courses[i - 1]
                    .start
                    .add(const Duration(hours: 1))
                    .difference(courses[i].start)
                    .inMinutes <=
                0);
      }

      if (i == courses.length - 1) {
        bottom = false;
      } else {
        bottom = (courses[i].end != null
            ? courses[i].end!.difference(courses[i + 1].start).inMinutes >= 0
            : courses[i]
                    .start
                    .add(const Duration(hours: 1))
                    .difference(courses[i + 1].start)
                    .inMinutes <=
                0);
      }

      res.add(CourseWidget(
        course: courses[i],
        time: courses[i].end != null
            ? ((courses[i].start.difference(courses[i].end!).abs().inMinutes /
                        15)
                    .ceil() /
                4)
            : 1,
        top: top,
        bottom: bottom,
      ));

      if (i != courses.length - 1) {
        res.add(SizedBox(
            height: (courses[i].end != null
                ? courses[i]
                        .end!
                        .difference(courses[i + 1].start)
                        .abs()
                        .inMinutes ~/
                    15 /
                    4 *
                    72
                : courses[i]
                        .start
                        .add(const Duration(hours: 1))
                        .difference(courses[i + 1].start)
                        .abs()
                        .inMinutes ~/
                    15 /
                    4 *
                    72)));
      }
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    courses.sort((a, b) => a.start.compareTo(b.start));

    late List<Widget> children = [
      Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: Text(
          "${WeekDay.name(day.weekday)} ${day.toDayString()}",
          style: Styles().f_18,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      )
    ];

    if (courses.isEmpty) {
      children.add(Text(
        "Aucun cours",
        style: Styles().f_18,
        textAlign: TextAlign.center,
      ));
    } else {
      children.addAll(viewBuilder());
    }

    return Column(
      children: children,
    );
  }
}

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key, this.group}) : super(key: key);

  final GroupEntity? group;

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  Week week = Week();
  DateTime date = DateTime.now();
  late Future<List<CourseEntity>> _schedule;

  Future<List<CourseEntity>> fetchSchedule(Week w) async {
    List<CourseEntity> courses = List.empty(growable: true);
    GroupEntity group = GroupEntity(-100, "", null, null, true);
    try {
      group = Api.instance
          .getData<List<GroupEntity>>("myGroups")
          .where((element) => element.referent != null)
          .first;
    } catch (e) {}

    courses
        .addAll(await Api.instance.schedule.getFromTo(widget.group ?? group, w.begin, w.end));

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

  calendarWeek(DateTime d) {
    changeWeek(Week.fromDate(d));
    changeDay(d);
  }

  Widget hourIndicator() {
    List<String> hourList =
        List.generate(12, (index) => (index + 8).toString().padLeft(2, '0'));
    List<Widget> children = [
      const SizedBox(
        height: 15,
      )
    ];

    for (var h in hourList) {
      children.add(Text(
        "$h _",
        style: Styles().f_10,
      ));
      children.add(const SizedBox(
        height: 60,
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
        DateBar(
          week: week,
          onPrevious: previousWeek,
          onNext: nextWeek,
          onCalendarDate: calendarWeek,
        ),
        Expanded(
          child: Stack(
            children: [
              LayoutBuilder(
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
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FutureBuilder(
                                    builder: (_, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                hourIndicator(),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10, right: 5),
                                                    child: DaySchedule(
                                                      courses: (snapshot.data
                                                              as List<
                                                                  CourseEntity>)
                                                          .where((element) =>
                                                              element.start
                                                                  .isTheSameDate(
                                                                      date))
                                                          .toList(),
                                                      day: date,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        );
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: const Color.fromARGB(
                                                255, 38, 96, 170),
                                            backgroundColor: ThemesHandler
                                                .instance.theme.card,
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
                    return UiScrollBar(
                      scrollController: null,
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        FutureBuilder(
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              List<Widget> view = [hourIndicator()];

                              for (int i = 0; i < 7; i++) {
                                DateTime d = week.begin.add(Duration(days: i));
                                List<CourseEntity> courses =
                                    (snapshot.data as List<CourseEntity>)
                                        .where((element) =>
                                            element.start.isTheSameDate(d))
                                        .toList();

                                if (!(courses.isEmpty && (i == 5 || i == 6))) {
                                  view.add(Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: DaySchedule(
                                            courses: courses, day: d)),
                                  ));
                                }
                              }

                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: view,
                                  ));
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(255, 38, 96, 170),
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
                    );
                  }
                },
              ),
              Row(
                children: [
                  Flexible(
                      flex: 3,
                      child: GestureDetector(
                          onTap: previousDay, onDoubleTap: previousWeek)),
                  const Spacer(flex: 2),
                  Flexible(
                      flex: 3,
                      child: GestureDetector(
                          onTap: nextDay, onDoubleTap: () => nextWeek()))
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
class TeacherTimeTable extends StatefulWidget {
  const TeacherTimeTable({Key? key}) : super(key: key);

  @override
  State<TeacherTimeTable> createState() => _TeacherTimeTableState();
}

class _TeacherTimeTableState extends State<TeacherTimeTable> {
  late Future<List<GroupEntity>> _promos;
  late Future<List<GroupEntity>> _groups;

  GroupEntity? _promo;
  GroupEntity? _group;

  Future<List<GroupEntity>> fetchPromos() async {
    return (await Api.instance.groups.get())
        .where((group) => group.private == false && group.parent == null)
        .toList();
  }

  Future<List<GroupEntity>> fetchGroups(GroupEntity group) async {
    return (await Api.instance.groups.get())
        .where((g) => g.private == false && g.parent?.id == group.id)
        .toList();
  }

  Widget getTimetable(GroupEntity? group) {
    if (group != null) {
      return TimeTable(key: UniqueKey(), group: group);
    } else {
      return const SizedBox(width: 0, height: 0,);
    }
  }

  @override
  void initState() {
    _promos = fetchPromos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget timetable = getTimetable(_group);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ThemesHandler.instance.theme.card),
          child: Column(
            children: [
              FutureBuilder(
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return DropdownInput<GroupEntity>(
                      onChanged: (promo) {
                        _promo = promo;
                        setState(() {
                          _groups = fetchGroups(_promo!);
                        });
                      },
                      hint: "Promo",
                      itemBuilder: (item) => Text(
                        (item as GroupEntity).name,
                        style: Styles().f_15.apply(
                            color: ThemesHandler.instance.theme.foreground),
                      ),
                      list: snapshot.data as List<GroupEntity>,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: const Color.fromARGB(255, 38, 96, 170),
                        backgroundColor: ThemesHandler.instance.theme.card,
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
                future: _promos,
              ),
              Builder(builder: (context) {
                if (_promo != null) {
                  return FutureBuilder(
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return DropdownInput<GroupEntity>(
                          onChanged: (group) {
                            setState(() {
                              _group = group;
                            });
                          },
                          hint: "Groupe",
                          itemBuilder: (item) => Text(
                            (item as GroupEntity).name,
                            style: Styles().f_15.apply(
                                color: ThemesHandler.instance.theme.foreground),
                          ),
                          list: snapshot.data as List<GroupEntity>,
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color.fromARGB(255, 38, 96, 170),
                            backgroundColor: ThemesHandler.instance.theme.card,
                            strokeWidth: 2,
                          ),
                        );
                      }
                    },
                    future: _groups,
                  );
                } else {
                  return const SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
              })
            ],
          ),
        ),
        Expanded(
          child: timetable,
        )
      ],
    );
  }
}

