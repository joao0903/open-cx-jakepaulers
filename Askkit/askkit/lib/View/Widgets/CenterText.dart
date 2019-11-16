import 'package:flutter/cupertino.dart';

class CenterText extends StatelessWidget {
  String text;
  double textScale;

  CenterText(this.text, {this.textScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Text(this.text, textScaleFactor: textScale, textAlign: TextAlign.center)
        )
    );
  }
}