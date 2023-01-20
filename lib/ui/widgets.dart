import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BoxButton extends StatelessWidget {
  const BoxButton({Key? key, required this.child, required this.onTap})
      : super(key: key);

  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}

class UiButton extends StatelessWidget {
  const UiButton(
      {Key? key,
      required this.onTap,
      required this.height,
      required this.width,
      required this.color,
      required this.child})
      : super(key: key);

  final Function() onTap;
  final double height;
  final double width;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BoxButton(
        onTap: onTap,
        child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: child)));
  }
}

class UiContainer extends StatelessWidget {
  const UiContainer(
      {Key? key, required this.backgroundColor, required this.child})
      : super(key: key);

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      body: SafeArea(child: child),
    );
  }
}

class UiScrollBar extends StatelessWidget {
  const UiScrollBar(
      {Key? key, required this.child, required this.scrollController})
      : super(key: key);

  final ScrollController? scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: scrollController,
        thickness: 4,
        thumbVisibility: true,
        radius: const Radius.circular(10),
        child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false)
                .copyWith(overscroll: false),
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            )));
  }
}

class UiDatePicker extends StatefulWidget {
  const UiDatePicker({
    Key? key,
    this.initialDate,
    required this.onSubmit,
  }) : super(key: key);

  final DateTime? initialDate;
  final Function(DateTime) onSubmit;

  @override
  State<UiDatePicker> createState() => UiDatePickerState();
}

class UiDatePickerState extends State<UiDatePicker> {
  late DateTime date;
  late Widget mask;

  submit() {
    widget.onSubmit(date);
    Navigator.pop(context);
  }

  @override
  void initState() {
    date = widget.initialDate == null ? DateTime.now() : widget.initialDate!;

    mask = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
  }

  Widget dayBox(Widget? child, Color? color, {double radius = 4}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: color,
        ),
        width: 34,
        height: 34,
        child: child);
  }

  List<Widget> getDays() {
    DateTime temp = DateTime(date.year, date.month, 1, 12);
    List<Widget> res = [];

    for (int i = 0; i < 6; i++) {
      List<Widget> row = [];

      if (i == 5 && (temp.weekday != 1 || temp.month != date.month)) {
        break;
      }

      for (int j = 0; j < 7; j++) {
        if (temp.weekday == j + 1 && temp.month == date.month) {
          int year = temp.year;
          int month = temp.month;
          int day = temp.day;
          bool isDate = date.year == temp.year &&
              date.month == temp.month &&
              date.day == temp.day;

          row.add(dayBox(
              BoxButton(
                onTap: () => setState(() {
                  date = DateTime(year, month, day, 12);
                }),
                child: Center(
                    child: Text(
                  temp.day.toString(),
                  style: Styles().f_13.apply(
                      color: isDate
                          ? Colors.white
                          : ThemesHandler.instance.theme.foreground),
                )),
              ),
              isDate
                  ? const Color.fromARGB(255, 38, 96, 170)
                  : ThemesHandler.instance.theme.navIcon,
              radius: isDate ? 10 : 4));
          temp = temp.add(const Duration(days: 1));
        } else {
          row.add(
            dayBox(null, Colors.transparent),
          );
        }
      }
      res.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row,
          )));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mask,
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: EdgeInsets.only(
                    top: max((constraints.maxHeight - 400) / 2, 10)),
                child: Container(
                  decoration: BoxDecoration(
                      color: ThemesHandler.instance.theme.card,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  width: min(400, max(constraints.maxWidth - 20, 0)),
                  child: UiScrollBar(
                    scrollController: null,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                          height: 25,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: BoxButton(
                                onTap: () => Navigator.pop(context),
                                child: SizedBox(
                                    width: 30,
                                    child: Center(
                                      child: SvgPicture.asset(
                                          "assets/svg/cross.svg",
                                          height: 15),
                                    ))),
                          )),
                      SizedBox(
                          height: 40,
                          child: Center(
                              child: Text(
                            "${WeekDay.name(date.weekday)} ${date.day.toString().padLeft(2, "0")} ${Month.name(date.month)}",
                            style: Styles().f_18,
                          ))),
                      SizedBox(
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${Month.name(date.month)} ${date.year}",
                                  style: Styles().f_15,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: BoxButton(
                                          onTap: () => setState(() {
                                                date = DateTime(date.year,
                                                    (date.month - 1));
                                              }),
                                          child: SvgPicture.asset(
                                              "assets/svg/arrow_left.svg",
                                              height: 20)),
                                    ),
                                    SizedBox(
                                      width: 30,
                                      child: BoxButton(
                                          onTap: () => setState(() {
                                                date = DateTime(date.year,
                                                    (date.month + 1));
                                              }),
                                          child: SvgPicture.asset(
                                              "assets/svg/arrow_right.svg",
                                              height: 20)),
                                    )
                                  ],
                                )
                              ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: getDays(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: BoxButton(
                              onTap: submit,
                              child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 38, 96, 170),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    "assets/svg/valid.svg",
                                    height: 20,
                                  ))),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ]);
          },
        )
      ],
    );
  }
}

