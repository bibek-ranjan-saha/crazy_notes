import 'dart:async';
import 'package:flutter/material.dart';

/// Custom Animation Controller to controll the animation state of AnimatedText Widget
enum AnimatedTextController {
  play,
  pause,
  stop,
  restart,
  loop,
}

///
/// AnimatedText Widget helps to animated the words from one to another by
/// re-using the [similar alphabets] between the two animating words
///
class AnimatedText extends StatefulWidget {
  /// List of [String] that would be displayed subsequently in the animation.
  final List<String> wordList;

  /// Gives [TextStyle] to the words.
  final TextStyle? textStyle;

  /// Sets the [speed] of the text animations.
  ///
  /// Default [speed] of per Text Animation is 1000 milliseconds.
  final Duration speed;

  /// Sets the [alignment] to the text.
  ///
  /// Default [alignment] is set to Alignment.center
  final Alignment alignment;

  /// Sets the [controller] for the animation.
  ///
  /// Default [controller] is set to AnimatedTextController.loop
  final AnimatedTextController controller;

  /// Set the [display time] of the text after fade-in.
  /// It will wait for display-time before starting the next animation
  ///
  /// Default [display time] is 1000 milliseconds.
  final Duration displayTime;

  /// Adds the onFinished [VoidCallback] to the animated widget.
  ///
  /// This method will run only if [controller] is not set to AnimatedTextController.loop
  final VoidCallback? onFinished;

  /// Adds the onAnimate [VoidCallback] to the animated widget.
  ///
  /// This method will be called right after the fade-in animtion of the text with its index.
  final Function? onAnimate;

  /// Sets the number of times the animation should repeat
  ///
  /// By default it is set to 5
  final int repeatCount;

  const AnimatedText(
      {Key? key,required this.wordList,
        this.speed = const Duration(milliseconds: 1000),
        this.displayTime = const Duration(milliseconds: 1000),
        this.textStyle,
        this.alignment = Alignment.center,
        this.onFinished,
        this.repeatCount = 5,
        this.controller = AnimatedTextController.loop,
        this.onAnimate})
      : assert(wordList.length > 1,
  'AnimatedText: wordList must contain aleast 2 strings.'),
        assert(repeatCount >= 0,
        'AnimatedText: repeatCount should be greator than equal to 0'),
        super();
  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  bool isFirst = true, pause = false;
  int index = 0, finalCounter = 0, length = 0;
  List<String> words = List<String>.empty(growable: true);
  List<List<String>> separatedStrings =
  List<List<String>>.empty(growable: true);
  Map<String, Map<String, _Position>> animateDataMap =
  <String, Map<String, _Position>>{};
  Map<String, List<String>> preProcesedFadeIn = <String, List<String>>{},
      preProcesedFadeOut = <String, List<String>>{};
  Timer? _timer;

  AnimationController? fadeController;
  Animation? fadeOutAnimation, fadeInAnimation;

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    pause = oldWidget.controller == AnimatedTextController.pause;

