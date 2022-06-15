//  Copyright (c) 2019 Aleksander Woźniak
//  Copyright (c) 2020 Sorunome
//  Copyright (c) 2022 Famedly GmbH
//  Licensed under Apache License v2.0

library matrix_link_text;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import 'src/clean_rich_text.dart';
import 'src/link_widget.dart';
import 'src/tlds.dart';
import 'src/schemes.dart';

export 'src/clean_rich_text.dart';

typedef LinkTapHandler = void Function(String uri);

/// predicates whether the [uri] is handled internally by the app
///
/// returns [true] in case the link is being handled by the app
/// returns [false] in case the [Link] widget should handle the [uri]
typedef LinkHandlerPredicate = FutureOr<bool?> Function(Uri uri);

@Deprecated('Use [LinkWidgetSpan] instead.')
class LinkTextSpan extends LinkWidgetSpan {
  LinkTextSpan(
      {TextStyle? style,
      required String url,
      String? text,
      LinkTapHandler? onLinkTap,
      List<InlineSpan>? children})
      : super(
            uri: Uri.parse(url),
            text: text,
            children: children,
            style: style,
            predicate: onLinkTap == null
                ? null
                : (uri) {
                    onLinkTap(uri.toString());
                    return true;
                  });
}

class LinkWidgetSpan extends WidgetSpan {
  final Uri uri;

  LinkWidgetSpan(
      {TextStyle? style,
      TextStyle? hoverStyle,
      required this.uri,
      String? text,
      LinkHandlerPredicate? predicate,
      List<InlineSpan>? children})
      : assert((text != null) ^ (children != null),
            'You must either provide [text] or [children], never both.'),
        super(
          child: LinkWidget(
            uri: uri,
            predicate: predicate,
            style: style,
            hoverStyle: hoverStyle,
            child: text != null
                ? Text(text)
                : Text.rich(TextSpan(children: children)),
          ),
          style: style,
        );
}

// whole regex:
// (?<=\b|(?<=\W)(?=[#!+$@])|^)(?:(?<![#!+$@=])(?:([a-z0-9]+):(?:\/\/(?:[^\s\x{200b}]+(?::[^\s\x{200b}]*)?@)?(?:[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.[a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+|\d{1,3}(?:\.\d{1,3}){3}|\[[\da-f:]{3,}\]|localhost)(?::\d+)?(?:(?=[\/?#])[^\s\x{200b}\(]*(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))?|(?!\/\/)[^\s\x{200b}\(]+(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))|(?<!\.)[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.(?!http)([a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+)(?:(?=[\/?#])[^\s\x{200b}\(]*(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))?|(?:[^\s\x{200b}]+@)[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.(?!http)([a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+))|[#!+$@][^:\s\x{200b}]*:[\w\.\d-]+\.[\w\d-]+)
// Consists of: `startregex(?:urlregex|matrixregex)`
// start regex: (?<=\b|(?<=\W)(?=[#!+$@])|^)
// url regex: (?<![#!+$@=])(?:([a-z0-9]+):(?:\/\/(?:[^\s\x{200b}]+(?::[^\s\x{200b}]*)?@)?(?:[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.[a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+|\d{1,3}(?:\.\d{1,3}){3}|\[[\da-f:]{3,}\]|localhost)(?::\d+)?(?:(?=[\/?#])[^\s\x{200b}\(]*(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))?|(?!\/\/)[^\s\x{200b}\(]+(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))|(?<!\.)[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.(?!http)([a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+)(?:(?=[\/?#])[^\s\x{200b}\(]*(?:\([^\s\x{200b}]*[^\s\x{200b}:;,.!?>\]}]|[^\s\x{200b}\):;,.!?>\]}]))?|(?:[^\s\x{200b}]+@)[a-z\d\x{00a1}-\x{ffff}](?:\.?[a-z\d\x{00a1}-\x{ffff}-])*\.(?!http)([a-z\x{00a1}-\x{ffff}][a-z\x{00a1}-\x{ffff}-]+))
// matrix regex: [#!+$@][^:\s\x{200b}]*:[\w\.\d-]+\.[\w\d-]+
// \x{0000} needs to be replaced with \u0000, not done in the comments so that they work with regex101.com
final RegExp _regex = RegExp(
    r'(?<=\b|(?<=\W)(?=[#!+$@])|^)(?:(?<![#!+$@=])(?:([a-z0-9]+):(?:\/\/(?:[^\s\u200b]+(?::[^\s\u200b]*)?@)?(?:[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.[a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+|\d{1,3}(?:\.\d{1,3}){3}|\[[\da-f:]{3,}\]|localhost)(?::\d+)?(?:(?=[\/?#])[^\s\u200b\(]*(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))?|(?!\/\/)[^\s\u200b\(]+(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))|(?<!\.)[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.(?!http)([a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+)(?:(?=[\/?#])[^\s\u200b\(]*(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))?|(?:[^\s\u200b]+@)[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.(?!http)([a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+))|[#!+$@][^:\s\u200b]*:[\w\.\d-]+\.[\w\d-]+)',
    caseSensitive: false);

