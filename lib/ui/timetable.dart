import 'dart:async';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:cyrel/utils/platform.dart';
import 'package:cyrel/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:screenshot/screenshot.dart';

abstract class Period {
  DateTime periodStart();
  DateTime periodEnd();
  List<Widget> periodDisplay({required TextStyle style});
  Color periodColor();
}

class CoursePeriod extends CourseEntity implements Period {
  CoursePeriod(
      {required super.id,
      required super.start,
      required super.end,
      required super.category,
      required super.subject,
      required super.teachers,
      required super.rooms});

  CoursePeriod.fromCourse(CourseEntity c)
      : super(
            id: c.id,
            start: c.start,
            end: c.end,
            category: c.category,
            subject: c.subject,
            teachers: c.teachers,
            rooms: c.rooms);

  @override
  Color periodColor() {
    Color color;

    switch (category) {
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

    return color;
  }

  @override
  List<Widget> periodDisplay({required TextStyle style}) {
    String subject =
        super.subject != null ? super.subject! : super.category.name;
    String teachers = super.teachers.join(", ");
    String rooms = super
        .rooms
        .map((e) => e.startsWith("PAU ") ? e.split(" ")[1] : e)
        .join(", ");

    return [
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
      )
    ];
  }

  @override
  DateTime periodEnd() {
    if (end == null) {
      return start.apply(hour: 19, minute: 30);
    } else {
      return end!;
    }
  }

  @override
  DateTime periodStart() {
    return start;
  }
}

class PeriodWidget extends StatelessWidget {
  const PeriodWidget({
    Key? key,
    required this.period,
    required this.height,
    this.paddingTop = 0,
    this.paddingBottom = 0,
  }) : super(key: key);

  final Period period;
  final double height;
  final double paddingTop;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    TextStyle style =
        period.periodEnd().difference(period.periodStart()).inMinutes / 60 >=
                1.4
            ? Styles.f_13nt
            : Styles.f_10nt;

    return Container(
        height: height,
        padding: EdgeInsets.fromLTRB(0, paddingTop, 0, paddingBottom),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: period.periodColor(),
          ),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                period.periodStart().toHourString(),
                style: style,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: period.periodDisplay(style: style),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                period.periodEnd().toHourString(),
                style: style,
              ),
            ),
          ]),
        ));
  }
}

class DaySchedule extends StatelessWidget {
  const DaySchedule(
      {Key? key,
      required this.periods,
      required this.day,
      required this.quarterSize,
      required this.emptyText})
      : super(key: key);

  final List<Period> periods;
  final DateTime day;
  final double quarterSize;
  final String emptyText;

  Widget space(int n) {
    return SizedBox(height: n * quarterSize);
  }

