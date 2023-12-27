import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_tools/sliver_tools.dart';

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;
  _SliverPersistentHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

extension SliverWidgetExtension on Widget {
  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);

  SliverFillRemaining toSliverFillRemaining() =>
      SliverFillRemaining(child: this);

  SliverPersistentHeader toSliverPersistentHeader({
    Key? key,
    required double minExtent,
    required double maxExtent,
    Widget? child,
  }) =>
      SliverPersistentHeader(
        key: key,
        delegate: _SliverPersistentHeaderDelegate(
          minExtent: minExtent,
          maxExtent: maxExtent,
          child: child ?? this,
        ),
      );
}

extension SliverListExtension on List<Widget> {
  MultiSliver toMultiSliver() => MultiSliver(children: this);

  SliverList toSliverList() =>
      SliverList(delegate: SliverChildListDelegate(this));

  SliverFixedExtentList toSliverFixedExtentList({
    required double itemExtent,
  }) =>
      SliverFixedExtentList(
        delegate: SliverChildListDelegate(this),
        itemExtent: itemExtent,
      );

  SliverPrototypeExtentList toSliverPrototypeExtentList({
    required Widget prototypeItem,
  }) =>
      SliverPrototypeExtentList(
        delegate: SliverChildListDelegate(this),
        prototypeItem: prototypeItem,
      );

  SliverVariedExtentList toSliverVariedExtentList({
    required double Function(int, SliverLayoutDimensions) itemExtent,
  }) =>
      SliverVariedExtentList(
        delegate: SliverChildListDelegate(this),
        itemExtentBuilder: itemExtent,
      );

  SliverGrid toSliverGrid({
    required int crossAxisCount,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) =>
      SliverGrid(
        delegate: SliverChildListDelegate(this),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio ?? 1,
          crossAxisSpacing: crossAxisSpacing ?? 0,
          mainAxisSpacing: mainAxisSpacing ?? 0,
        ),
      );
}

extension SliverExtensions on SingleChildRenderObjectWidget {
  SliverOpacity sliverOpacity({Key? key, double opacity = 1.0}) =>
      SliverOpacity(key: key, opacity: opacity, sliver: this);

  SliverIgnorePointer sliverIgnorePointer({Key? key, bool ignoring = true}) =>
      SliverIgnorePointer(key: key, ignoring: ignoring, sliver: this);

  SliverOffstage sliverOffstage({Key? key, bool offstage = true}) =>
      SliverOffstage(key: key, offstage: offstage, sliver: this);

  SliverFillRemaining toSliverFillRemainingWithScrollable({
    Key? key,
    ScrollPhysics? physics,
    ScrollController? controller,
    Axis? axisDirection,
    bool fillOverscroll = true,
    bool hasScrollBody = true,
    Clip? clipBehavior,
  }) =>
      SliverFillRemaining(
        key: key,
        fillOverscroll: fillOverscroll,
        hasScrollBody: hasScrollBody,
        child: SingleChildScrollView(
          physics: physics,
          controller: controller,
          scrollDirection: axisDirection ?? Axis.vertical,
          reverse: axisDirection == Axis.vertical ||
              axisDirection == Axis.horizontal,
          padding: EdgeInsets.zero,
          primary: false,
          clipBehavior: clipBehavior ?? Clip.hardEdge,
          child: this,
        ),
      );

  SliverVisibility sliverVisibility({
    Key? key,
    Widget replacementSliver = const SliverToBoxAdapter(),
    bool visible = true,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) =>
      SliverVisibility(
        key: key,
        sliver: this,
        replacementSliver: replacementSliver,
        visible: visible,
        maintainState: maintainState,
        maintainAnimation: maintainAnimation,
        maintainSize: maintainSize,
        maintainSemantics: maintainSemantics,
        maintainInteractivity: maintainInteractivity,
      );

  SliverSafeArea sliverSafeArea({
    Key? key,
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
  }) =>
      SliverSafeArea(
        key: key,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        minimum: minimum,
        sliver: this,
      );

  SliverPadding sliverPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) =>
      SliverPadding(
        padding: EdgeInsets.only(
          top: top ?? vertical ?? all ?? 0,
          bottom: bottom ?? vertical ?? all ?? 0,
          left: left ?? horizontal ?? all ?? 0,
          right: right ?? horizontal ?? all ?? 0,
        ),
        sliver: this,
      );
}
