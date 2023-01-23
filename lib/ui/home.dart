import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/main.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    Api.instance.onAuthExpired = () {
      HotRestartController.performHotRestart(context);
    };

    return LayoutBuilder(builder: (context, constraints) {
      double horizontalMargin =
          constraints.maxHeight > (screenRatio * constraints.maxWidth)
              ? max(5, constraints.maxWidth / 48)
              : max(20, constraints.maxWidth / 12);

      return Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: UiScrollBar(
          scrollController: ScrollController(initialScrollOffset: 0),
          child: Column(children: [
            SizedBox(height: (1 / 24) * constraints.maxHeight),
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      decoration: BoxDecoration(
                          color: ThemesHandler.instance.theme.card,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 5),
                            BoxButton(
                                child: Container(
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.all(7),
                                    child: SizedBox(
                                        height: 21,
                                        child: SvgPicture.asset(
                                          "assets/svg/theme.svg",
                                          height: 21,
                                        ))),
                                onTap: () {
                                  ThemesHandler.instance.toggleTheme();
                                  HotRestartController.performHotRestart(
                                      context);
                                }),
                            const SizedBox(width: 5),
                            BoxButton(
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(7),
                                  child: SizedBox(
                                      height: 21,
                                      child: SvgPicture.asset(
                                        "assets/svg/logout.svg",
                                        height: 21,
                                      ))),
                              onTap: () async {
                                await Api.instance.logout();
                                ThemesHandler.instance.cursor = 0;
                                HotRestartController.performHotRestart(context);
                              },
                            ),
                            const SizedBox(width: 5),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                Widget toCard(Widget child) {
                  return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ThemesHandler.instance.theme.card),
                      child: child);
                }

                Widget widgetDisplay(String text, Widget child) {
                  return Column(
                    children: [
                      Text(
                        text,
                        style: Styles().f_15,
                      ),
                      Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: child,
                      ),
                    ],
                  );
                }

                Widget courseDisplay(String text, CourseEntity course) {
                  return widgetDisplay(text, CourseWidget(course: course));
                }

                Widget futureCourseDisplay(
                    String text, Future<CourseEntity> future) {
                  return FutureBuilder<CourseEntity>(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return courseDisplay(text, snapshot.data!);
                        } else {
                          return widgetDisplay(
                              text,
                              Text(
                                "Aucun cours",
                                style: Styles().f_15,
                                textAlign: TextAlign.center,
                              ));
                        }
                      } else {
                        return widgetDisplay(
                            text,
                            Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(255, 38, 96, 170),
                                  backgroundColor:
                                      ThemesHandler.instance.theme.card,
                                  strokeWidth: 2,
                                ),
                              ),
                            ));
                      }
                    },
                    future: future,
                  );
                }

                Widget homeworkDisplay(
                    String text, List<HomeworkEntity> homeworks) {
                  return homeworks.isEmpty
                      ? widgetDisplay(
                          text,
                          Text(
                            "Aucun devoirs",
                            style: Styles().f_15,
                            textAlign: TextAlign.center,
                          ))
                      : widgetDisplay(
                          text,
                          Column(
                            children: homeworks
                                .map((h) => HomeWorkCard(
                                      homework: h,
                                      color: ThemesHandler
                                          .instance.theme.background,
                                    ))
                                .toList(),
                          ));
                }

                Widget futureHomeworkDisplay(
                    String text, Future<List<HomeworkEntity>> future) {
                  return FutureBuilder<List<HomeworkEntity>>(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return homeworkDisplay(text, snapshot.data!);
                        } else {
                          return widgetDisplay(
                              text,
                              Text(
                                "Aucun devoirs",
                                style: Styles().f_15,
                                textAlign: TextAlign.center,
                              ));
                        }
                      } else {
                        return widgetDisplay(
                            text,
                            Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(255, 38, 96, 170),
                                  backgroundColor:
                                      ThemesHandler.instance.theme.card,
                                  strokeWidth: 2,
                                ),
                              ),
                            ));
                      }
                    },
                    future: future,
                  );
                }

                Future<List<HomeworkEntity>> fetchHomeworks(
                    DateTime date) async {
                  List<HomeworkEntity> homeworks = List.empty(growable: true);
                  List<GroupEntity> groups =
                      Api.instance.getData<List<GroupEntity>>("myGroups");

                  for (var group in groups) {
                    if (!group.private) {
                      homeworks.addAll(await Api.instance.homeworks
                          .getFromTo(group, date, date));
                    }
                  }

                  return homeworks;
                }

                GroupEntity group;
                try {
                  group = Api.instance
                      .getData<List<GroupEntity>>("myGroups")
                      .where((element) => element.referent != null)
                      .first;
                } catch (e) {
                  group =
                      Api.instance.getData<List<GroupEntity>>("myGroups").first;
                }

                DateTime now = DateTime.now();
                DateTime nowMidnight = DateTime(now.year, now.month, now.day);

                Future<List<CourseEntity>> nextDCourses = Api.instance.schedule
                    .getFromTo(group, nowMidnight,
                        nowMidnight.add(const Duration(days: 2)));
                Widget nextDayCourses = toCard(Column(children: [
                  futureCourseDisplay("Demain, vous commencez par :",
                      nextDCourses.then((list) {
                    List<CourseEntity> filtered = list
                        .where((element) => nowMidnight
                            .add(const Duration(days: 1))
                            .isBefore(element.start))
                        .toList();
                    filtered.sort((a, b) => a.start.compareTo(b.start));
                    return filtered.first;
                  })),
                  futureCourseDisplay("Et vous finissez par :",
                      nextDCourses.then((list) {
                    List<CourseEntity> filtered = list
                        .where((element) => nowMidnight
                            .add(const Duration(days: 1))
                            .isBefore(element.start))
                        .toList();
                    filtered.sort((a, b) => a.start.compareTo(b.start));
                    return filtered.last;
                  })),
                ]));

                Future<List<CourseEntity>> nextCourses = Api.instance.schedule
                    .getFromTo(
                        group,
                        nowMidnight.subtract(const Duration(days: 1)),
                        nowMidnight.add(const Duration(days: 1)));
                Widget nextCourse = toCard(Column(
                  children: [
                    futureCourseDisplay("Cours en cours :",
                        nextCourses.then((list) {
                      List<CourseEntity> filtered = list
                          .where((e) =>
                              (e.end == null || now.isBefore(e.end!)) &&
                              now.isAfter(e.start))
                          .toList();
                      filtered.sort((a, b) => a.start.compareTo(b.start));
                      return filtered.last;
                    })),
                    futureCourseDisplay("Prochain cours :",
                        nextCourses.then((list) {
                      List<CourseEntity> filtered =
                          list.where((e) => now.isBefore(e.start)).toList();
                      filtered.sort((a, b) => a.start.compareTo(b.start));
                      return filtered.first;
                    })),
                  ],
                ));

                Widget homeworkView = toCard(Column(children: [
                  futureHomeworkDisplay(
                      "Devoirs pour aujourd'hui :", fetchHomeworks(now)),
                  futureHomeworkDisplay("Devoirs pour demain :",
                      fetchHomeworks(now.add(const Duration(days: 1))))
                ]));

                List<Widget> view = [
                  nextCourse,
                  const SizedBox(
                    height: 40,
                    width: 0,
                  ),
                  homeworkView,
                  const SizedBox(
                    height: 40,
                    width: 0,
                  ),
                  nextDayCourses
                ];

                if (constraints.maxWidth > 825) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: view,
                  );
                } else {
                  return Column(
                    children: view,
                  );
                }
              },
            )
          ]),
        ),
      );
    });
  }
}