  List<Widget> view() {
    List<Widget> res = [];

    res.add(space(((periods[0].periodStart().hour - 8) * 60 +
            periods[0].periodStart().minute) ~/
        15));

    for (int i = 0; i < periods.length; i++) {
      int spaceBefore = i == 0
          ? 0
          : periods[i - 1]
                  .periodEnd()
                  .difference(periods[i].periodStart())
                  .inMinutes
                  .abs() ~/
              15;

      bool spaceAfter = i == periods.length - 1
          ? false
          : (periods[i]
                      .periodEnd()
                      .difference(periods[i + 1].periodStart())
                      .inMinutes ~/
                  15) ==
              0;

      if (spaceBefore != 0) {
        res.add(space(spaceBefore));
      }

      res.add(PeriodWidget(
        period: periods[i],
        height: (periods[i]
                    .periodStart()
                    .difference(periods[i].periodEnd())
                    .inMinutes
                    .abs() ~/
                15) *
            quarterSize,
        paddingTop: spaceBefore == 0 ? 2 : 0,
        paddingBottom: spaceAfter ? 2 : 0,
      ));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    periods.sort((a, b) => a.periodStart().compareTo(b.periodStart()));

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

    if (periods.isEmpty) {
      children.add(Text(
        emptyText,
        style: Styles().f_18,
        textAlign: TextAlign.center,
      ));
    } else {
      children.addAll(view());
    }

    return Column(
      children: children,
    );
  }
}

class TimetableState {
  Week week = Week();
  DateTime date = DateTime.now();
  Future<GroupEntity> group = () async {
    GroupEntity group = GroupEntity(-100, "", null, null, true, {});
    try {
      if (Api.instance.getData<UserEntity>("me").type == UserType.student) {
        group = Api.instance
            .getData<List<GroupEntity>>("myGroups")
            .where((element) => element.tags["type"] == "group")
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

    return group;
  }();
  late Future<List<CourseEntity>> schedule;

  Future<List<CourseEntity>> fetchSchedule(Week w) async {
    List<CourseEntity> courses = List.empty(growable: true);

    if ((await group).id > -100) {
      courses.addAll(await Api.instance.schedule
          .getFromTo(await group, w.begin, w.end));
    } else {
      courses.addAll(await Api.instance.schedule.getProfessorScheduleFromTo(
          (await group).name, w.begin, w.end));
    }

    return courses;
  }

  changeWeek(Week w) {
      week = w;
      schedule = fetchSchedule(week);
  }

  previousWeek() {
    changeWeek(week.previous());
      date = week.end;
  }

  nextWeek() {
    changeWeek(week.next());
      date = week.begin;
  }

  changeDay(DateTime d) {
      date = d;

      if (week.begin.isAfter(date)) {
        previousWeek();
      } else if (week.end.isBefore(date)) {
        nextWeek();
      }
  }

  previousDay() {
    changeDay(date.subtract(const Duration(days: 1)));
  }

  nextDay() {
    changeDay(date.add(const Duration(days: 1)));
  }
}

class HourIndicator extends StatelessWidget {
  const HourIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class TimetableLandscapeView extends StatelessWidget {
  const TimetableLandscapeView({super.key, required this.timetableState});

  final TimetableState timetableState;

  @override
  Widget build(BuildContext context) {
    return UiScrollBar(
      scrollController: null,
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        FutureBuilder(
          builder: (_, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.done &&
                snapshot.hasData) {
              List<Widget> view = [const HourIndicator()];

              for (int i = 0; i < 7; i++) {
                DateTime d = timetableState.week.begin.add(Duration(days: i));
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
                          periods: courses
                              .map((c) =>
                              CoursePeriod.fromCourse(c))
                              .toList(),
                          day: d,
                          quarterSize: 18,
                          emptyText: "rien",
                        )),
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
          future: timetableState.schedule,
        ),
      ]),
    );

  }
}


class TimeTable extends StatefulWidget {
  const TimeTable({Key? key, required this.timetableState}) : super(key: key);

  final TimetableState timetableState;

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  changeWeek(Week w) {
    setState(() {
      widget.timetableState.changeWeek(w);
    });
  }

  previousWeek() {
    setState(() {
      widget.timetableState.previousWeek();
    });
  }

  nextWeek() {
    setState(() {
      widget.timetableState.nextWeek();
    });
  }

  changeDay(DateTime d) {
    setState(() {
      widget.timetableState.changeDay(d);
    });
  }

  previousDay() {
    setState(() {
      widget.timetableState.previousDay();
    });
  }

  nextDay() {
    setState(() {
      widget.timetableState.nextDay();
    });
  }

  calendarWeek(DateTime d) {
    changeWeek(Week.fromDate(d));
    changeDay(d);
  }

