import 'package:flutter/material.dart';
import 'package:flutter_application_2/video_call/call_notification.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Ensure proper text direction is available for all children
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Main app content
          child,

          // Call notification overlay - positioned at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CallNotificationWidget(),
          ),
        ],
      ),
    );
  }
}
