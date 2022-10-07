import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeWorkCard extends StatelessWidget {
  const HomeWorkCard({Key? key, required this.color, required this.homework})
      : super(key: key);

  final Color color;
  final HomeworkEntity homework;

  @override
  Widget build(BuildContext context) {
    Color typeColor;

    switch (homework.type) {
      case HomeworkType.exo:
        typeColor = const Color.fromARGB(255, 38, 96, 170);
        break;
      case HomeworkType.dm:
        typeColor = const Color.fromARGB(255, 38, 170, 96);
        break;
      case HomeworkType.ds:
        typeColor = const Color.fromARGB(255, 196, 38, 38);
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color,
                border: Border(bottom: BorderSide(color: typeColor, width: 6))),
            child: Row(children: [
              Expanded(
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(homework.title, style: Styles().f_18)),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(homework.content, style: Styles().f_13)),
                ]),
              ),
            ]),
          ),
        ));
  }
}

class HomeWorkDay extends StatelessWidget {
  const HomeWorkDay({Key? key, required this.dayName, required this.homeworks})
      : super(key: key);

  final String dayName;
  final List<HomeworkEntity> homeworks;

  @override
  Widget build(BuildContext context) {
    Widget title = Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 20),
        child: Text(dayName, style: Styles().f_24));
    List<Widget> list = [title];

    for (var h in homeworks) {
      list.add(
          HomeWorkCard(color: ThemesHandler.instance.theme.card, homework: h));
    }

    return Container(
        margin: const EdgeInsets.all(10), child: Column(children: list));
  }
}

class HomeWork extends StatefulWidget {
  const HomeWork({Key? key}) : super(key: key);

  @override
  State<HomeWork> createState() => _HomeWorkState();
}

class _HomeWorkState extends State<HomeWork> {
  Week week = Week();
  late Future<List<HomeworkEntity>> _homeworks;
  final sc = ScrollController();

  Future<List<HomeworkEntity>> fetchHomeworks(Week w) async {
    List<HomeworkEntity> homeworks = List.empty(growable: true);
    List<GroupEntity> groups =
        Api.instance.getData<List<GroupEntity>>("myGroups");

    for (var group in groups) {
      if (!group.private) {
        homeworks.addAll(
            await Api.instance.homeworks.getFromTo(group, w.begin, w.end));
      }
    }

    return homeworks;
  }

  List<Widget> weekListBuilder(List<HomeworkEntity> list) {
    List<Widget> res = [];
    List<List<HomeworkEntity>> homeworks = List.generate(7, (index) => []);

    for (var h in list) {
      if (week.belong(h.date)) {
        homeworks[h.date.weekday - 1].add(h);
      }
    }

    for (int i = 0; i < 7; i++) {
      if (homeworks[i].isNotEmpty) {
        res.add(
            HomeWorkDay(dayName: WeekDay.name(i + 1), homeworks: homeworks[i]));
      }
    }

    if (res.isEmpty) {
      res.add(Text(
        "Aucun devoir",
        style: Styles().f_18,
      ));
    }

    res.add(const SizedBox(height: 50,));

    return res;
  }

  changeWeek(Week w) {
    setState(() {
      week = w;
      _homeworks = fetchHomeworks(week);
    });
  }

  previousWeek() {
    changeWeek(week.previous());
  }

  nextWeek() {
    changeWeek(week.next());
  }

  calendarWeek(DateTime date) {
    changeWeek(Week.fromDate(date));
  }

  @override
  void initState() {
    _homeworks = fetchHomeworks(week);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    return Stack(children: [
      LayoutBuilder(
        builder: (context, constraints) {
          double horizontalMargin =
              constraints.maxHeight > (screenRatio * constraints.maxWidth)
                  ? max(5, constraints.maxWidth / 48)
                  : max(20, constraints.maxWidth / 12);

          return Container(
              color: ThemesHandler.instance.theme.background,
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Stack(children: [
                Column(children: [
                  DateBar(
                      week: week,
                      onPrevious: previousWeek,
                      onNext: nextWeek,
                      onCalendarDate: calendarWeek),
                  Expanded(
                    child: FutureBuilder(
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: UiScrollBar(
                                scrollController: sc,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                      children: weekListBuilder(snapshot.data
                                          as List<HomeworkEntity>)),
                                ),
                              ),
                            );
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
                        future: _homeworks),
                  ),
                ]),
                Row(
                  children: [
                    Flexible(
                        flex: 3,
                        child: GestureDetector(onDoubleTap: previousWeek)),
                    const Spacer(flex: 2),
                    Flexible(
                        flex: 3,
                        child: GestureDetector(onDoubleTap: () => nextWeek()))
                  ],
                ),
              ]));
        },
      ),
      Builder(builder: (ctx) {
        if (!Api.instance.isOffline && Api.instance.getData<bool>("homework")) {
          return Positioned(
            bottom: 20,
            right: 20,
            child: BoxButton(
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
                                  HomeworkCreatingPage(
                            onCreated: () {
                              changeWeek(week);
                            },
                          ),
                        ));
                  });
                },
                child: Container(
                    width: 40,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 38, 96, 170),
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/svg/plus.svg",
                      height: 20,
                    ))),
          );
        } else {
          return Container(
            width: 0,
            height: 0,
            color: Colors.transparent,
          );
        }
      })
    ]);
  }
}

