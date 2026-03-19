import 'package:flutter/material.dart';

extension FormAutoScroll on GlobalKey<FormState> {
  bool validateAndScroll() {
    final bool isValid = currentState?.validate() ?? false;
    if (!isValid) {
      Element? firstErrorElement;

      void finaFirstError(Element element) {
        if (firstErrorElement != null) return;

        if (element.widget is FormField) {
          final State<StatefulWidget> state =
              (element as StatefulElement).state;
          if (state is FormFieldState && state.hasError) {
            firstErrorElement = element;
            return;
          }
        }
        element.visitChildren(finaFirstError);
      }

      currentContext?.visitChildElements(finaFirstError);
      if (firstErrorElement != null) {
        Scrollable.ensureVisible(
          firstErrorElement!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }
    return isValid;
  }
}
