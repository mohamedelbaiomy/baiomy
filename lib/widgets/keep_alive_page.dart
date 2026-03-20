import 'package:flutter/material.dart';

class BaiomyKeepAlivePage extends StatefulWidget {
  const BaiomyKeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<BaiomyKeepAlivePage> createState() => _BaiomyKeepAlivePageState();
}

class _BaiomyKeepAlivePageState extends State<BaiomyKeepAlivePage>
    with AutomaticKeepAliveClientMixin<BaiomyKeepAlivePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