// fallback regex without lookbehinds for incompatible browsers etc.
// it is slightly worse but still gets the job mostly done
final RegExp _fallbackRegex = RegExp(
    r'(?:\b|(?=[#!+$@])|^)(?:(?:([a-z0-9]+):(?:\/\/(?:[^\s\u200b]+(?::[^\s\u200b]*)?@)?(?:[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.[a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+|\d{1,3}(?:\.\d{1,3}){3}|\[[\da-f:]{3,}\]|localhost)(?::\d+)?(?:(?=[\/?#])[^\s\u200b\(]*(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))?|(?!\/\/)[^\s\u200b\(]+(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))|[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.(?!http)([a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+)(?:(?=[\/?#])[^\s\u200b\(]*(?:\([^\s\u200b]*[^\s\u200b:;,.!?>\]}]|[^\s\u200b\):;,.!?>\]}]))?|(?:[^\s\u200b]+@)[a-z\d\u00a1-\uffff](?:\.?[a-z\d\u00a1-\uffff-])*\.(?!http)([a-z\u00a1-\uffff][a-z\u00a1-\uffff-]+))|[#!+$@][^:\s\u200b]*:[\w\.\d-]+\.[\w\d-]+)',
    caseSensitive: false);

final RegExp _estimateRegex = RegExp(r'[^\s\u200b][\.:][^\s\u200b]');