class TextInput extends StatefulWidget {
  const TextInput(
      {Key? key,
      required this.onChanged,
      required this.icon,
      this.hint = "",
      this.initialValue})
      : super(key: key);

  final Function(String) onChanged;
  final Widget icon;
  final String hint;
  final String? initialValue;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState<T extends TextInput> extends State<T> {
  TextStyle style = Styles().f_15;
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ThemesHandler.instance.theme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          icon,
          const Spacer(
            flex: 1,
          ),
          Expanded(flex: 20, child: child)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        widget.icon,
        TextFormField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: style.apply(
                  color:
                      ThemesHandler.instance.theme.foreground.withAlpha(150))),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
          initialValue: widget.initialValue,
        ));
  }
}

class NumberInput extends StatefulWidget {
  const NumberInput(
      {Key? key, required this.onChanged, required this.icon, this.hint = ""})
      : super(key: key);

  final Function(int?) onChanged;
  final Widget icon;
  final String hint;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState<T extends NumberInput> extends State<T> {
  TextStyle style = Styles().f_15;
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ThemesHandler.instance.theme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          icon,
          const Spacer(
            flex: 1,
          ),
          Expanded(flex: 20, child: child)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        widget.icon,
        TextFormField(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: style.apply(
                  color:
                      ThemesHandler.instance.theme.foreground.withAlpha(150))),
          style: style,
          onChanged: (value) => widget.onChanged(int.tryParse(value.trim())),
        ));
  }
}

class MultilineTextInput extends StatefulWidget {
  const MultilineTextInput(
      {Key? key,
      required this.onChanged,
      required this.icon,
      this.hint = "",
      this.initialValue})
      : super(key: key);

  final Function(String) onChanged;
  final Widget icon;
  final String hint;
  final String? initialValue;

  @override
  State<MultilineTextInput> createState() => _MultilineTextInputState();
}

class _MultilineTextInputState<T extends MultilineTextInput> extends State<T> {
  TextStyle style = Styles().f_15;
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ThemesHandler.instance.theme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          icon,
          const Spacer(
            flex: 1,
          ),
          Expanded(flex: 20, child: child)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        widget.icon,
        TextFormField(
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          cursorColor: cursorColor,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: style.apply(
                  color:
                      ThemesHandler.instance.theme.foreground.withAlpha(150))),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
          initialValue: widget.initialValue,
        ));
  }
}

class DateInput extends StatefulWidget {
  const DateInput(
      {Key? key,
      required this.onChanged,
      required this.icon,
      this.hint = "",
      this.initialDate})
      : super(key: key);

  final Function(DateTime?) onChanged;
  final Widget icon;
  final String hint;
  final DateTime? initialDate;

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState<T extends DateInput> extends State<T> {
  TextStyle style = Styles().f_15;
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);
  bool datePicker = false;
  String? value;
  DateTime? res;
  late final TextEditingController controller;

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ThemesHandler.instance.theme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          icon,
          const Spacer(
            flex: 1,
          ),
          Expanded(flex: 20, child: child)
        ],
      ),
    );
  }

  @override
  void initState() {
    res = widget.initialDate;
    controller = TextEditingController(
        text:
            res == null ? DateTime.now().toDateString() : res!.toDateString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        widget.icon,
        TextFormField(
          keyboardType: TextInputType.datetime,
          readOnly: true,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: style.apply(
                  color:
                      ThemesHandler.instance.theme.foreground.withAlpha(150))),
          style: style,
          controller: controller,
          onChanged: (value) => widget.onChanged(res),
          onTap: (() {
            setState(() {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(microseconds: 0),
                    reverseTransitionDuration: const Duration(microseconds: 0),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        UiContainer(
                            backgroundColor: Colors.transparent,
                            child: UiDatePicker(
                                initialDate: res,
                                onSubmit: (date) {
                                  setState(() {
                                    controller.text = date.toDateString();
                                    res = date;
                                    widget.onChanged(res);
                                  });
                                })),
                  ));
            });
          }),
        ));
  }
}

