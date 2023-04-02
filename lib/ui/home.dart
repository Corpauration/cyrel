import 'dart:io';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_alert_entity.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/constants.dart';
import 'package:cyrel/main.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/settings.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:cyrel/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

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
                            !kIsWeb && Platform.isAndroid? BoxButton(
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(7),
                                  child: SizedBox(
                                      height: 21,
                                      child: SvgPicture.asset(
                                        "assets/svg/settings.svg",
                                        height: 21,
                                      ))),
                              onTap: () {
                                setState(() {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(microseconds: 0),
                                        reverseTransitionDuration:
                                        const Duration(microseconds: 0),
                                        pageBuilder:
                                            (context, animation, secondaryAnimation) =>
                                            const SettingsPage(),
                                      ));
                                });
                              },
                            ): const SizedBox(width: 0, height: 0,),
                            const SizedBox(width: 5,),
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
                                final service = FlutterBackgroundService();
                                var isRunning = await service.isRunning();
                                if (isRunning) {
                                  service.invoke("stopService");
                                }
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
            LayoutBuilder(builder: (context, constraints) {
              if (kIsWeb) {
                return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ThemesHandler.instance.theme.card),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Flexible(
                                child: Text(
                              "Cyrel est maintenant disponible pour android !",
                              style: Styles().f_15,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        )),
                        // Expanded(child: Container(color: Colors.transparent,)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: RichText(
                              textAlign: TextAlign.right,
                              softWrap: true,
                              text: TextSpan(
                                  text: "Télécharger",
                                  mouseCursor: SystemMouseCursors.click,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      Uri url = apkUrl;
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                        );
                                      }
                                    },
                                  style:
                                      Styles().f_15.apply(color: Colors.blue))),
                        )
                      ],
                    ));
              }
              else {
                return const SizedBox();
              }
            }),
            const SizedBox(
              height: kIsWeb? 40: 0,
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
                                style: Styles().f_13,
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
                            style: Styles().f_13,
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
                                style: Styles().f_13,
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
            ),
            const SizedBox(
              height: 40,
            ),
            LayoutBuilder(builder: (context, constraints) {
              int count = ((constraints.maxWidth - horizontalMargin - 30) / 250).round();
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

              Api.instance.courseAlert.get(group);

              return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ThemesHandler.instance.theme.card),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Changements dans la semaine :",
                        style: Styles().f_15,
                      ),
                      FutureBuilder<List<CourseAlertEntity>>(
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                              snapshot.data!.sort((a, b) => b.time.compareTo(a.time));
                              List<Widget> widgets =
                                  List.generate(snapshot.data!.length, (index) {
                                    String event;
                                    switch (snapshot.data![index].event) {
                                      case CourseAlertEvent.ADDED:
                                        event = "ajouté";
                                        break;
                                      case CourseAlertEvent.DELETED:
                                        event = "supprimé";
                                        break;
                                      case CourseAlertEvent.MODIFIED:
                                        event = "modifié";
                                        break;
                                    }

                                    return FutureBuilder<CourseEntity>(
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return Container(
                                              constraints: const BoxConstraints(maxHeight: 72),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Cours du ${snapshot.data!.start.toDateString()} $event :",
                                                    style: Styles().f_13,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Flexible(
                                                    child: Container(
                                                      width: 250,
                                                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                      child: CourseWidget(course: snapshot.data!),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        } else {
                                          return Center(
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
                                          );
                                        }
                                      },
                                      future: Api.instance.schedule.get(snapshot.data![index].id),
                                    );
                              });
                              return Container(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                constraints: const BoxConstraints(maxHeight: 260),
                                width: CyrelOrientation.current == CyrelOrientation.portrait? 250: null,
                                child: GridView.count(
                                  childAspectRatio: constraints.maxWidth / 138 / count,
                                  primary: false,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  crossAxisCount: count,
                                  children: widgets,
                                ),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  "Aucun changements",
                                  style: Styles().f_13,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          } else {
                            return Center(
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
                            );
                          }
                        },
                        future: Api.instance.courseAlert.get(group),
                      )
                    ],
                  ));
            }),
            const SizedBox(
              height: 20,
            ),
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
                                    final service = FlutterBackgroundService();
                                    var isRunning = await service.isRunning();
                                    if (isRunning) {
                                      service.invoke("stopService");
                                    }
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
                LayoutBuilder(builder: (context, constraints) {
                  if (kIsWeb) {
                    return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ThemesHandler.instance.theme.card),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          "Cyrel est maintenant disponible pour android !",
                                          style: Styles().f_15,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                )),
                            // Expanded(child: Container(color: Colors.transparent,)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: RichText(
                                  textAlign: TextAlign.right,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: "Télécharger",
                                      mouseCursor: SystemMouseCursors.click,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          Uri url = apkUrl;
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                            );
                                          }
                                        },
                                      style:
                                      Styles().f_15.apply(color: Colors.blue))),
                            )
                          ],
                        ));
                  }
                  else {
                    return const SizedBox();
                  }
                }),
                const SizedBox(
                  height: kIsWeb? 40: 0,
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
                                    style: Styles().f_13,
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
                      Iterable<String> match = professors.where((element) {
                        String r = "${Api.instance.getData<UserEntity>("me").lastname.replaceAll(" ", " *").toUpperCase()} ${Api.instance.getData<UserEntity>("me").firstname.replaceAll(" ", " *").toUpperCase()}";
                        return RegExp(r.replaceAllCapitalizedAccent()).hasMatch(element);
                      });
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