// ignore: non_constant_identifier_names
TextSpan LinkTextSpans(
    {required String text,
    TextStyle? textStyle,
    TextStyle? linkStyle,
    TextStyle? hoverStyle,
    @Deprecated('Use [beforeLaunch] instead.') LinkTapHandler? onLinkTap,
    LinkHandlerPredicate? beforeLaunch,
    ThemeData? themeData}) {
  textStyle ??= themeData?.textTheme.bodyText2;
  linkStyle ??= themeData?.textTheme.bodyText2?.copyWith(
    color: themeData.colorScheme.secondary,
    decoration: TextDecoration.underline,
  );

  // first estimate if we are going to have matches at all
  final estimateMatches = _estimateRegex.allMatches(text);
  if (estimateMatches.isEmpty) {
    return TextSpan(
      text: text,
      style: textStyle,
      children: const [],
    );
  }

  // Our _regex uses lookbehinds for nicer matching, which isn't supported by all browsers yet.
  // Sadly, an error is only thrown on usage. So, we try to match against an empty string to get
  // our error ASAP and then determine the regex we use based on that.
  RegExp regexToUse;
  try {
    _regex.hasMatch('');
    regexToUse = _regex;
  } catch (_) {
    regexToUse = _fallbackRegex;
  }

  List<RegExpMatch>? links;
  List<String>? textParts;
  if (text.length > 300) {
    // we have a super long text, let's try to split it up
    links = [];
    // thing greatly simplify if the textParts.last is already a string
    textParts = [''];
    // now we will separate the `text` into chunks around their matches, and then apply the regex
    // only to those substrings.
    // As we already estimated some matches, we know the for-loop will run at least once, simplifying things
    // we will need to make sure to merge overlapping chunks together
    var curStart = -1; // the current chunk start
    var curEnd = 0; // the current chunk end
    var lastEnd = 0; // the last chunk end, where we stopped parsing
    var abort = false; // should we abort and fall back to the slow method?
    void processChunk() {
      if (textParts == null || links == null) {
        abort = true;
        links = null;
        textParts = null;
        return;
      }
      // we gotta make sure to save the text fragment between the current and the last chunk
      final firstFragment = text.substring(lastEnd, curStart);
      if (firstFragment.isNotEmpty) {
        textParts!.last += firstFragment;
      }
      // fetch our current fragment...
      final fragment = text.substring(curStart, curEnd);
      // add all the links
      links!.addAll(regexToUse.allMatches(fragment));

      // and fetch the text parts
      final fragmentTextParts = fragment.split(regexToUse);
      // if the first of last text part is empty, that means that the chunk wasn't big enough to fit the full URI
      // thus we abort and fall back to the slow method
      if ((fragmentTextParts.first.isEmpty && curStart > 0) ||
          (fragmentTextParts.last.isEmpty && curEnd < text.length)) {
        abort = true;
        links = null;
        textParts = null;
        return;
      }
      // add all the text parts correctly
      textParts!.last += fragmentTextParts.removeAt(0);
      textParts!.addAll(fragmentTextParts);
      // and save the lastEnd for later
      lastEnd = curEnd;
    }

    for (final e in estimateMatches) {
      const chunkSize = 120;
      final start = max(e.start - chunkSize, 0);
      final end = min(e.start + chunkSize, text.length);
      if (start < curEnd) {
        // merge blocks
        curEnd = end;
      } else {
        // new block! And proccess the last chunk!
        if (curStart != -1) {
          processChunk();
        }
        curStart = start;
        curEnd = end;
      }
      if (abort) {
        break;
      }
    }
    // we musn't forget to proccess the last chunk
    if (!abort) {
      processChunk();
    }
    if (!abort) {
      // and we musn't forget to add the last fragment
      final lastFragment = text.substring(lastEnd, text.length);
      if (lastFragment.isNotEmpty && textParts != null) {
        textParts!.last += lastFragment;
      }
    }
  }
  links ??= regexToUse.allMatches(text).toList();
  if (links!.isEmpty) {
    return TextSpan(
      text: text,
      style: textStyle,
      children: const [],
    );
  }

  textParts ??= text.split(regexToUse);
  final textSpans = <InlineSpan>[];

  int i = 0;
  for (var part in textParts!) {
    textSpans.add(TextSpan(text: part, style: textStyle));

    if (i < links!.length) {
      final element = links![i];
      final linkText = element.group(0) ?? '';
      var link = linkText;
      final scheme = element.group(1);
      final tldUrl = element.group(2);
      final tldEmail = element.group(3);
      var valid = true;
      if (scheme?.isNotEmpty ?? false) {
        // we have to validate the scheme
        valid = allSchemes.contains(scheme!.toLowerCase());
      }
      if (valid && (tldUrl?.isNotEmpty ?? false)) {
        // we have to validate if the tld exists
        valid = allTlds.contains(tldUrl!.toLowerCase());
        link = 'https://$link';
      }
      if (valid && (tldEmail?.isNotEmpty ?? false)) {
        // we have to validate if the tld exists
        valid = allTlds.contains(tldEmail!.toLowerCase());
        link = 'mailto:$link';
      }
      final uri = Uri.parse(link);

      if (valid) {
        textSpans.add(
          LinkWidgetSpan(
            text: linkText,
            style: linkStyle,
            hoverStyle: hoverStyle,
            uri: uri,
            predicate: beforeLaunch ??
                // ignore: deprecated_member_use_from_same_package
                (onLinkTap != null
                    ? (uri) {
                        // ignore: deprecated_member_use_from_same_package
                        onLinkTap.call(uri.toString());
                        return false;
                      }
                    : null),
          ),
        );
      } else {
        textSpans.add(TextSpan(text: linkText, style: textStyle));
      }

      i++;
    }
  }
  return TextSpan(text: '', children: textSpans);
}

class LinkText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextStyle? hoverStyle;
  final TextAlign? textAlign;
  @Deprecated('Use [beforeLaunch] instead.')
  final LinkTapHandler? onLinkTap;
  final LinkHandlerPredicate? beforeLaunch;
  final int? maxLines;

  const LinkText({
    Key? key,
    required this.text,
    this.textStyle,
    this.linkStyle,
    this.hoverStyle,
    this.textAlign = TextAlign.start,
    @Deprecated('Use [beforeLaunch] instead.') this.onLinkTap,
    this.beforeLaunch,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CleanRichText(
      LinkTextSpans(
        text: text,
        textStyle: textStyle,
        linkStyle: linkStyle,
        hoverStyle: hoverStyle,
        // ignore: deprecated_member_use_from_same_package
        onLinkTap: onLinkTap,
        beforeLaunch: beforeLaunch ??
            // ignore: deprecated_member_use_from_same_package
            (onLinkTap != null
                ? (uri) {
                    // ignore: deprecated_member_use_from_same_package
                    onLinkTap?.call(uri.toString());
                    return false;
                  }
                : null),
        themeData: Theme.of(context),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