class DropdownInput<T> extends StatefulWidget {
  const DropdownInput(
      {Key? key,
      required this.onChanged,
      this.icon,
      required this.list,
      required this.itemBuilder,
      this.hint = "",
      this.initialValue})
      : super(key: key);

  final Function(dynamic) onChanged;
  final List<T> list;
  final Widget Function(dynamic) itemBuilder;
  final String hint;
  final Widget? icon;
  final dynamic initialValue;

  @override
  _DropdownInputState<T, DropdownInput> createState() => _DropdownInputState();
}

class _DropdownInputState<V, T extends DropdownInput> extends State<T> {
  TextStyle style = Styles().f_15;
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget? icon, Widget child) {
    List<Widget> list = icon == null
        ? [Expanded(flex: 20, child: child)]
        : [
            icon,
            const Spacer(
              flex: 1,
            ),
            Expanded(flex: 20, child: child)
          ];
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ThemesHandler.instance.theme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: list,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        widget.icon,
        DropdownButtonFormField<V>(
          items: widget.list.map<DropdownMenuItem<V>>((dynamic value) {
            return DropdownMenuItem<V>(
              value: value,
              child: widget.itemBuilder(value),
            );
          }).toList(),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: style),
          style: style,
          elevation: 1,
          borderRadius: BorderRadius.circular(10),
          onChanged: (value) => widget.onChanged(value),
          dropdownColor: ThemesHandler.instance.theme.card,
          value: widget.initialValue,
        ));
  }
}

class DateBar extends StatefulWidget {
  const DateBar(
      {Key? key,
      required this.week,
      required this.onPrevious,
      required this.onNext,
      required this.onCalendarDate})
      : super(key: key);

  final Week week;
  final Function() onPrevious;
  final Function() onNext;
  final Function(DateTime) onCalendarDate;

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        BoxButton(
            onTap: widget.onPrevious,
            child: SizedBox(
                width: 28,
                child:
                    SvgPicture.asset("assets/svg/arrow_left.svg", height: 28))),
        Container(
          width: 180,
          alignment: Alignment.center,
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          UiContainer(
                              backgroundColor: Colors.transparent,
                              child: UiDatePicker(
                                  initialDate: widget.week.begin,
                                  onSubmit: (date) {
                                    setState(() {
                                      widget.onCalendarDate(date);
                                    });
                                  })),
                    ));
              });
            },
            child: Text(
              widget.week.toString(),
              textAlign: TextAlign.center,
              style: Styles().f_24,
            ),
          ),
        ),
        BoxButton(
            onTap: widget.onNext,
            child: SizedBox(
                width: 28,
                child: SvgPicture.asset("assets/svg/arrow_right.svg",
                    height: 28))),
      ]),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UiContainer(
        backgroundColor: Colors.white,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            double iconSize = max(constraints.maxHeight / 6, 80);
            return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/cyrel.svg",
                        height: iconSize,
                      ),
                      Container(
                        height: iconSize / 2,
                      ),
                      SizedBox(
                          width: iconSize * 2,
                          child: const LinearProgressIndicator(
                            backgroundColor: Color.fromRGBO(213, 213, 213, 1.0),
                            color: Color.fromRGBO(55, 110, 187, 1),
                          )),
                    ],
                  ),
                ));
          },
        ));
  }
}

class PromGrpSelector extends StatefulWidget {
  PromGrpSelector({Key? key, required this.builder}) : super(key: key);

  Widget Function(GroupEntity?, GroupEntity?) builder;

  @override
  State<PromGrpSelector> createState() => _PromGrpSelectorState();
}

class _PromGrpSelectorState extends State<PromGrpSelector> {
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
        LayoutBuilder(builder: (context, constraints) {
          List<Widget> fields = [
            FutureBuilder(
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    constraints: BoxConstraints(maxWidth: CyrelOrientation.current == CyrelOrientation.portrait? 400: constraints.maxWidth / 2),
                    child: DropdownInput<GroupEntity>(
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
                    ),
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
                      return Container(
                        constraints: BoxConstraints(maxWidth: CyrelOrientation.current == CyrelOrientation.portrait? 400: constraints.maxWidth / 2 - 40),
                        child: DropdownInput<GroupEntity>(
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
                        ),
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
          ];

          if (CyrelOrientation.current == CyrelOrientation.portrait) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ThemesHandler.instance.theme.card),
              child: Column(
                      children: fields,
                    ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ThemesHandler.instance.theme.card),
              child: Row(
                children: fields,
              ),
            );
          }
        }),
        Expanded(
          child: widget.builder(_promo, _group),
        )
      ],
    );
  }
}
