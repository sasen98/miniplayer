import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

class MyPopEntry extends PopEntry {
  MyPopEntry({required this.popNotifier, required this.popInvoked});
  final ValueListenable<bool> popNotifier;
  final PopInvokedCallback? popInvoked;
  @override
  ValueListenable<bool> get canPopNotifier => popNotifier;

  @override
  PopInvokedCallback? get onPopInvoked => popInvoked;
}

class MiniplayerWillPopScope extends StatefulWidget {
  const MiniplayerWillPopScope({
    Key? key,
    required this.child,
    required this.onWillPop,
  }) : super(key: key);

  final Widget child;
  final PopInvokedCallback onWillPop;

  @override
  _MiniplayerWillPopScopeState createState() => _MiniplayerWillPopScopeState();

  static _MiniplayerWillPopScopeState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MiniplayerWillPopScopeState>();
  }
}

class _MiniplayerWillPopScopeState extends State<MiniplayerWillPopScope> {
  ModalRoute<dynamic>? _route;

  _MiniplayerWillPopScopeState? _descendant;

  set descendant(state) {
    _descendant = state;
    updateRouteCallback();
  }

  PopEntry? onWillPop() {
    PopEntry? popEntry;
    if (_descendant != null) {
      popEntry = _descendant!.onWillPop();
    }
    if (popEntry == null || popEntry.canPopNotifier.value) {
      popEntry = MyPopEntry(
        popInvoked: widget.onWillPop,
        popNotifier: ValueNotifier<bool>(true),
      );
    }
    return popEntry;
  }

  void updateRouteCallback() {
    if (onWillPop() != null) {
      _route?.unregisterPopEntry(onWillPop()!);
      _route = ModalRoute.of(context);
      _route?.registerPopEntry(onWillPop()!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var parentGuard = MiniplayerWillPopScope.of(context);
    if (parentGuard != null) {
      parentGuard.descendant = this;
    }
    updateRouteCallback();
  }

  @override
  void dispose() {
    if (onWillPop() != null) {
      _route?.unregisterPopEntry(onWillPop()!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
