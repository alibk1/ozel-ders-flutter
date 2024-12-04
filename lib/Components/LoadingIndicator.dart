import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator {
  final BuildContext context;

  LoadingIndicator(this.context);

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Color(0xFF222831),
            size: 80,
          ),
        );
      },
    );
  }
}
