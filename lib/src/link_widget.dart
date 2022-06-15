import 'package:flutter/material.dart';
import 'package:matrix_link_text/link_text.dart';
import 'package:url_launcher/link.dart';

class LinkWidget extends StatefulWidget {
  final Uri uri;
  final Widget child;
  final LinkHandlerPredicate? predicate;
  final TextStyle? style;
  final TextStyle? hoverStyle;

  const LinkWidget({
    Key? key,
    required this.uri,
    required this.child,
    this.predicate,
    this.style,
    this.hoverStyle,
  }) : super(key: key);

  @override
  State<LinkWidget> createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  bool _hovering = false;

  TextStyle? get style => _hovering
      ? widget.hoverStyle ??
          widget.style?.copyWith(color: widget.style?.color?.withBlue(128))
      : widget.style;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      onHover: (_) => setState(() => _hovering = true),
      child: Link(
        builder: (context, action) => InkWell(
            onTap: () async {
              if (await widget.predicate?.call(widget.uri) ?? false) {
                action?.call();
              }
            },
            child: style != null
                ? DefaultTextStyle(
                    style: style!,
                    child: widget.child,
                  )
                : widget.child),
        uri: widget.uri,
      ),
    );
  }
}
