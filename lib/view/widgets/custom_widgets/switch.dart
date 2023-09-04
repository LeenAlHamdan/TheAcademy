import 'package:flutter/material.dart';
import 'package:the_academy/model/themes.dart';

class MeySwitch extends StatefulWidget {
  final String onText;
  final String offText;
  final Function onChange;
  final bool initVal;
  final bool isIcons;
  final bool awaitFun;
  final IconData? onIcon;
  final IconData? offIcon;
  final Color? onColor;
  final Color? offColor;

  const MeySwitch({
    Key? key,
    required this.onChange,
    this.offText = '',
    this.onText = '',
    this.initVal = false,
    this.isIcons = false,
    this.onIcon,
    this.offIcon,
    this.onColor,
    this.offColor,
    this.awaitFun = false,
  }) : super(key: key);
  @override
  _MeySwitchState createState() => _MeySwitchState();
}

class _MeySwitchState extends State<MeySwitch>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  final Duration _duration = const Duration(milliseconds: 370);
  late Animation<Alignment> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    isChecked = widget.initVal;

    _animationController =
        AnimationController(vsync: this, duration: _duration);

    _animation = AlignmentTween(
            begin:
                widget.initVal ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.initVal ? Alignment.centerLeft : Alignment.centerRight)
        .animate(
      CurvedAnimation(
          parent: _animationController,
          curve: widget.initVal ? Curves.bounceIn : Curves.bounceOut,
          reverseCurve: widget.initVal ? Curves.bounceOut : Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () async {
            if (mounted) {
              setState(() {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
                isChecked = !isChecked;
              });
            }
            if (widget.awaitFun) {
              await widget.onChange(isChecked);
            } else {
              widget.onChange(isChecked);
            }
          },
          child: Container(
            width: 65,
            height: 35,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: widget.onColor != null
                  ? isChecked
                      ? widget.onColor
                      : widget.offColor
                  : Themes.primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
              /* boxShadow: [
                BoxShadow(
                    color: isChecked ? Colors.green : Colors.red,
                    blurRadius: 12,
                    offset: Offset(0, 8))
              ], */
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: _animation.value,
                  child: Container(
                    width: 25,
                    height: 25,
                    margin: EdgeInsets.only(
                      right: isChecked ? 2 : 0,
                      left: isChecked ? 0 : 2,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Themes.primaryColorLight,
                    ),
                  ),
                ),
                Positioned(
                  left: isChecked ? 8 : null,
                  right: isChecked ? null : 8,
                  height: 25,
                  child: Center(
                    child: widget.isIcons
                        ? Icon(
                            isChecked ? widget.onIcon : widget.offIcon,
                          )
                        : Text(
                            isChecked ? widget.onText : widget.offText,
                            style: TextStyle(color: Themes.primaryColorLight),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