class TeacherHome extends StatefulWidget {
  const TeacherHome({Key? key}) : super(key: key);

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    Api.instance.onAuthExpired = () {
      HotRestartController.performHotRestart(context);
    };

    return LayoutBuilder(builder: (context, constraints) {
      double horizontalMargin =
          constraints.maxHeight > (screenRatio * constraints.maxWidth)
              ? max(5, constraints.maxWidth / 48)
              : max(20, constraints.maxWidth / 12);

      return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: UiScrollBar(
              scrollController: ScrollController(initialScrollOffset: 0),
              child: Column(children: [
                SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          decoration: BoxDecoration(
                              color: ThemesHandler.instance.theme.card,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(width: 5),
                                BoxButton(
                                    child: Container(
                                        height: 35,
                                        width: 35,
                                        padding: const EdgeInsets.all(7),
                                        child: SizedBox(
                                            height: 21,
                                            child: SvgPicture.asset(
                                              "assets/svg/theme.svg",
                                              height: 21,
                                            ))),
                                    onTap: () {
                                      ThemesHandler.instance.toggleTheme();
                                      HotRestartController.performHotRestart(
                                          context);
                                    }),
                                const SizedBox(width: 5),
                                BoxButton(
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      padding: const EdgeInsets.all(7),
                                      child: SizedBox(
                                          height: 21,
                                          child: SvgPicture.asset(
                                            "assets/svg/logout.svg",
                                            height: 21,
                                          ))),
                                  onTap: () async {
                                    await Api.instance.logout();
                                    ThemesHandler.instance.cursor = 0;
                                    HotRestartController.performHotRestart(
                                        context);
                                  },
                                ),
                                const SizedBox(width: 5),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    Widget toCard(Widget child) {
                      return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ThemesHandler.instance.theme.card),
                          child: child);
                    }

                    Widget widgetDisplay(String text, Widget child) {
                      return Column(
                        children: [
                          Text(
                            text,
                            style: Styles().f_15,
                          ),
                          Container(
                            width: 250,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: child,
                          ),
                        ],
                      );
                    }

                    Widget courseDisplay(String text, CourseEntity course) {
                      return widgetDisplay(text, CourseWidget(course: course));
                    }

                    Widget futureCourseDisplay(
                        String text, Future<CourseEntity> future) {
                      return FutureBuilder<CourseEntity>(
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return courseDisplay(text, snapshot.data!);
                            } else {
                              return widgetDisplay(
                                  text,
                                  Text(
                                    "Aucun cours",
                                    style: Styles().f_15,
                                    textAlign: TextAlign.center,
                                  ));
                            }
                          } else {
                            return widgetDisplay(
                                text,
                                Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: const Color.fromARGB(255, 38, 96, 170),
                                      backgroundColor:
                                      ThemesHandler.instance.theme.card,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ));
                          }
                        },
                        future: future,
                      );
                    }



                    Future<String> professor = Future.microtask(() async {
                      List<String> professors = await Api.instance.schedule.getScheduleProfessors();
                      Iterable<String> match = professors.where((element) => element == "${Api.instance.getData<UserEntity>("me").lastname.toUpperCase()} ${Api.instance.getData<UserEntity>("me").firstname.toUpperCase()}");
                      if (match.isNotEmpty) {
                        return match.first;
                      }
                      return "";
                    });

                    DateTime now = DateTime.now();
                    DateTime nowMidnight = DateTime(now.year, now.month, now.day);

                    Future<List<CourseEntity>> nextDCourses = professor.then((p) => Api.instance.schedule
                        .getProfessorScheduleFromTo(p, nowMidnight,
                        nowMidnight.add(const Duration(days: 2))));
                    Widget nextDayCourses = toCard(Column(children: [
                      futureCourseDisplay("Demain, vous commencez par :",
                          nextDCourses.then((list) {
                            List<CourseEntity> filtered = list
                                .where((element) => nowMidnight
                                .add(const Duration(days: 1))
                                .isBefore(element.start))
                                .toList();
                            filtered.sort((a, b) => a.start.compareTo(b.start));
                            return filtered.first;
                          })),
                      futureCourseDisplay("Et vous finissez par :",
                          nextDCourses.then((list) {
                            List<CourseEntity> filtered = list
                                .where((element) => nowMidnight
                                .add(const Duration(days: 1))
                                .isBefore(element.start))
                                .toList();
                            filtered.sort((a, b) => a.start.compareTo(b.start));
                            return filtered.last;
                          })),
                    ]));

                    Future<List<CourseEntity>> nextCourses = professor.then((p) => Api.instance.schedule
                        .getProfessorScheduleFromTo(
                        p,
                        nowMidnight.subtract(const Duration(days: 1)),
                        nowMidnight.add(const Duration(days: 1))));
                    Widget nextCourse = toCard(Column(
                      children: [
                        futureCourseDisplay("Cours en cours :",
                            nextCourses.then((list) {
                              List<CourseEntity> filtered = list
                                  .where((e) =>
                              (e.end == null || now.isBefore(e.end!)) &&
                                  now.isAfter(e.start))
                                  .toList();
                              filtered.sort((a, b) => a.start.compareTo(b.start));
                              return filtered.last;
                            })),
                        futureCourseDisplay("Prochain cours :",
                            nextCourses.then((list) {
                              List<CourseEntity> filtered =
                              list.where((e) => now.isBefore(e.start)).toList();
                              filtered.sort((a, b) => a.start.compareTo(b.start));
                              return filtered.first;
                            })),
                      ],
                    ));

                    List<Widget> view = [
                      nextCourse,
                      const SizedBox(
                        height: 40,
                        width: 0,
                      ),
                      nextDayCourses
                    ];

                    if (constraints.maxWidth > 825) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: view,
                      );
                    } else {
                      return Column(
                        children: view,
                      );
                    }
                  },
                )
              ])));
    });
  }
}
