import 'dart:async';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/week.dart';
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
                      child: Text(homework.title,
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 18))),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(homework.content,
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 13))),
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
        child: Text(dayName,
            style: const TextStyle(fontFamily: "Montserrat", fontSize: 24)));
    List<Widget> list = [title];

    for (var h in homeworks) {
      list.add(HomeWorkCard(color: Colors.white, homework: h));
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
  Completer<List<HomeworkEntity>> future = Completer();

  fetchHomeworks() async {
    List<HomeworkEntity> homeworks = List.empty(growable: true);
    List<GroupEntity> groups =
        Api.instance.getData<List<GroupEntity>>("myGroups");
    DateTime begin = week.begin;
    for (var group in groups) {
      if (!group.private) {
        homeworks.addAll(await Api.instance.homeworks
            .getFromTo(group, week.begin, week.end));
      }
    }
    if (week.begin == begin) {
      if (future.isCompleted) {
        setState(() {
          future = Completer();
        });
      }
      future.complete(homeworks);
    }
  }

  List<Widget> weekListBuilder(List<HomeworkEntity> list) {
    List<Widget> res = [];
    List<List<HomeworkEntity>> homeworks = List.generate(7, (index) => []);

    for (var h in list) {
      if (week.belong(h.date)) {
        homeworks[h.date.weekday == 7 ? 0 : h.date.weekday].add(h);
      }
    }

    for (int i = 0; i < 7; i++) {
      int index = (i + 1) % 7;
      if (homeworks[index].isNotEmpty) {
        res.add(HomeWorkDay(
            dayName: WeekDay.name(index), homeworks: homeworks[index]));
      }
    }

    return res;
  }

  @override
  void initState() {
    fetchHomeworks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = 40;
    ScrollController _scrollController = ScrollController();

    return Container(
      color: const Color.fromRGBO(247, 247, 248, 1),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                BoxButton(
                    child: SizedBox(
                        width: 28,
                        child: SvgPicture.asset("assets/svg/arrow_left.svg",
                            height: 28)),
                    onTap: () => setState(() {
                          week = week.previous();
                          future = Completer();
                          fetchHomeworks();
                        })),
                Container(
                  width: 180,
                  alignment: Alignment.center,
                  child: Text(
                    week.toString(),
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontFamily: "Montserrat", fontSize: 24),
                  ),
                ),
                BoxButton(
                    child: SizedBox(
                        width: 28,
                        child: SvgPicture.asset("assets/svg/arrow_right.svg",
                            height: 28)),
                    onTap: () => setState(() {
                          week = week.next();
                          future = Completer();
                          fetchHomeworks();
                        })),
              ]),
            ),
            Expanded(
              child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: UiScrollBar(
                            scrollController: _scrollController,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  children: weekListBuilder(
                                      snapshot.data as List<HomeworkEntity>)),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 38, 96, 170),
                        backgroundColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
                future: future.future,
              ),
            )
          ])),
    );
  }
}
