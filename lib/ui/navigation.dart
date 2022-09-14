import 'dart:io';

import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UiPage {
  UiPage({Key? key, required this.icon, required this.page}) : super();

  final Widget icon;
  final Widget page;
}

class NavIcon extends StatelessWidget {
  const NavIcon({Key? key, required this.icon}) : super(key: key);

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: icon,
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar(
      {Key? key,
      required this.size,
      required this.onTap,
      required this.children,
      this.borderRadius,
      this.selectedColor,
      required this.index})
      : super(key: key);

  final double size;
  final Function(int) onTap;
  final List<Widget> children;
  final double? borderRadius;
  final Color? selectedColor;
  final int index;

  @override
  State<NavBar> createState() => NavBarState();
}

class NavBarState<T extends NavBar> extends State<T> {
  late int _index;
  late double _iconPadding;

  Widget _iconBoxBuilder(Widget child, Color bgColor) {
    late double borderRadius;
    double iconSize = widget.size - _iconPadding;

    if (widget.borderRadius == null) {
      borderRadius = widget.size / 4;
    } else {
      borderRadius = widget.borderRadius!;
    }

    return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Container(
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius)),
            child: child));
  }

  List<Widget> _buildChildren() {
    List<Widget> res = [];
    Color selectedColor = ThemesHandler.instance.theme.navIcon;

    widget.children.asMap().forEach((key, value) {
      late Widget icon;

      if (key == _index) {
        icon = _iconBoxBuilder(NavIcon(icon: value), selectedColor);
      } else {
        icon = _iconBoxBuilder(
            NavIcon(icon: value), ThemesHandler.instance.theme.card);
      }

      res.add(Expanded(
        flex: 1,
        child: BoxButton(
          child: Center(child: icon),
          onTap: () {
            _index = key;
            widget.onTap(key);
          },
        ),
      ));
    });

    return res;
  }

  @override
  void initState() {
    _index = widget.index;
    _iconPadding = widget.size / 5;

    if (widget.children.length < 2) {
      throw ArgumentError(
          "children parameter must be a widget list with more than one element");
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index) {
      _index = widget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemesHandler.instance.theme.card,
      constraints: BoxConstraints(minHeight: widget.size),
      child: Row(
        children: _buildChildren(),
      ),
    );
  }
}

class NavRail extends NavBar {
  const NavRail(
      {Key? key,
      required double size,
      required Function(int) onTap,
      required List<Widget> children,
      double? borderRadius,
      Color? selectedColor,
      required int index,
      this.topColumnPadding})
      : super(
            key: key,
            size: size,
            onTap: onTap,
            children: children,
            index: index);

  final double? topColumnPadding;

  @override
  State<NavRail> createState() => NavRailState();
}

class NavRailState extends NavBarState<NavRail> {
  @override
  List<Widget> _buildChildren() {
    List<Widget> res = [];
    Color selectedColor = ThemesHandler.instance.theme.navIcon;

    widget.children.asMap().forEach((key, value) {
      late Color bgColor;

      bgColor = key == _index
          ? selectedColor
          : ThemesHandler.instance.theme.card;

      res.add(_iconBoxBuilder(
          BoxButton(
              child: NavIcon(icon: value),
              onTap: () {
                _index = key;
                widget.onTap(key);
              }),
          bgColor));
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _buildChildren();
    List<Widget> middleElements = [];

    children.sublist(1).asMap().forEach((key, value) {
      middleElements.add(value);

      if (key + 1 < children.length - 1) {
        middleElements.add(
            Container(constraints: BoxConstraints(minHeight: _iconPadding)));
      }
    });

    List<Widget> content = [
      children.first,
      Expanded(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: middleElements,
      ))
    ];

    if (widget.topColumnPadding != null) {
      content.insert(
          0,
          Container(
            constraints: BoxConstraints(
                maxHeight: widget.topColumnPadding!,
                minWidth: widget.topColumnPadding!),
          ));
    }

    return Container(
        color: ThemesHandler.instance.theme.card,
        constraints: BoxConstraints(minWidth: widget.size),
        child: Column(children: content));
  }
}

class NavHandler extends StatefulWidget {
  const NavHandler({Key? key, required this.pages}) : super(key: key);

  final List<UiPage> pages;

  @override
  State<NavHandler> createState() => _NavHandlerState();
}

class _NavHandlerState extends State<NavHandler> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;
    PageController pageControler = PageController(initialPage: _index);

    Widget getView({required Axis scrollDirection}) {
      return Expanded(
          child: PageView(
            physics: !kIsWeb && Platform.isAndroid
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        scrollDirection: scrollDirection,
        onPageChanged: (value) => setState(() {
          _index = value;
        }),
        controller: pageControler,
        children: widget.pages.map((e) => e.page).toList(),
      ));
    }

    List<Widget> icons = widget.pages.map(((e) => e.icon)).toList();

    void _onTap(int value) {
      if (value == _index - 1 || value == _index + 1) {
        pageControler.animateToPage(value,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        pageControler.jumpToPage(value);
      }
    }

    return UiContainer(
      backgroundColor: ThemesHandler.instance.theme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight > (screenRatio * constraints.maxWidth)) {
            CyrelOrientation.current = CyrelOrientation.portrait;
            return Column(children: [
              getView(scrollDirection: Axis.horizontal),
              NavBar(
                size: 60,
                index: _index,
                onTap: _onTap,
                children: icons,
              ),
            ]);
          } else {
            CyrelOrientation.current = CyrelOrientation.landscape;
            return Row(children: [
              NavRail(
                size: 60,
                index: _index,
                onTap: _onTap,
                topColumnPadding: 10,
                children: icons,
              ),
              getView(scrollDirection: Axis.vertical),
            ]);
          }
        },
      ),
    );
  }
}
