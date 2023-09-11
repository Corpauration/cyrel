import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:cyrel/utils/string.dart';
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
    String rooms = course.rooms
        .map((e) => e.startsWith("PAU ") ? e.split(" ")[1] : e)
        .join(", ");

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
    GroupEntity group = GroupEntity(-100, "", null, null, true, {});
    try {
      if (Api.instance.getData<UserEntity>("me").type == UserType.student) {
        group = Api.instance
            .getData<List<GroupEntity>>("myGroups")
            .where((element) => element.referent != null)
            .first;
      } else {
        List<String> professors =
            await Api.instance.schedule.getScheduleProfessors();
        Iterable<String> match = professors.where((element) {
          String r =
              "${Api.instance.getData<UserEntity>("me").lastname.replaceAll(" ", " *").toUpperCase()} ${Api.instance.getData<UserEntity>("me").firstname.replaceAll(" ", " *").toUpperCase()}";
          return RegExp(r.replaceAllCapitalizedAccent()).hasMatch(element);
        });
        if (match.isNotEmpty) {
          group.name = match.first;
        }
      }
    } catch (e) {}

    if ((widget.group ?? group).id > -100) {
      print(widget.group?.id);
      courses.addAll(await Api.instance.schedule
          .getFromTo(widget.group ?? group, w.begin, w.end));
    } else {
      courses.addAll(await Api.instance.schedule.getProfessorScheduleFromTo(
          (widget.group ?? group).name, w.begin, w.end));
    }

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

class StudentTimeTable extends StatefulWidget {
  const StudentTimeTable({Key? key}) : super(key: key);

  @override
  State<StudentTimeTable> createState() => _StudentTimeTableState();
}

class _StudentTimeTableState extends State<StudentTimeTable> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PromGrpSelector(
            builder: (_, group) => TimeTable(key: UniqueKey(), group: group),
            visible: visible),
        Positioned(
          bottom: 20,
          right: 20,
          child: BoxButton(
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          transitionDuration: const Duration(microseconds: 0),
                          reverseTransitionDuration:
                              const Duration(microseconds: 0),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  UiContainer(
                                      backgroundColor: Colors.transparent,
                                      child: UiPopup(
                                          onSubmit: (s) => {
                                                if (s == "groups")
                                                  {
                                                    setState(() {
                                                      visible = !visible;
                                                    })
                                                  }
                                              },
                                          choices: const {
                                            "groups":
                                                "Voir d'autres emplois du temps",
                                            "google":
                                                "Synchroniser avec Google Calendar"
                                          }))));
                });
              },
              child: Container(
                  width: 45,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 38, 96, 170),
                      borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    "assets/svg/group_white.svg",
                    height: 25,
                  ))),
        )
      ],
    );
  }
}

class TeacherTimeTable extends StatelessWidget {
  const TeacherTimeTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PromGrpSelector(
      builder: (_, group) => TimeTable(key: UniqueKey(), group: group),
      customFetchPromos: () async {
        List<GroupEntity> p = (await Api.instance.groups.get())
            .where((group) => group.private == false && group.parent == null)
            .toList();
        p.insert(0, GroupEntity(-100, "Professeurs", null, null, false, {}));
        return p;
      },
      customFetchGroups: (promo) async {
        if (promo.id == -100) {
          List<String> s = await Api.instance.schedule.getScheduleProfessors();
          return List.generate(
              s.length,
              (index) =>
                  GroupEntity(-100 - index, s[index], null, null, false, {}));
        } else {
          return (await Api.instance.groups.get())
              .where((g) => g.private == false && g.parent?.id == promo.id)
              .toList();
        }
      },
    );
  }
}
