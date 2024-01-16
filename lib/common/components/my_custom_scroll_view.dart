import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCustomScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final Widget inactiveWidget;
  final Widget pullToRefreshWidget;
  final Widget releaseToRefreshWidget;
  final Widget refreshWidget;
  final Widget refreshCompleteWidget;
  final BoxDecoration decoration;
  final Widget sliverAppBar;
  final Widget sliver;
  final Widget? loadMoreWidget;
  const MyCustomScrollView({
    super.key,
    required this.onRefresh,
    this.onLoadMore,
    this.inactiveWidget = const Text('下拉刷新'),
    this.pullToRefreshWidget = const Text('下拉刷新'),
    this.releaseToRefreshWidget = const Text('松开刷新'),
    this.refreshWidget = const CupertinoActivityIndicator(),
    this.refreshCompleteWidget = const Text('刷新完成'),
    this.decoration = const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.green],
      ),
    ),
    this.sliverAppBar = const SliverAppBar(
      title: Text('SliverAppBar'),
      floating: true,
      snap: true,
      flexibleSpace: Placeholder(),
      expandedHeight: 200,
    ),
    required this.sliver,
    this.loadMoreWidget = const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CupertinoActivityIndicator(),
      ),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      notificationPredicate: (notification) {
        return false;
      },
      child: NotificationListener(
        onNotification: onNotification,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            sliverAppBar,
            CupertinoSliverRefreshControl(
              onRefresh: onRefresh,
              builder: (context, refreshState, pulledExtent,
                  refreshTriggerPullDistance, refreshIndicatorExtent) {
                return Container(
                  alignment: Alignment.center,
                  height: pulledExtent,
                  decoration: decoration,
                  child: _buildRefreshIndicator(
                    refreshState,
                  ),
                );
              },
            ),
            sliver,
            if (onLoadMore != null && loadMoreWidget != null)
              SliverToBoxAdapter(
                child: loadMoreWidget,
              ),
          ],
        ),
      ),
    );
  }

  bool onNotification(notification) {
    if (onLoadMore != null && notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      // 检查是否滚动到底部
      if (metrics.pixels == metrics.maxScrollExtent) {
        onLoadMore!.call();
      }
    }
    return true;
  }

  Widget _buildRefreshIndicator(RefreshIndicatorMode refreshState) {
    switch (refreshState) {
      case RefreshIndicatorMode.drag:
        return pullToRefreshWidget;
      case RefreshIndicatorMode.armed:
        return releaseToRefreshWidget;
      case RefreshIndicatorMode.refresh:
        return refreshWidget;
      case RefreshIndicatorMode.done:
        return refreshCompleteWidget;
      default:
        return inactiveWidget;
    }
  }
}
