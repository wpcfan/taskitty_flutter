import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../common/common.dart';

class TagsWidget extends StatefulWidget {
  final List<String> initialTags;
  final List<String> topTags;
  final String? helperText;
  final Color inputBorderColor;
  final Color focusBorderColor;
  final Color tagBorderColor;
  final Color helperTextColor;
  final Color deleteIconColor;
  final double inputBorderWidth;
  final double focusBorderWidth;
  final TextStyle topTagsHintTextStyle;
  final Function(String)? onSelected;
  final Function(List<String>)? onTagChanged;

  const TagsWidget({
    super.key,
    this.initialTags = const [],
    this.topTags = const [],
    this.helperText,
    this.inputBorderColor = Colors.grey,
    this.focusBorderColor = Colors.purple,
    this.tagBorderColor = Colors.purple,
    this.helperTextColor = Colors.purple,
    this.deleteIconColor = Colors.white38,
    this.inputBorderWidth = 3.0,
    this.focusBorderWidth = 3.0,
    this.topTagsHintTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
    ),
    this.onSelected,
    this.onTagChanged,
  });

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  late double _distanceToField;
  late TextfieldTagsController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
  }

  @override
  Widget build(BuildContext context) {
    final tagInput = TextFieldTags(
      textfieldTagsController: _controller,
      initialTags: widget.initialTags,
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      validator: (String tag) {
        if ((_controller.getTags ?? []).contains(tag)) {
          return AppLocalizations.of(context)!.duplicateTagError;
        }
        return null;
      },
      inputfieldBuilder: inputFieldBuilder,
    );
    final topTagsList = widget.topTags
        .map((tag) => tag.toChip(
              onPressed: () {
                _controller.addTag = tag;
                widget.onTagChanged?.call(_controller.getTags ?? []);
              },
            ))
        .toList()
        .toWrap(
          spacing: 5.0,
          runSpacing: 5.0,
        );
    return [
      tagInput.expanded(),
      if (widget.topTags.isNotEmpty)
        Text(
          AppLocalizations.of(context)!.topTagsHintText,
          style: widget.topTagsHintTextStyle,
        ).expanded(),
      if (widget.topTags.isNotEmpty) topTagsList.expanded(),
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
    );
  }

  TagsBuilder<dynamic> inputFieldBuilder(
      context, tec, fn, error, onChanged, onSubmitted) {
    return ((context, sc, tags, onTagDelete) {
      final decoration = BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
        color: widget.tagBorderColor,
      );

      deleteIcon(tag) => Icon(
            Icons.cancel,
            size: 14.0,
            color: widget.deleteIconColor,
          ).inkWell(onTap: () {
            onTagDelete(tag);
            widget.onTagChanged?.call(_controller.getTags ?? []);
          });

      tagSelected(tag) => Text(
            '#$tag',
            style: const TextStyle(color: Colors.white),
          ).inkWell(onTap: () {
            widget.onSelected?.call(tag);
          });

      toElement(String tag) => Container(
          decoration: decoration,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: [
            tagSelected(tag),
            const SizedBox(width: 4.0),
            deleteIcon(tag),
          ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween));

      final prefixIcon = tags
          .map(toElement)
          .toList()
          .toRow()
          .scrollable(controller: sc, scrollDirection: Axis.horizontal);

      final inputBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: widget.inputBorderColor,
          width: widget.inputBorderWidth,
        ),
      );

      final focusBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: widget.focusBorderColor,
          width: widget.focusBorderWidth,
        ),
      );

      final helperStyle = TextStyle(
        color: widget.helperTextColor,
      );

      return TextField(
        controller: tec,
        focusNode: fn,
        decoration: InputDecoration(
          isDense: true,
          border: inputBorder,
          focusedBorder: focusBorder,
          helperText: widget.helperText,
          helperStyle: helperStyle,
          hintText: _controller.hasTags
              ? ''
              : AppLocalizations.of(context)!.tagsHintText,
          errorText: error,
          prefixIconConstraints:
              BoxConstraints(maxWidth: _distanceToField * 0.74),
          prefixIcon: tags.isNotEmpty ? prefixIcon : null,
        ),
        onChanged: (tag) {
          onChanged(tag);
          widget.onTagChanged?.call(_controller.getTags ?? []);
        },
        onSubmitted: onSubmitted,
      );
    });
  }
}