class HomeworkCreatingPage extends StatefulWidget {
  const HomeworkCreatingPage({Key? key, required this.onCreated})
      : super(key: key);

  final Function() onCreated;

  @override
  State<HomeworkCreatingPage> createState() => _HomeworkCreatingPageState();
}

class _HomeworkCreatingPageState extends State<HomeworkCreatingPage> {
  final sc = ScrollController();
  String? _title;
  String? _content;
  DateTime _date = DateTime.now();
  HomeworkType? _type;
  GroupEntity? _group;
  bool loading = false;

  _sendHomework() async {
    if (loading) {
      return;
    }
    if (_title == null || _content == null || _type == null || _group == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Formulaire incorrecte",
        style: Styles.f_13nt,
      )));
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      await Api.instance.homework.createHomework(HomeworkEntity(
          title: _title!,
          content: _content!,
          date: _date,
          type: _type!,
          group: _group!));
      Navigator.of(context).pop();
      widget.onCreated();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Impossible de créer le devoir",
        style: Styles.f_13nt,
      )));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;
    return UiContainer(
        backgroundColor: ThemesHandler.instance.theme.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalMargin =
                constraints.maxHeight > (screenRatio * constraints.maxWidth)
                    ? max(5, constraints.maxWidth / 48)
                    : max(20, constraints.maxWidth / 12);
            double titleWidth = max(constraints.maxWidth - 4 * 28, 1);

            return Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  BoxButton(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                          width: 28,
                          child: SvgPicture.asset("assets/svg/cross.svg",
                              height: 20))),
                  Container(
                    width: titleWidth,
                    alignment: Alignment.center,
                    child: Text(
                      "Créer un devoir",
                      textAlign: TextAlign.center,
                      style: Styles().f_24,
                    ),
                  ),
                ]),
              ),
              Flexible(
                child: Container(
                    margin: EdgeInsets.fromLTRB(
                        horizontalMargin, 10, horizontalMargin, 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ThemesHandler.instance.theme.card),
                    child: UiScrollBar(
                      scrollController: sc,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextInput(
                              onChanged: (title) {
                                _title = title;
                              },
                              icon: SvgPicture.asset(
                                "assets/svg/homework_title.svg",
                                height: 25,
                              ),
                              hint: "Titre du devoir",
                            ),
                            MultilineTextInput(
                                onChanged: (content) {
                                  _content = content;
                                },
                                icon: SvgPicture.asset(
                                  "assets/svg/homework_content.svg",
                                  height: 25,
                                ),
                                hint: "Contenu du devoir"),
                            DateInput(
                                onChanged: (date) {
                                  _date = date!;
                                },
                                icon: SvgPicture.asset(
                                  "assets/svg/calendar.svg",
                                  height: 25,
                                ),
                                hint: "Date du devoir"),
                            DropdownInput<HomeworkType>(
                              onChanged: (type) {
                                _type = type;
                              },
                              icon: SvgPicture.asset(
                                "assets/svg/homework_type.svg",
                                height: 25,
                              ),
                              hint: "Type du devoir",
                              itemBuilder: (item) => Text(
                                (item as HomeworkType).name,
                                style: Styles().f_15.apply(
                                    color: ThemesHandler
                                        .instance.theme.foreground),
                              ),
                              list: HomeworkType.values,
                            ),
                            DropdownInput<GroupEntity>(
                                onChanged: (group) {
                                  _group = group;
                                },
                                icon: SvgPicture.asset(
                                  "assets/svg/group.svg",
                                  height: 20,
                                ),
                                hint: "Groupe",
                                itemBuilder: (item) => Text(
                                  item.name,
                                  style: Styles().f_15.apply(
                                          color: ThemesHandler
                                              .instance.theme.foreground),
                                    ),
                                list: Api.instance
                                    .getData<List<GroupEntity>>("myGroups")
                                    .where((element) => !element.private)
                                    .toList()),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: BoxButton(
                                  onTap: _sendHomework,
                                  child: Container(
                                      width: 48,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 38, 96, 170),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.all(10),
                                      child: loading
                                          ? const SizedBox(
                                              height: 28,
                                              child: CircularProgressIndicator(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 38, 96, 170),
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : SvgPicture.asset(
                                              "assets/svg/valid.svg",
                                              height: 28,
                                            ))),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ]);
          },
        ));
  }
}
