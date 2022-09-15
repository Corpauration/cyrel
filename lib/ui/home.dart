import 'dart:math';

import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
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
                                      HotRestartController.performHotRestart(context);
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
                              onTap: () {},
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

                Widget nextDayCourses = toCard(Column(children: [
                  courseDisplay(
                      "Demain, vous commencez par :",
                      CourseEntity(
                          category: CourseCategory.DEFAULT,
                          start: DateTime.now(),
                          id: "dd",
                          rooms: [],
                          teachers: [],
                          subject: "dd",
                          end: null)),
                  courseDisplay(
                      "Et vous finissez par :",
                      CourseEntity(
                          category: CourseCategory.DEFAULT,
                          start: DateTime.now(),
                          id: "dd",
                          rooms: [],
                          teachers: [],
                          subject: "dd",
                          end: null)),
                ]));

                Widget nextCourse = toCard(Column(
                  children: [
                    courseDisplay(
                        "Prochain cours :",
                        CourseEntity(
                            category: CourseCategory.DEFAULT,
                            start: DateTime.now(),
                            id: "dd",
                            rooms: [],
                            teachers: [],
                            subject: "dd",
                            end: null)),
                  ],
                ));

                Widget homeworkView = toCard(Column(children: [
                  homeworkDisplay("Devoirs pour aujourd'hui :", []),
                  homeworkDisplay("Devoirs pour demain :", [
                    HomeworkEntity(
                        title: "dd",
                        content: "dd",
                        date: DateTime.now(),
                        type: HomeworkType.ds,
                        group: GroupEntity(3, "dd", null, null, false))
                  ])
                ]));

                List<Widget> view = [
                  nextCourse,
                  const SizedBox(
                    height: 40,
                    width: 0,
                  ),
                  homeworkView
                ];

                if (constraints.maxWidth > 550) {
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
