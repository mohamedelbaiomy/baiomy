import 'package:flutter/material.dart';

// Box(height: 20)
// class Box extends StatelessWidget {
//   final double? width;
//   final double? height;
//
//   const Box({super.key, this.width, this.height});
//
//   const Box.square(double dimension, {super.key})
//     : width = dimension,
//       height = dimension;
//
//   const Box.shrink({super.key}) : width = 0, height = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(width: width, height: height);
//   }
// }

// 15.boxH
extension BoxExtension on num {
  SizedBox get box => .new(width: toDouble(), height: toDouble());

  SizedBox get boxW => .new(width: toDouble());

  SizedBox get boxH => .new(height: toDouble());
}

// extension NullableBoxExtension on Null {
//   SizedBox get box => const SizedBox.shrink();
// }

// Spacing.md
class Spacing {
  // static const SizedBox xs = SizedBox(height: 4, width: 4);
  // static const SizedBox sm = SizedBox(height: 8, width: 8);
  // static const SizedBox md = SizedBox(height: 16, width: 16);
  // static const SizedBox lg = SizedBox(height: 24, width: 24);
  // static const SizedBox xl = SizedBox(height: 32, width: 32);

  static const SizedBox shrink = .shrink();

  static SizedBox height(double h) => .new(height: h);

  static SizedBox width(double w) => .new(width: w);
}
