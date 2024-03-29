import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/constants.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/utils/date.dart';
import 'package:cyrel/utils/platform.dart';
import 'package:cyrel/utils/version.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:universal_html/html.dart' as html;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

class UiPopup extends StatefulWidget {
  const UiPopup({
    Key? key,
    required this.choices,
    required this.onSubmit,
  }) : super(key: key);

  final bool Function(String) onSubmit;
  final Map<String, String> choices;

  @override
  State<UiPopup> createState() => UiPopupState();
}

class UiPopupState extends State<UiPopup> {
  late Widget mask;

  submit(String content) {
    if (widget.onSubmit(content)) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    mask = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
  }

  Widget choiceBox(String key, String content,
      {double radius = 4, Color? color}) {
    return Row(
      children: [
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.transparent,
            ),
            height: 34,
            child: BoxButton(
                onTap: () {
                  submit(key);
                },
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content,
                      style: Styles().f_15,
                    ))))
      ],
    );
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
                      Column(
                        children: widget.choices.entries
                            .map<Widget>((e) => choiceBox(e.key, e.value))
                            .toList(),
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

class UiIcsPopup extends StatefulWidget {
  const UiIcsPopup({Key? key, required this.url}) : super(key: key);

  final Future<String> url;

  @override
  State<UiIcsPopup> createState() => UiIcsPopupState();
}

class UiIcsPopupState extends State<UiIcsPopup> {
  late Widget mask;

  @override
  void initState() {
    mask = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
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
                      Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                              child: Text(
                                "Synchroniser avec Google Calendar",
                                style: Styles().f_18,
                              )),
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                "Copiez-collez l'url du calendrier ics dans Google Calendar ou une autre application gérant les calendriers",
                                style: Styles().f_15,
                              )),
                          FutureBuilder<String>(
                              future: widget.url,
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return CircularProgressIndicator(
                                    color:
                                        const Color.fromARGB(255, 38, 96, 170),
                                    backgroundColor:
                                        ThemesHandler.instance.theme.card,
                                    strokeWidth: 2,
                                  );
                                } else {
                                  return TextClipboard(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Color.fromARGB(255, 38, 96, 170),
                                      ),
                                      value: snapshot.data!);
                                }
                              })
                        ],
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

class UiTextPopup extends StatefulWidget {
  const UiTextPopup({Key? key, required this.title, required this.content})
      : super(key: key);

  final String title;
  final String content;

  @override
  State<UiTextPopup> createState() => UiTextPopupState();
}

class UiTextPopupState extends State<UiTextPopup> {
  late Widget mask;

  @override
  void initState() {
    mask = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
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
                      Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                              child: Text(
                                widget.title,
                                style: Styles().f_18,
                              )),
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                widget.content,
                                style: Styles().f_15,
                              ))
                        ],
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

class UiScreenshotPopup extends StatefulWidget {
  const UiScreenshotPopup({Key? key, required this.image, required this.name})
      : super(key: key);

  final String name;
  final Future<Uint8List> image;

  @override
  State<UiScreenshotPopup> createState() => UiScreenshotPopupState();
}

class UiScreenshotPopupState extends State<UiScreenshotPopup> {
  late Widget mask;

  @override
  void initState() {
    mask = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
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
                      FutureBuilder<Uint8List>(
                          future: widget.image,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return CircularProgressIndicator(
                                color: const Color.fromARGB(255, 38, 96, 170),
                                backgroundColor:
                                    ThemesHandler.instance.theme.card,
                                strokeWidth: 2,
                              );
                            } else {
                              return Column(
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                      child: Text(
                                        "Capture d'écran",
                                        style: Styles().f_18,
                                      )),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child:
                                          Image.memory(snapshot.requireData)),
                                  Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          (kIsWeb ||
                                                  Platform.name == "android" ||
                                                  Platform.name == "ios" ||
                                                  Platform.name == "macos")
                                              ? BoxButton(
                                                  onTap: () async {
                                                    try {
                                                      await Share.shareXFiles([
                                                        XFile.fromData(
                                                            snapshot
                                                                .requireData,
                                                            mimeType:
                                                                "image/png")
                                                      ]);
                                                    } on UnimplementedError {
                                                      Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                              opaque: false,
                                                              transitionDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          0),
                                                              reverseTransitionDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          0),
                                                              pageBuilder: (pContext,
                                                                      animation,
                                                                      secondaryAnimation) =>
                                                                  const UiContainer(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      child:
                                                                          UiTextPopup(
                                                                        title:
                                                                            "Erreur",
                                                                        content:
                                                                            "Votre appareil ne supporte pas le partage d'image",
                                                                      ))));
                                                    }
                                                  },
                                                  child: Container(
                                                      width: 45,
                                                      margin: const EdgeInsets
                                                          .only(right: 10),
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(255, 38,
                                                              96, 170),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: const Icon(
                                                        Icons.share,
                                                        size: 25,
                                                        color: Colors.white,
                                                      )))
                                              : const SizedBox(),
                                          kIsWeb
                                              ? BoxButton(
                                                  onTap: () async {
                                                    final canvas =
                                                        html.CanvasElement(
                                                            width: 1920,
                                                            height: 1080);
                                                    final ctx =
                                                        canvas.context2D;
                                                    final base64 = html.window
                                                        .btoa(snapshot
                                                            .requireData
                                                            .map((e) => String
                                                                .fromCharCode(
                                                                    e))
                                                            .join());
                                                    final img =
                                                        html.ImageElement();
                                                    img.src =
                                                        "data:image/png;base64,$base64";
                                                    img.onLoad.listen((event) {
                                                      ctx.drawImage(img, 0, 0);
                                                      final a =
                                                          html.AnchorElement(
                                                              href: canvas
                                                                  .toDataUrl());
                                                      a.download = widget.name;
                                                      a.click();
                                                    });
                                                  },
                                                  child: Container(
                                                      width: 45,
                                                      margin: const EdgeInsets
                                                          .only(right: 10),
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(255, 38,
                                                              96, 170),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: const Icon(
                                                        Icons.save,
                                                        size: 25,
                                                        color: Colors.white,
                                                      )))
                                              : const SizedBox()
                                        ],
                                      ))
                                ],
                              );
                            }
                          })
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

