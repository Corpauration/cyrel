import 'dart:math';

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

    for (int j = 0; j < 6; j++) {
      List<Widget> row = [];

      if (j == 5 && temp.weekday != 1) {
        break;
      }

      for (int i = 0; i < 7; i++) {
        if (temp.weekday == i + 1 && temp.month == date.month) {
          int year = temp.year.toInt();
          int month = temp.month.toInt();
          int day = temp.day.toInt();
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
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      color: isDate ? Colors.white : Colors.black),
                )),
              ),
              isDate
                  ? const Color.fromARGB(255, 38, 96, 170)
                  : Colors.grey[100], radius: isDate ? 10 : 4));
          temp = temp.add(const Duration(days: 1));
        } else {
          row.add(dayBox(null, Colors.transparent),);
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
                margin: EdgeInsets.only(top: max((constraints.maxHeight-350)/2,10)),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  width: min(400, max(constraints.maxWidth-20, 0)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(height: 30, child: Row()), // TODO add cross onSubmit triger with svg asset and Boxbutton
                    SizedBox(
                        height: 40,
                        child: Center(
                            child: Text(
                          "${WeekDay.name(date.weekday)} ${date.day.toString().padLeft(2, "0")} ${Month.name(date.month)}",
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 18),
                        ))),
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${Month.name(date.month)} ${date.year}", style: const TextStyle(fontFamily: "Montserrat", fontSize: 15),),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: BoxButton(
                                        onTap: () =>
                                          setState(() {
                                            date = DateTime(date.year,
                                                (date.month-1));
                                          })
                                        ,
                                        child: SvgPicture.asset(
                                            "assets/svg/arrow_left.svg",
                                            height: 20)),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: BoxButton(
                                        onTap: () => setState(() {
                                            date = DateTime(date.year,
                                                (date.month+1));
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
                    )
                  ]),
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
  const TextInput({Key? key, required this.onChanged, required this.iconPath, this.hint = ""}) : super(key: key);

  final Function(String) onChanged;
  final String iconPath;
  final String hint;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState<T extends TextInput> extends State<T> {
  TextStyle style = const TextStyle(fontFamily: "Montserrat", fontSize: 16);
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 248, 1),
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
        SvgPicture.asset(
          widget.iconPath,
          height: 25,
        ),
        TextFormField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
          ),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
        ));
  }
}

class MultilineTextInput extends StatefulWidget {
  const MultilineTextInput({Key? key, required this.onChanged, required this.iconPath, this.hint = ""}) : super(key: key);

  final Function(String) onChanged;
  final String iconPath;
  final String hint;

  @override
  State<MultilineTextInput> createState() => _MultilineTextInputState();
}

class _MultilineTextInputState<T extends MultilineTextInput> extends State<T> {
  TextStyle style = const TextStyle(fontFamily: "Montserrat", fontSize: 16);
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 248, 1),
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
        SvgPicture.asset(
          widget.iconPath,
          height: 25,
        ),
        TextFormField(
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          cursorColor: cursorColor,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
          ),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
        ));
  }
}

class DateInput extends StatefulWidget {
  const DateInput({Key? key, required this.onChanged, required this.iconPath, this.hint = ""}) : super(key: key);

  final Function(String) onChanged;
  final String iconPath;
  final String hint;

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState<T extends DateInput> extends State<T> {
  TextStyle style = const TextStyle(fontFamily: "Montserrat", fontSize: 16);
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);
  bool datePicker = false;

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 248, 1),
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
        SvgPicture.asset(
          widget.iconPath,
          height: 25,
        ),
        TextFormField(
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
          ),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
          onTap: (() {
            setState(() {
              datePicker = true;
            });
          }),
        ));
  }
}

class DropdownInput<T> extends StatefulWidget {
  const DropdownInput({Key? key, required this.onChanged, required this.iconPath, required this.list, required this.itemBuilder, this.hint = ""}) : super(key: key);

  final Function(dynamic) onChanged;
  final List<T> list;
  final Widget Function(dynamic) itemBuilder;
  final String hint;
  final String iconPath;

  @override
  _DropdownInputState<T, DropdownInput> createState() => _DropdownInputState();
}

class _DropdownInputState<V, T extends DropdownInput> extends State<T> {
  TextStyle style = const TextStyle(fontFamily: "Montserrat", fontSize: 16);
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 248, 1),
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
        SvgPicture.asset(
          widget.iconPath,
          height: 25,
        ),
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
          ),
          style: style,
          elevation: 1,
          borderRadius: BorderRadius.circular(10),
          onChanged: (value) => widget.onChanged(value),
        ));
  }
}
