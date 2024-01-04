import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:taskitty_flutter/common/extensions/extensions.dart';

class HorizontalTimeWidget extends StatefulWidget {
  const HorizontalTimeWidget({super.key});

  @override
  State<HorizontalTimeWidget> createState() => _HorizontalTimeWidgetState();
}

class _HorizontalTimeWidgetState extends State<HorizontalTimeWidget> {
  late int _focusedHour;
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _focusedHour = DateTime.now().hour;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemScrollController.jumpTo(index: _focusedHour);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      scrollDirection: Axis.horizontal,
      itemScrollController: _itemScrollController,
      itemCount: 24,
      separatorBuilder: (context, index) => const VerticalDivider(
        width: 1,
        color: Colors.black12,
      ),
      itemBuilder: (context, index) {
        final key = ValueKey('htw_$index');
        final textStyle = _focusedHour == index
            ? TextStyle(
                fontSize: 20,
                color: Colors.primaries[0],
                fontWeight: FontWeight.bold,
              )
            : const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              );
        final backgroundColor =
            _focusedHour == index ? Colors.black26 : Colors.transparent;
        return Text(
          '$index:00',
          key: key,
          style: textStyle,
        ).center().padding(all: 8).backgroundColor(backgroundColor).inkWell(
          onTap: () async {
            setState(() {
              _focusedHour = index;
            });
          },
        );
      },
    ).constrained(height: 60);
  }
}
