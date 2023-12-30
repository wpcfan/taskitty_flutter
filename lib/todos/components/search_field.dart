import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

/// 顶部导航栏的标题位置组件
class SearchFieldWidget extends StatefulWidget {
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final int debounceTime;
  final TextStyle placeholderStyle;
  final Icon prefixIcon;
  final Color backgroundColor;
  final TextStyle style;
  const SearchFieldWidget({
    super.key,
    this.onSubmitted,
    this.onChanged,
    this.debounceTime = 300,
    this.placeholderStyle = const TextStyle(color: Colors.white30),
    this.prefixIcon = const Icon(Icons.search, color: Colors.white),
    this.backgroundColor = Colors.black12,
    this.style = const TextStyle(color: Colors.white),
  });

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  final _searchQueryController = TextEditingController();
  final _searchQuerySubject = BehaviorSubject<String>();

  @override
  void initState() {
    super.initState();
    _searchQuerySubject.stream
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen((query) {
      if (widget.onChanged != null) {
        widget.onChanged!(query);
      }
    });
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _searchQuerySubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: AppLocalizations.of(context)!.searchPlaceholder,
      placeholderStyle: widget.placeholderStyle,
      prefixIcon: widget.prefixIcon,
      backgroundColor: widget.backgroundColor,
      style: widget.style,
      onChanged: (query) {
        _searchQuerySubject.add(query);
      },
      onSubmitted: widget.onSubmitted,
    );
  }
}
