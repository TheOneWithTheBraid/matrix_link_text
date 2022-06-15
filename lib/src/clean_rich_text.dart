import 'package:flutter/widgets.dart';

/// Like Text.rich only that it also correctly disposes of all recognizers
class CleanRichText extends StatefulWidget {
  final InlineSpan child;
  final TextAlign? textAlign;
  final int? maxLines;

  const CleanRichText(this.child, {Key? key, this.textAlign, this.maxLines})
      : super(key: key);

  @override
  State<CleanRichText> createState() => _CleanRichTextState();
}

class _CleanRichTextState extends State<CleanRichText> {
  void _disposeTextSpan(TextSpan textSpan) {
    textSpan.recognizer?.dispose();
    if (textSpan.children != null) {
      for (final child in textSpan.children!) {
        if (child is TextSpan) {
          _disposeTextSpan(child);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.child is TextSpan) {
      _disposeTextSpan(widget.child as TextSpan);
    }
  }

  @override
  Widget build(BuildContext build) {
    return Text.rich(
      widget.child,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
    );
  }
}
