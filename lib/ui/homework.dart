import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeWorkCard extends StatelessWidget {
  const HomeWorkCard(
      {Key? key, required this.color, required this.homework, this.onLongPress})
      : super(key: key);

  final Color color;
  final HomeworkEntity homework;
  final Function(HomeworkEntity)? onLongPress;

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

    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress!(homework);
        }
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color,
                  border:
                      Border(bottom: BorderSide(color: typeColor, width: 6))),
              child: Row(children: [
                Expanded(
                  child: Column(children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(homework.title,
                            style: Styles().f_18)),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(homework.content,
                            style: Styles().f_13)),
                  ]),
                ),
              ]),
            ),
          )),
    );
  }
}

class HomeWorkDay extends StatelessWidget {
  const HomeWorkDay({Key? key, required this.dayName, required this.homeworks, this.groups})
      : super(key: key);

  final String dayName;
  final List<HomeworkEntity> homeworks;
  final List<GroupEntity>? groups;

  @override
  Widget build(BuildContext context) {
    Widget title = Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 20),
        child: Text(dayName, style: Styles().f_24));
    List<Widget> list = [title];
    bool canModify =
        !Api.instance.isOffline && (Api.instance.getData<bool>("homework") || Api.instance.getData<UserEntity>("me").type == UserType.professor);

    for (var h in homeworks) {
      list.add(HomeWorkCard(
        color: ThemesHandler.instance.theme.card,
        homework: h,
        onLongPress: canModify
            ? (hw) {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(microseconds: 0),
                      reverseTransitionDuration:
                          const Duration(microseconds: 0),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeworkEditingPage(
                        homework: hw,
                        onChanged: () {},
                        groups: groups,
                      ),
                    ));
              }
            : null,
      ));
    }

    return Container(
        margin: const EdgeInsets.all(10), child: Column(children: list));
  }
}

class HomeWork extends StatefulWidget {
  const HomeWork({Key? key, this.groups}) : super(key: key);

  final List<GroupEntity>? groups;

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
        widget.groups ?? Api.instance.getData<List<GroupEntity>>("myGroups");

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
            HomeWorkDay(dayName: WeekDay.name(i + 1), homeworks: homeworks[i], groups: widget.groups,));
      }
    }

    if (res.isEmpty) {
      res.add(Text(
        "Aucun devoir",
        style: Styles().f_18,
      ));
    }

    res.add(const SizedBox(
      height: 50,
    ));

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
        if (!Api.instance.isOffline && (Api.instance.getData<bool>("homework") || Api.instance.getData<UserEntity>("me").type == UserType.professor)) {
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
                            groups: widget.groups,
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

class HomeworkTeacher extends StatefulWidget {
  const HomeworkTeacher({Key? key}) : super(key: key);

  @override
  State<HomeworkTeacher> createState() => _HomeworkTeacherState();
}

class _HomeworkTeacherState extends State<HomeworkTeacher> {
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

  @override
  void initState() {
    _promos = fetchPromos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                            setState(() => _group = group);
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
          child: Builder(builder: (context) {
            if (_promo != null && _group != null) {
              return HomeWork(
                key: UniqueKey(),
                groups: [_promo!, _group!],
              );
            } else {
              return const SizedBox(
                width: 0,
                height: 0,
              );
            }
          }),
        )
      ],
    );
  }
}

class HomeworkCreatingPage extends StatefulWidget {
  const HomeworkCreatingPage({Key? key, required this.onCreated, this.groups})
      : super(key: key);

  final Function() onCreated;
  final List<GroupEntity>? groups;

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
                                list: widget.groups ??
                                    Api.instance
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

class HomeworkEditingPage extends StatefulWidget {
  const HomeworkEditingPage(
      {Key? key, required this.homework, required this.onChanged, this.groups})
      : super(key: key);

  final HomeworkEntity homework;
  final Function() onChanged;
  final List<GroupEntity>? groups;

  @override
  State<HomeworkEditingPage> createState() => _HomeworkEditingPageState();
}

class _HomeworkEditingPageState extends State<HomeworkEditingPage> {
  final sc = ScrollController();
  late String _title;
  late String _content;
  late DateTime _date;
  late HomeworkType _type;
  late GroupEntity _group;
  bool loading = false;

  _updateHomework() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      await Api.instance.homework.update(HomeworkEntity(
          id: widget.homework.id,
          title: _title,
          content: _content,
          date: _date,
          type: _type,
          group: _group));
      Navigator.of(context).pop();
      widget.onChanged();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Impossible de modifier le devoir",
        style: Styles.f_13nt,
      )));
    }
    setState(() {
      loading = false;
    });
  }

  _deleteHomework() async {
    if (loading) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
        "Voulez-vous supprimer le devoir ?",
        style: Styles.f_13nt,
      ),
      action: SnackBarAction(
          label: "OUI",
          onPressed: () async {
            if (loading) {
              return;
            }
            setState(() {
              loading = true;
            });
            try {
              await Api.instance.homework.delete(widget.homework);
              Navigator.of(context).pop();
              widget.onChanged();
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                "Impossible de supprimer le devoir",
                style: Styles.f_13nt,
              )));
            }
            setState(() {
              loading = false;
            });
          }),
    ));
  }

  @override
  void initState() {
    _title = widget.homework.title;
    _content = widget.homework.content;
    _date = widget.homework.date;
    _type = widget.homework.type;
    _group = widget.homework.group;
    super.initState();
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
                      "Modifier un devoir",
                      textAlign: TextAlign.center,
                      style: Styles().f_24,
                    ),
                  ),
                  BoxButton(
                      onTap: _deleteHomework,
                      child: SizedBox(
                          width: 28,
                          child: SvgPicture.asset("assets/svg/remove.svg",
                              height: 20))),
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
                              initialValue: _title,
                            ),
                            MultilineTextInput(
                              onChanged: (content) {
                                _content = content;
                              },
                              icon: SvgPicture.asset(
                                "assets/svg/homework_content.svg",
                                height: 25,
                              ),
                              hint: "Contenu du devoir",
                              initialValue: _content,
                            ),
                            DateInput(
                              onChanged: (date) {
                                _date = date!;
                              },
                              icon: SvgPicture.asset(
                                "assets/svg/calendar.svg",
                                height: 25,
                              ),
                              hint: "Date du devoir",
                              initialDate: _date,
                            ),
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
                              initialValue: _type,
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
                              list: widget.groups ??
                                  Api.instance
                                      .getData<List<GroupEntity>>("myGroups")
                                      .where((element) => !element.private)
                                      .toList(),
                              initialValue: _group,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: BoxButton(
                                  onTap: _updateHomework,
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
