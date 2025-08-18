import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart'; // Ensure this imports navigatorKey
import 'package:flutter_application_2/video_call/video_call_provider.dart';
import 'package:flutter_application_2/video_call/video_call_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CallNotificationWidget extends StatefulWidget {
  const CallNotificationWidget({Key? key}) : super(key: key);

  @override
  State<CallNotificationWidget> createState() => _CallNotificationWidgetState();
}

class _CallNotificationWidgetState extends State<CallNotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PatientVideoCallProvider>(
      builder: (context, provider, child) {
        // Only show when there's an incoming call
        if (provider.isNotification == false) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Incoming Video Call',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From: ${provider.doctorName ?? 'Doctor'}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (provider.callReason != null)
                                Text(
                                  'Reason: ${provider.callReason}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.call_end,
                          label: 'Decline',
                          color: Colors.red,
                          onTap: () {
                            provider.rejectCall();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.videocam,
                          label: 'Accept',
                          color: Colors.green,
                          onTap: () async {
                            // Request permissions first
                            bool hasPermissions =
                                await provider.requestPermissions();

                            if (hasPermissions) {
                              // Use the global navigatorKey to push the route
                              // This fixes the navigation context issue
                              print('========================================' +
                                  navigatorKey.currentState.toString());
                              if (navigatorKey.currentState != null) {
                                // Navigate to the VideoCallScreen

                                navigatorKey.currentState!.push(
                                  MaterialPageRoute(
                                    builder: (context) => VideoCallScreen(),
                                  ),
                                );
                              } else {
                                // Fallback error handling if navigatorKey is not available
                                print(
                                    "Error: Navigator key's current state is null");

                                // Show a fallback message or toast notification
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Unable to start call. Please try again."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              // Show permission denied dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Permission Required'),
                                  content: Text(
                                      'Camera and microphone permissions are needed for video calls.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        provider.rejectCall();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
