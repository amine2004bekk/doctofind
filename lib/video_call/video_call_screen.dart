import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/video_call/video_call_provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _renderersInitialized = false;
  bool _callStarted = false;
  bool _isDisposing = false; // Flag to track disposal state

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    // Initialize both renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Ensure we're still mounted before updating state
    if (mounted) {
      setState(() {
        _renderersInitialized = true;
      });

      // Only start the call after renderers are fully initialized
      // Use a slight delay to ensure renderers are ready
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _startCallIfReady();
        }
      });
    }
  }

  void _startCallIfReady() {
    if (!_renderersInitialized || _callStarted) return;

    final provider =
        Provider.of<PatientVideoCallProvider>(context, listen: false);
    if (provider.isCallIncoming) {
      setState(() {
        _callStarted = true;
      });
      // Now accept the call with fully initialized renderers
      provider.acceptCall(_localRenderer, _remoteRenderer);
    }
  }

  // Safe navigation helper
  void _safePopNavigation() {
    if (!_isDisposing && mounted && navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState?.pop();
    }
  }

  @override
  void dispose() {
    _isDisposing = true; // Set flag before any async operations

    // Handle call ending in synchronous context
    try {
      final provider =
          Provider.of<PatientVideoCallProvider>(context, listen: false);
      if (provider.isCallInProgress || provider.isCallConnected) {
        provider.endCall();
      }
    } catch (e) {
      // Handle any errors silently - we're already disposing
      debugPrint('Error during disposal: $e');
    }

    // Dispose renderers
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent accidentally leaving the call screen with back button
        if (_isDisposing) return true; // Allow pop if already disposing

        final provider =
            Provider.of<PatientVideoCallProvider>(context, listen: false);
        if (provider.isCallInProgress || provider.isCallConnected) {
          // Show confirmation dialog
          bool shouldPop = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('End Call?'),
                  content: Text('Are you sure you want to end the call?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await provider.endCall();
                        navigatorKey.currentState
                            ?.pop(); // Return true to allow pop
                      },
                      child:
                          Text('End Call', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ) ??
              false;
          return shouldPop;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<PatientVideoCallProvider>(
          builder: (context, provider, child) {
            // Set streams to renderers when available
            if (_renderersInitialized) {
              if (provider.localStream != null &&
                  _localRenderer.srcObject != provider.localStream) {
                _localRenderer.srcObject = provider.localStream;
              }
              if (provider.remoteStream != null &&
                  _remoteRenderer.srcObject != provider.remoteStream) {
                _remoteRenderer.srcObject = provider.remoteStream;
              }
            }

            // Handle call ended or rejected state with delayed navigation
            if (provider.callStatus == CallStatus.ended ||
                provider.callStatus == CallStatus.rejected) {
              // Schedule navigation for the next frame to avoid build errors
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _safePopNavigation();
              });
            }

            return SafeArea(
              child: Stack(
                children: [
                  // Status screens based on call state
                  _buildCallStatusScreen(provider),

                  // Call controls at bottom (if in a call)
                  if (provider.callStatus == CallStatus.connected ||
                      provider.callStatus == CallStatus.connecting)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildCallControls(provider),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCallStatusScreen(PatientVideoCallProvider provider) {
    // Handle different call states
    switch (provider.callStatus) {
      case CallStatus.initializing:
      case CallStatus.connecting:
        return _buildConnectingScreen(provider);

      case CallStatus.connected:
        return _buildConnectedCallScreen(provider);

      case CallStatus.failed:
        return _buildCallFailedScreen();

      case CallStatus.permissionDenied:
        return _buildPermissionDeniedScreen();

      case CallStatus.ended:
      case CallStatus.rejected:
        // Return a simple loading screen while waiting for navigation
        return Center(
            child: Text('Call ended', style: TextStyle(color: Colors.white)));

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing video call...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildConnectingScreen(PatientVideoCallProvider provider) {
    return Stack(
      children: [
        // Show local video as background while connecting
        if (_renderersInitialized && provider.localStream != null)
          Positioned.fill(
            child: RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
          ),

        // Overlay with connecting status
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  provider.callStatus == CallStatus.initializing
                      ? 'Initializing call...'
                      : 'Connecting to doctor...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedCallScreen(PatientVideoCallProvider provider) {
    return Stack(
      children: [
        // Remote video (full screen)
        if (_renderersInitialized && provider.remoteStream != null)
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
          ),

        // Local video (picture-in-picture)
        if (_renderersInitialized && provider.localStream != null)
          Positioned(
            top: 20,
            right: 20,
            width: 120,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RTCVideoView(
                  _localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
              ),
            ),
          ),

        // Doctor name overlay
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black54,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  provider.doctorName ?? 'Doctor',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallFailedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'Call Failed',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            'Unable to connect to the doctor',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _safePopNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Return', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            color: Colors.orange,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'Permissions Required',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Camera and microphone access is needed for video calls',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              final provider =
                  Provider.of<PatientVideoCallProvider>(context, listen: false);
              bool granted = await provider.requestPermissions();
              if (mounted) {
                if (granted) {
                  provider.acceptCall(_localRenderer, _remoteRenderer);
                } else {
                  // Still denied, go back
                  provider.endCall();
                  _safePopNavigation();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Allow Access', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              final provider =
                  Provider.of<PatientVideoCallProvider>(context, listen: false);
              provider.endCall();
              _safePopNavigation();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(PatientVideoCallProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: provider.isAudioEnabled ? Icons.mic : Icons.mic_off,
            label: provider.isAudioEnabled ? 'Mute' : 'Unmute',
            backgroundColor:
                provider.isAudioEnabled ? Colors.grey[700]! : Colors.red,
            onPressed: () => provider.toggleAudio(),
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            backgroundColor: Colors.red,
            onPressed: () async {
              await provider.endCall();
              if (mounted) {
                _safePopNavigation();
              }
            },
          ),
          _buildControlButton(
            icon: provider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            label: provider.isVideoEnabled ? 'Stop Video' : 'Start Video',
            backgroundColor:
                provider.isVideoEnabled ? Colors.grey[700]! : Colors.red,
            onPressed: () => provider.toggleVideo(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