    if (!_isSame(oldWidget.wordList, widget.wordList)) {
      _resetAnimation();
      _setInitialValues();
      _processWords();
      if (widget.controller == AnimatedTextController.play ||
          widget.controller == AnimatedTextController.restart ||
          widget.controller == AnimatedTextController.loop) {
        _start();
      }
    } else {
      if (oldWidget.controller != widget.controller) {
        setState(() {
          pause = widget.controller == AnimatedTextController.pause ||
              widget.controller == AnimatedTextController.stop;
        });

        if (widget.controller == AnimatedTextController.stop) {
          _resetAnimation();
          _setInitialValues();
        } else if (widget.controller == AnimatedTextController.play ||
            widget.controller == AnimatedTextController.loop) {
          _resetAnimation();
          _nextAnimation();
        } else if (widget.controller == AnimatedTextController.restart) {
          _resetAnimation();
          _setInitialValues();
          _start();
        } else if (widget.controller == AnimatedTextController.pause) {
          _timer?.cancel();
          //fadeController?.reset();
        }
      }
    }
  }

  _resetAnimation() {
    _timer?.cancel();
    fadeController?.reset();
    fadeController?.stop();
    fadeController?.dispose();
  }

  bool _isSame(List<String> list1, List<String> list2) {
    if (list1.length == list2.length) {
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) {
          return false;
        }
      }
    } else {
      return false;
    }
    return true;
  }

  _setInitialValues() {
    index = 0;
    finalCounter = 0;
    setState(() {});
  }

  @override
  void initState() {
    _resetAnimation();
    _setInitialValues();
    _processWords();
    _start();
    super.initState();
  }

  _start() {
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    fadeController?.stop();
    fadeController?.dispose();
    super.dispose();
  }

  _processWords() {
    words = List<String>.from(widget.wordList);
    preProcesedFadeIn = <String, List<String>>{};
    preProcesedFadeOut = <String, List<String>>{};
    separatedStrings = List<List<String>>.empty(growable: true);
    animateDataMap = <String, Map<String, _Position>>{};
    length = words.length;
    for (var element in words) {
      Map<String, int> map = <String, int>{};
      List<String> lis = List<String>.empty(growable: true);
      element.replaceAll(' ', ' ').split('').forEach((element) {
        map[element] = (map[element] ??= 0) + 1;
        lis.add('$element${map[element]}');
      });
      separatedStrings.add(lis);
    }

    int len = separatedStrings.length;
    for (int i = 0; i < len; i++) {
      Map<String, _Position> inner = <String, _Position>{};
      for (int j = 0; j < separatedStrings[i].length; j++) {
        if (separatedStrings[(i + 1) % len].contains(separatedStrings[i][j])) {
          inner[separatedStrings[i][j]] = _Position(-1, -1, const Size(-1, -1));
        }
      }

      animateDataMap[words[i]] = Map.from(inner);
    }

    for (int i = 0; i < len; i++) {
      String strFadeIn = "", strFadeOut = "";
      List<String> fadeIn = List<String>.empty(growable: true),
          fadeOut = List<String>.empty(growable: true);
      int pos = _prevIndex(i);
      for (int j = 0; j < separatedStrings[i].length; j++) {
        String element = separatedStrings[i][j];
        if (animateDataMap[words[pos]]![element] != null) {
          if (strFadeIn != "") {
            fadeIn.add(strFadeIn);
          }
          fadeIn.add(element);
          strFadeIn = "";
        } else {
          strFadeIn += element.substring(0, 1);
        }

        if (animateDataMap[words[i]]![element] != null) {
          if (strFadeOut != "") {
            fadeOut.add(strFadeOut);
          }
          fadeOut.add(element);
          strFadeOut = "";
        } else {
          strFadeOut += element.substring(0, 1);
        }
      }
      if (strFadeIn != "") {
        fadeIn.add(strFadeIn);
      }

      if (strFadeOut != "") {
        fadeOut.add(strFadeOut);
      }

      preProcesedFadeIn[words[i]] = fadeIn;
      preProcesedFadeOut[words[i]] = fadeOut;
    }
    if (mounted) setState(() {});
  }

  int _prevIndex(int index) {
    return ((index - 1) % length + length) % length;
  }

  _setKey(GlobalKey key, MapEntry e) {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (key.currentContext != null) {
        animateDataMap[words[_prevIndex(index)]]![e.value] =
            _getPositionByKey(key);
      } else {
        _setKey(key, e);
      }
    });
  }

  _startAnimation() async {
    fadeController = AnimationController(
      duration: widget.speed,
      vsync: this,
    );

    fadeOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: fadeController!,
            curve: const Interval(0.2, 0.4, curve: Curves.decelerate)));

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: fadeController!,
            curve: const Interval(0.4, 1.0, curve: Curves.decelerate)));
    if (widget.controller == AnimatedTextController.play ||
        widget.controller == AnimatedTextController.restart ||
        widget.controller == AnimatedTextController.loop) {
      await fadeController?.forward();
      if (widget.onAnimate != null) widget.onAnimate!(index);
      _nextAnimation();
    }
  }

  _nextAnimation() {
    if (pause) {
      return;
    }
    bool isLast = index == length - 1;
    if (isFirst && index == 0) {
      isFirst = false;
    }

    if (isLast) {
      if (widget.controller == AnimatedTextController.loop) {
        index = 0;
      } else {
        if (finalCounter >= widget.repeatCount) {
          _timer?.cancel();
          if (widget.onFinished != null) widget.onFinished!();
          return;
        }
        finalCounter++;
        index = 0;
      }
    } else {
      index++;
    }

    if (mounted) setState(() {});

    fadeController = AnimationController(
      duration: widget.speed,
      vsync: this,
    );

    fadeOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: fadeController!,
            curve: const Interval(0.4, 1.0, curve: Curves.decelerate)));

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: fadeController!,
            curve: const Interval(0.65, 1.0, curve: Curves.decelerate)))
      ..addStatusListener(_animationEndedListener);

    if (widget.controller == AnimatedTextController.play ||
        widget.controller == AnimatedTextController.restart ||
        widget.controller == AnimatedTextController.loop) {
      if (widget.onAnimate != null) widget.onAnimate!(index);
      fadeController?.forward();
    }
  }

  _animationEndedListener(state) {
    if (state == AnimationStatus.completed) {
      _timer = Timer(
          Duration(
              milliseconds: widget.displayTime.inMilliseconds < 600
                  ? 600
                  : widget.displayTime.inMilliseconds),
          _nextAnimation);
    }
  }

  Widget buildPositionProvider(MapEntry e) {
    GlobalKey key = GlobalKey();
    Widget textWidget = RichText(
      key: key,
      maxLines: 1,
      text: TextSpan(
        style: widget.textStyle ?? DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: e.value.substring(0, 1),
              style: TextStyle(color: Colors.black.withOpacity(0))),
        ],
      ),
    );
    if (animateDataMap[words[_prevIndex(index)]] != null &&
        animateDataMap[words[_prevIndex(index)]]![e.value] != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (key.currentContext != null) {
          animateDataMap[words[_prevIndex(index)]]![e.value] =
              _getPositionByKey(key);
        } else {
          _setKey(key, e);
        }
      });
    }
    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: <Widget>[
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  alignment: widget.alignment,
                  child: Wrap(
                    children:
                    separatedStrings[index].toList().asMap().entries.map((e) {
                      return buildPositionProvider(e);
                    }).toList(),
                  ),
                ),
                // Fade out
                if (words.length > 1)
                  _FadeOut(
                    first: isFirst,
                    alignment: widget.alignment,
                    textStyle:
                    widget.textStyle ?? DefaultTextStyle.of(context).style,
                    fadeAnimation: fadeOutAnimation!,
                    fadeController: fadeController!,
                    animatedMap: animateDataMap[words[_prevIndex(index)]]!,
                    alphabets: preProcesedFadeOut[words[_prevIndex(index)]]!,
                  ),
                // FadeIn
                if (words.length > 1)
                  _FadeIn(
                    first: isFirst,
                    textStyle:
                    widget.textStyle ?? DefaultTextStyle.of(context).style,
                    alignment: widget.alignment,
                    fadeAnimation: fadeInAnimation!,
                    fadeController: fadeController!,
                    animatedMap: animateDataMap[words[_prevIndex(index)]]!,
                    alphabets: isFirst
                        ? separatedStrings[index]
                        : preProcesedFadeIn[words[index]]!,
                  ),
              ],
            ),
          );
        });
  }
}

