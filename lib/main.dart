import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

enum NavBarFlow { Row, Column }

class NavBar extends StatefulWidget {
  const NavBar(
      {Key? key,
      required this.flow,
      required this.size,
      required this.bgColor,
      required this.onTap,
      required this.children,
      this.borderRadius,
      this.selectedColor,
      this.startIndex = 0,
      this.topColumnPadding})
      : super(key: key);

  final NavBarFlow flow;
  final double size;
  final Color bgColor;
  final Function(int) onTap;
  final List<Widget> children;
  final double? borderRadius;
  final Color? selectedColor;
  final int startIndex;
  final double? topColumnPadding;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _index = 0;
  double iconPadding = 10;

  @override
  void initState() {
    _index = widget.startIndex;

    iconPadding = widget.size / 6;

    if (widget.children.length < 2) {
      throw ArgumentError(
          "children parameter must be a widget list with more than one element");
    }

    super.initState();
  }

  BoxConstraints _buildSize(size) {
    if (widget.flow == NavBarFlow.Row) {
      return BoxConstraints(maxHeight: size, minHeight: size);
    } else {
      return BoxConstraints(maxWidth: size, minWidth: size);
    }
  }

  BoxConstraints _buildSpace(size) {
    if (widget.flow == NavBarFlow.Row) {
      return BoxConstraints(maxWidth: size, minWidth: size);
    } else {
      return BoxConstraints(maxHeight: size, minHeight: size);
    }
  }

  List<Widget> _buildChildren(List<Widget> icons) {
    List<Widget> res = [];
    icons.asMap().forEach((key, value) {
      late Color bgColor;
      late double borderRadius;
      const int colorChanger = 35;
      double iconSize = widget.size - iconPadding;

      if (_index == key) {
        if (widget.selectedColor == null) {
          if ((widget.bgColor.blue + widget.bgColor.red + widget.bgColor.blue) /
                  3 >
              168) {
            bgColor = widget.bgColor
                .withBlue(widget.bgColor.blue - colorChanger)
                .withRed(widget.bgColor.red - colorChanger)
                .withGreen(widget.bgColor.green - colorChanger);
          } else {
            bgColor = widget.bgColor
                .withBlue(widget.bgColor.blue + colorChanger)
                .withRed(widget.bgColor.red + colorChanger)
                .withGreen(widget.bgColor.green + colorChanger);
          }
        } else {
          bgColor = widget.selectedColor!;
        }
      } else {
        bgColor = widget.bgColor;
      }

      if (widget.borderRadius == null) {
        borderRadius = widget.size / 4;
      } else {
        borderRadius = widget.borderRadius!;
      }

      if (key == 0 && widget.topColumnPadding != null) {
        res.add(Container(
          constraints: _buildSpace(widget.topColumnPadding),
          color: Colors.transparent,
        ));
      }

      res.add(SizedBox(
        width: iconSize,
        height: iconSize,
        child: Container(
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius)),
          child: IconButton(
            icon: value,
            onPressed: () {
              _index = key;
              widget.onTap(key);
            },
          ),
        ),
      ));
    });

    return res;
  }

  Widget _buildChild() {
    if (widget.flow == NavBarFlow.Row) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildChildren(widget.children));
    } else {
      var children = _buildChildren(widget.children);
      late List<Widget> content;
      late List<Widget> others;

      if (widget.topColumnPadding == null) {
        content = children.sublist(0, 0);
        others = children.sublist(1);
      } else {
        content = children.sublist(0, 2);
        others = children.sublist(2);
      }

      content.add(Expanded(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: others,
      )));

      return Column(
          mainAxisAlignment: MainAxisAlignment.start, children: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: widget.bgColor,
        constraints: _buildSize(widget.size),
        child: _buildChild());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyrel',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _portrait = false;
  int _index = 0;

  final List<Widget> _pages = const [Home(), TimeTable(), HomeWork()];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;
    PageController _page_controler = PageController(initialPage: _index);

    return Scaffold(
        appBar: null,
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: ((context, constraints) {
            if (constraints.maxHeight > (screenRatio * constraints.maxWidth)) {
              _portrait = true;
              return Column(
                children: [
                  Expanded(
                      child: PageView(
                    onPageChanged: (value) => setState(() {
                      _index = value;
                    }),
                    controller: _page_controler,
                    children: _pages,
                  )),
                  Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: NavBar(
                      flow: NavBarFlow.Row,
                      bgColor: Colors.white,
                      size: 60,
                      startIndex: _index,
                      onTap: (value) {
                        _page_controler.animateToPage(value,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      children: [
                        SvgPicture.asset("assets/svg/home.svg"),
                        SvgPicture.asset("assets/svg/timetable.svg"),
                        SvgPicture.asset("assets/svg/homework.svg")
                      ],
                    ),
                  )
                ],
              );
            } else {
              _portrait = false;
              return Row(children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  child: NavBar(
                    flow: NavBarFlow.Column,
                    bgColor: Colors.white,
                    size: 60,
                    startIndex: _index,
                    onTap: (value) {
                      _page_controler.animateToPage(value,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
                    topColumnPadding: 10,
                    children: [
                      SvgPicture.asset("assets/svg/home.svg"),
                      SvgPicture.asset("assets/svg/timetable.svg"),
                      SvgPicture.asset("assets/svg/homework.svg")
                    ],
                  ),
                ),
                Expanded(
                    child: PageView(
                  onPageChanged: (value) => setState(() {
                    _index = value;
                  }),
                  controller: _page_controler,
                  children: _pages,
                )),
              ]);
            }
          }),
        ));
  }
}