class TextClipboard extends StatefulWidget {
  const TextClipboard({Key? key, required this.icon, required this.value})
      : super(key: key);

  final Widget icon;
  final String value;

  @override
  State<TextClipboard> createState() => _TextClipboardState();
}

class _TextClipboardState<T extends TextClipboard> extends State<T> {
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
          Expanded(flex: 20, child: child),
          const Spacer(
            flex: 1,
          ),
          icon
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: widget.value);

    return _buildDecoration(
        BoxButton(
            child: widget.icon,
            onTap: () => Clipboard.setData(ClipboardData(text: widget.value))),
        TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () => controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.value.text.length),
            keyboardType: TextInputType.none,
            autocorrect: false,
            cursorColor: cursorColor,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: style.apply(
                    color: ThemesHandler.instance.theme.foreground
                        .withAlpha(150))),
            style: style));
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
            return Stack(
              children: [
                SizedBox(
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
                                backgroundColor:
                                    Color.fromRGBO(213, 213, 213, 1.0),
                                color: Color.fromRGBO(55, 110, 187, 1),
                              )),
                        ],
                      ),
                    )),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 40,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        softWrap: true,
                        text: TextSpan(children: [
                          TextSpan(
                              text: "v${Version.instance.toString()} | ",
                              style: Styles().f_15),
                          TextSpan(
                              text: poweredBy,
                              mouseCursor: SystemMouseCursors.click,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Uri url = poweredByUrl;
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                              style: Styles()
                                  .f_15
                                  .apply(color: Colors.blue)
                                  .apply(decoration: TextDecoration.underline)),
                        ]),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }
}

class PromGrpSelector extends StatefulWidget {
  PromGrpSelector(
      {Key? key,
      required this.builder,
      this.visible = true,
      this.customFetchPromos,
      this.customFetchGroups})
      : super(key: key);

  bool visible;
  Future<List<GroupEntity>> Function()? customFetchPromos;
  Future<List<GroupEntity>> Function(GroupEntity)? customFetchGroups;

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
    if (widget.customFetchPromos != null)
      return await widget.customFetchPromos!();
    return (await Api.instance.groups.get())
        .where(
            (group) => group.private == false && group.tags["type"] == "promo")
        .toList();
  }

  Future<List<GroupEntity>> fetchGroups(GroupEntity group) async {
    if (widget.customFetchGroups != null)
      return await widget.customFetchGroups!(group);
    return (await Api.instance.groups.get())
        .where((g) =>
            g.private == false &&
            g.parent?.id == group.id &&
            g.tags["type"] == "group")
        .toList();
  }

  Widget containerOrExtended(
      {required bool containerMode,
      required Widget child,
      required double maxWidth}) {
    if (containerMode) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      );
    } else {
      return Expanded(flex: 1, child: child);
    }
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
          if (!widget.visible) {
            return const SizedBox();
          }
          List<Widget> fields = [
            FutureBuilder(
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return containerOrExtended(
                    containerMode:
                        CyrelOrientation.current == CyrelOrientation.portrait,
                    // constraints: BoxConstraints(maxWidth: CyrelOrientation.current == CyrelOrientation.portrait? 400: constraints.maxWidth / 2 - 10),
                    maxWidth: 400,
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
                      return containerOrExtended(
                        containerMode: CyrelOrientation.current ==
                            CyrelOrientation.portrait,
                        // constraints: BoxConstraints(maxWidth: CyrelOrientation.current == CyrelOrientation.portrait? 400: constraints.maxWidth / 2 - 10),
                        maxWidth: 400,
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
              margin: const EdgeInsets.symmetric(horizontal: 5),
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
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