// ignore: must_be_immutable
class _FadeIn extends StatefulWidget {
  final Map<String, _Position> animatedMap;
  final List<String> alphabets;
  final TextStyle textStyle;
  final bool first;
  final AnimationController fadeController;
  final Alignment alignment;
  final Animation fadeAnimation;
  const _FadeIn({
    required this.textStyle,
    required this.animatedMap,
    required this.alphabets,
    this.first = false,
    required this.fadeController,
    required this.fadeAnimation,
    required this.alignment,
  }) : super();
  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: widget.alignment,
      child: Wrap(
        children: widget.alphabets.toList().asMap().entries.map((e) {
          GlobalKey currentKey = GlobalKey();
          return AnimatedBuilder(
              key: currentKey,
              animation: widget.fadeAnimation,
              builder: (context, snapshot) {
                bool color = false;
                String text = e.value;
                if (widget.first) {
                  text = e.value.substring(0, 1);
                } else {
                  if (widget.animatedMap[e.value] != null) {
                    text = e.value.substring(0, 1);
                    color = true;
                  }
                }

                return _OpacityChild(
                  opacity: widget.fadeAnimation.value,
                  x: 0,
                  y: 40 * (1 - (widget.fadeAnimation.value as double)),
                  letter: text,
                  style: widget.textStyle,
                  color: color
                      ? widget.fadeController.isAnimating
                      ? Colors.transparent
                      : widget.textStyle.color
                      : widget.textStyle.color,
                );
              });
        }).toList(),
      ),
    );
  }
}