  @override
  void initState() {
    widget.timetableState.schedule = widget.timetableState.fetchSchedule(widget.timetableState.week);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateBar(
          week: widget.timetableState.week,
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
                                                const HourIndicator(),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10, right: 5),
                                                    child: DaySchedule(
                                                      periods: (snapshot.data
                                                              as List<
                                                                  CourseEntity>)
                                                          .where((element) =>
                                                              element.start
                                                                  .isTheSameDate(
                                                                  widget.timetableState.date))
                                                          .toList()
                                                          .map((c) =>
                                                              CoursePeriod
                                                                  .fromCourse(
                                                                      c))
                                                          .toList(),
                                                      day: widget.timetableState.date,
                                                      quarterSize: 18,
                                                      emptyText: "Aucun cours",
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
                                    future: widget.timetableState.schedule,
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
                    return TimetableLandscapeView(timetableState: widget.timetableState,);
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
  const StudentTimeTable({Key? key, required this.timetableState}) : super(key: key);

  final TimetableState timetableState;

  @override
  State<StudentTimeTable> createState() => _StudentTimeTableState();
}

class _StudentTimeTableState extends State<StudentTimeTable> {
  bool visible = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final choices = {
      "groups": "Voir d'autres emplois du temps",
      "google": "Synchroniser avec Google Calendar"
    };

    if (Platform.name == "android" || Platform.name == "ios" || Platform.name == "macos") {
      choices.putIfAbsent("screenshot", () => "Prendre une capture d'écran");
    }

    return Stack(
      children: [
        PromGrpSelector(
            builder: (_, group) {
              widget.timetableState.group = group != null? Future.value(group): widget.timetableState.group;
              return TimeTable(key: UniqueKey(), timetableState: widget.timetableState);
            },
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
                              (pContext, animation, secondaryAnimation) =>
                                  UiContainer(
                                      backgroundColor: Colors.transparent,
                                      child: UiPopup(
                                          onSubmit: (s) {
                                            switch (s) {
                                              case "groups": {
                                                setState(() {
                                                  visible = !visible;
                                                });
                                                return true;
                                              }
                                              case "google": {
                                                Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                        opaque: false,
                                                        transitionDuration:
                                                        const Duration(
                                                            microseconds: 0),
                                                        reverseTransitionDuration:
                                                        const Duration(
                                                            microseconds: 0),
                                                        pageBuilder: (pContext,
                                                            animation,
                                                            secondaryAnimation) =>
                                                            UiContainer(
                                                                backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                                child: UiIcsPopup(
                                                                    url: Api
                                                                        .instance
                                                                        .scheduleICal
                                                                        .createToken()))));
                                                return false;
                                              }
                                              case "screenshot": {
                                                ScreenshotController sc = ScreenshotController();
                                                Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                        opaque: false,
                                                        transitionDuration:
                                                        const Duration(
                                                            microseconds: 0),
                                                        reverseTransitionDuration:
                                                        const Duration(
                                                            microseconds: 0),
                                                        pageBuilder: (pContext,
                                                            animation,
                                                            secondaryAnimation) =>
                                                            UiContainer(
                                                                backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                                child: UiScreenshotPopup(
                                                                  image: sc.captureFromWidget(
                                                                      Container(
                                                                        color: ThemesHandler
                                                                            .instance
                                                                            .theme
                                                                            .background,
                                                                        child: TimetableLandscapeView(
                                                                            timetableState:
                                                                                widget.timetableState),
                                                                      ),
                                                                      targetSize: const Size(1920, 1080),
                                                                      context: context),
                                                                name: "schedule-${widget.timetableState.week.toString()}",))));
                                              /*.then((image) async {
                                                  await Share.shareXFiles([XFile.fromData(image, mimeType: "image/png")]);
                                                });*/
                                                return false;
                                              }
                                            }
                                            return true;
                                          },
                                          choices: choices))));
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
  const TeacherTimeTable({Key? key, required this.timetableState}) : super(key: key);

  final TimetableState timetableState;

  @override
  Widget build(BuildContext context) {
    return PromGrpSelector(
      builder: (_, group) {
        timetableState.group = group != null? Future.value(group): timetableState.group;
        return TimeTable(key: UniqueKey(), timetableState: timetableState);
      },
      customFetchPromos: () async {
        List<GroupEntity> p = (await Api.instance.groups.get())
            .where((group) =>
                group.private == false && group.tags["type"] == "promo")
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
              .where((g) =>
                  g.private == false &&
                  g.parent?.id == promo.id &&
                  g.tags["type"] == "group")
              .toList();
        }
      },
    );
  }
}
