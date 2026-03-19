import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BaiomyLoadingItem extends StatelessWidget {
  final double height;

  const BaiomyLoadingItem({super.key, required this.height});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: Skeleton.leaf(
      child: Container(
        width: .infinity,
        height: height,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