// ignore: must_be_immutable
class _FadeOut extends StatefulWidget {
  final Map<String, _Position> animatedMap;
  final List<String> alphabets;
  final TextStyle textStyle;
  final bool first;
  final AnimationController fadeController;
  final Alignment alignment;
  final Animation fadeAnimation;
  const _FadeOut({
    required this.textStyle,
    required this.animatedMap,
    required this.alphabets,
    this.first = false,
    required this.fadeController,
    required this.fadeAnimation,
    required this.alignment,
  }) : super();
  @override
  _FadeOutState createState() => _FadeOutState();
}

class _FadeOutState extends State<_FadeOut> {
  List<double>? localRef;

  @override
  void initState() {
    localRef = List<double>.empty(growable: true);
    _putLocalRef();
    super.initState();
  }

  @override
  void didUpdateWidget(_FadeOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alphabets != widget.alphabets) {
      _putLocalRef();
    }
  }

  _putLocalRef() {
    localRef = List<double>.empty(growable: true);
    for (var _ in widget.alphabets) {
      localRef!.add(0.0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: widget.alignment,
      child: Wrap(
        children: widget.alphabets.toList().asMap().entries.map((e) {
          double x = 0, y = -40;
          GlobalKey currentKey = GlobalKey();
          return AnimatedBuilder(
              key: currentKey,
              animation: widget.fadeAnimation,
              builder: (context, snapshot) {
                bool isUp = true;
                String text = e.value;
                if (!widget.first) {
                  if (widget.animatedMap[e.value] != null) {
                    text = e.value.substring(0, 1);
                    isUp = false;
                    _Position toPosition = widget.animatedMap[e.value]!;
                    if (currentKey.currentContext?.findRenderObject() != null) {
                      _Position fromPosition = _getPositionByKey(currentKey);
                      x = toPosition.x -
                          fromPosition.x +
                          toPosition.size.width -
                          fromPosition.size.width;
                    }
                  }
                }

                if (widget.fadeController.isAnimating) {
                  localRef![e.key] = x;
                }

                return _OpacityChild(
                  opacity: widget.first
                      ? 0
                      : isUp
                      ? widget.fadeController.isAnimating
                      ? (1 - widget.fadeAnimation.value)
                      : 0
                      : widget.fadeController.isAnimating
                      ? 1
                      : widget.fadeAnimation.value,
                  x: localRef![e.key] * widget.fadeAnimation.value,
                  y: isUp ? y * widget.fadeAnimation.value : 0,
                  letter: text,
                  style: widget.textStyle,
                  color: widget.fadeController.isAnimating
                      ? widget.textStyle.color
                      : widget.fadeController.isDismissed
                      ? widget.textStyle.color
                      : Colors.transparent,
                );
              });
        }).toList(),
      ),
    );
  }
}

class _OpacityChild extends StatelessWidget {
  final double opacity, x, y;
  final String letter;
  final TextStyle style;
  final Color? color;
  const _OpacityChild(
      {required this.opacity,
        required this.x,
        required this.y,
        required this.letter,
        required this.style,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
          offset: Offset(x, y),
          child: RichText(
            maxLines: 1,
            text: TextSpan(
              style: style,
              children: <TextSpan>[
                TextSpan(
                    text: letter,
                    style: TextStyle(color: color ?? Colors.black)),
              ],
            ),
          )),
    );
  }
}

class _Position {
  double x, y;
  Size size;
  _Position(this.x, this.y, this.size);
}

_Position _getPositionByKey(GlobalKey key) {
  RenderBox? box = (key.currentContext?.findRenderObject() as RenderBox?);
  if (box != null) {
    Size size = box.size;
    Offset position = box.localToGlobal(Offset.zero);
    return _Position(position.dx, position.dy, size);
  }
  return _Position(0, 0, const Size(0, 0));
}
