import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  LargeButton({
    Key? key, 
    required this.label, 
    this.widget,
    required this.onPressed, 
    this.working = false,
    this.viewPadding = false,
    this.rounded = false,
    this.backgroundColor,
    this.color
  }) : super(key: key);

  String label;
  Widget? widget;
  Function? onPressed;
  bool working;
  bool viewPadding;
  bool rounded;
  Color? backgroundColor;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed != null ? 1.0 : 0.3,
      child: Material(
        color: backgroundColor ?? Theme.of(context).colorScheme.onBackground,
        shape: rounded ? const StadiumBorder() : null,
        child: InkWell(
          customBorder: rounded ? const StadiumBorder() : null,
          onTap: onPressed != null ? () => onPressed!() : null,
          child: Container(
            height: 56,
            margin: EdgeInsets.only(bottom: viewPadding ? MediaQuery.of(context).viewPadding.bottom : 0),
            alignment: Alignment.center,
            child: working ? SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3, 
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.background)
              ),
            ) : widget ?? Text(
              label,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w600, 
                color: color ?? Theme.of(context).colorScheme.background
              ),
            ),
          ),
        ),
      ),
    );
  }
}
