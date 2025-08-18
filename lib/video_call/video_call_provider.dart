import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

// Video Call State Management for Patient
class PatientVideoCallProvider extends ChangeNotifier {
  // WebRTC connections
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // UI state
  bool _isCallIncoming = false;
  bool _isCallInProgress = false;
  bool _isCallConnected = false;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isMicPermissionGranted = false;
  bool _isCameraPermissionGranted = false;
  CallStatus _callStatus = CallStatus.idle;
  bool _isNotification = false;
  StreamSubscription? _callStatusSubscription;

  // User IDs
  final String patientId;
  String? _currentDoctorId;

  // Call metadata
  String? _doctorName;
  String? _callReason;

  // Getters
  bool get isCallIncoming => _isCallIncoming;
  bool get isNotification => _isNotification;
  bool get isCallInProgress => _isCallInProgress;
  bool get isCallConnected => _isCallConnected;
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isMicPermissionGranted => _isMicPermissionGranted;
  bool get isCameraPermissionGranted => _isCameraPermissionGranted;
  CallStatus get callStatus => _callStatus;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  String? get currentDoctorId => _currentDoctorId;
  String? get doctorName => _doctorName;
  String? get callReason => _callReason;

  // Firebase references
  late CollectionReference _callsCollection;
  StreamSubscription? _callSubscription;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      },
      // {
      //   'urls': [
      //     'stun:stun.webrtc.org:3478',
      //     'stun:stun1.webrtc.org:3478',
      //     'stun:stun2.webrtc.org:3478'
      //   ]
      // }
    ],
    'sdpSemantics': 'unified-plan',
    'iceCandidatePoolSize': 10,
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
  };

  PatientVideoCallProvider({required this.patientId}) {
    if (patientId == 'guest') {
      print('Patient ID cannot be empty');
      return;
    }
    print(
        '==========================================================================================[PVCPROVIDER] Initializing with patientId: $patientId');
    _callsCollection = FirebaseFirestore.instance.collection('video_calls');
    _listenForIncomingCalls();
    checkForEndedCalls();
    print(
        '=======================================================================[PVCPROVIDER] Provider initialized and listening for calls');
  }

  // Listen for incoming call requests
  void _listenForIncomingCalls() {
    print(FirebaseAuth.instance.currentUser?.uid);
    print('[PVCPROVIDER] Setting up listener for incoming calls');
    // Query for calls where this patient is the recipient
    var query = _callsCollection
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'offering')
        .orderBy('timestamp', descending: true)
        .limit(1);

    print(
        '[PVCPROVIDER] Query parameters - patientId: $patientId, status: offering');

    _callSubscription = query.snapshots().listen((snapshot) {
      print(
          '[PVCPROVIDER] Received call snapshot with ${snapshot.docs.length} documents');
      if (snapshot.docs.isEmpty) {
        print('[PVCPROVIDER] No incoming calls found');
        _isNotification = false;
        notifyListeners();
        return;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      print('[PVCPROVIDER] Incoming call data: ${data.toString()}');

      // Extract doctor information
      _currentDoctorId = data['doctorId'];
      _doctorName = data['doctorName'] ?? 'Doctor';
      _callReason = data['reason'] ?? 'Medical Consultation';

      print(
          '[PVCPROVIDER] Incoming call from doctor: $_doctorName (ID: $_currentDoctorId), reason: $_callReason');

      // Set call status
      _isCallIncoming = true;
      _isNotification = true;
      _callStatus = CallStatus.incoming;
      print('[PVCPROVIDER] Call status updated to: $_callStatus');
      notifyListeners();
    }, onError: (error) {
      print('[PVCPROVIDER] Error in call listener: $error');
    });
  }

  // Open user media (almost identical to doctor's implementation)
  // Open user media - Fixed implementation
  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    print('[PVCPROVIDER] Opening user media streams');

    // Verify renderers are initialized
    if (localVideo.textureId == null || remoteVideo.textureId == null) {
      throw Exception('Video renderers not initialized');
    }

    // Clear previous stream if it exists
    if (_localStream != null) {
      print('[PVCPROVIDER] Stopping previous local stream tracks');
      _localStream!.getTracks().forEach((track) => track.stop());
      _localStream = null;
      print("[PVCPROVIDER] Previous local stream stopped.");
    }

    // Also stop any existing tracks on the renderers
    print('[PVCPROVIDER] Cleaning up any existing renderer tracks');
    if (localVideo.srcObject != null) {
      localVideo.srcObject?.getTracks().forEach((t) => t.stop());
      localVideo.srcObject = null;
    }

    if (remoteVideo.srcObject != null) {
      remoteVideo.srcObject?.getTracks().forEach((t) => t.stop());
      remoteVideo.srcObject = null;
    }

    try {
      // Create a combined stream first
      final combinedStream = await createLocalMediaStream('combined');

      // Request camera permissions and get video stream
      print('[PVCPROVIDER] Requesting video permission');
      try {
        final videoStream = await navigator.mediaDevices.getUserMedia({
          'video': {
            'facingMode': 'user',
            'optional': [
              {'minWidth': 640},
              {'minHeight': 480},
              {'maxFrameRate': 30},
            ],
          }
        });

        print(
            "[PVCPROVIDER] Video stream obtained with ${videoStream.getVideoTracks().length} tracks");

        // Add all video tracks to combined stream
        for (var track in videoStream.getVideoTracks()) {
          print('[PVCPROVIDER] Adding video track: ${track.id}');
          combinedStream.addTrack(track);
        }

        _isCameraPermissionGranted = true;
      } catch (e) {
        print("[PVCPROVIDER] Error getting video: $e");
        _isCameraPermissionGranted = false;
      }

      // Request microphone permissions and get audio stream
      print('[PVCPROVIDER] Requesting audio permission');
      try {
        final audioStream =
            await navigator.mediaDevices.getUserMedia({'audio': true});

        print(
            "[PVCPROVIDER] Audio stream obtained with ${audioStream.getAudioTracks().length} tracks");

        // Add all audio tracks to combined stream
        for (var track in audioStream.getAudioTracks()) {
          print('[PVCPROVIDER] Adding audio track: ${track.id}');
          combinedStream.addTrack(track);
        }

        _isMicPermissionGranted = true;
      } catch (e) {
        print("[PVCPROVIDER] Error getting audio: $e");
        _isMicPermissionGranted = false;
      }

      // Check if we got any tracks
      if (combinedStream.getTracks().isEmpty) {
        throw Exception('Failed to get any media tracks');
      }

      // Assign to local stream variable and renderer
      _localStream = combinedStream;
      print(
          '[PVCPROVIDER] Local stream now has ${_localStream?.getTracks().length} tracks');

      // Make sure to wait a moment before assigning to the renderer
      await Future.delayed(Duration(milliseconds: 100));

      // Set the stream to the renderer
      print('[PVCPROVIDER] Setting stream to local video renderer');
      localVideo.srcObject = _localStream;

      // Initialize remote stream if needed
      if (remoteVideo.srcObject == null) {
        print('[PVCPROVIDER] Setting up remote video renderer');
        final remoteStream = await createLocalMediaStream('remote');
        remoteVideo.srcObject = remoteStream;
        _remoteStream = remoteStream;
      }

      // Notify listeners of state change
      notifyListeners();

      print(
          '[PVCPROVIDER] Media setup complete - Camera: $_isCameraPermissionGranted, Mic: $_isMicPermissionGranted');
    } catch (e) {
      print("[PVCPROVIDER] Error in openUserMedia: $e");
      _isCameraPermissionGranted = false;
      _isMicPermissionGranted = false;
      notifyListeners();
      throw e; // Re-throw to let caller handle
    }
  }

  // Register peer connection listeners
  void _registerPeerConnectionListeners() {
    print('[PVCPROVIDER] Registering peer connection listeners');
    if (_peerConnection == null) {
      print(
          '[PVCPROVIDER] WARNING: Attempted to register listeners on null peer connection');
      return;
    }

    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('[PVCPROVIDER] ICE gathering state changed: $state');
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('[PVCPROVIDER] Connection state change: $state');

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('[PVCPROVIDER] Call successfully connected!');
        _isCallConnected = true;
        _callStatus = CallStatus.connected;
        notifyListeners();

        // Add confirmation log to verify connection is working
        print(
            '[PVCPROVIDER] WebRTC connection established - SDP exchange successful');
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        print('[PVCPROVIDER] Call connection in progress...');
        _callStatus = CallStatus.connecting;
        notifyListeners();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print('[PVCPROVIDER] Call connection failed');
        _callStatus = CallStatus.failed;
        notifyListeners();
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        print('[PVCPROVIDER] Call disconnected');
        _callStatus = CallStatus.failed;
        notifyListeners();
      }
    };

    _peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('[PVCPROVIDER] Signaling state change: $state');

      // Log when signaling is stable (negotiation complete)
      if (state == RTCSignalingState.RTCSignalingStateStable) {
        print(
            '[PVCPROVIDER] Signaling stable - offer/answer exchange complete');
      }
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('[PVCPROVIDER] ICE connection state change: $state');

      // Track ICE connection success/failure
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        print('[PVCPROVIDER] ICE connection established successfully');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        print(
            '[PVCPROVIDER] ICE connection failed - likely connectivity issues');
        _callStatus = CallStatus.failed;
        notifyListeners();
      }
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      print(
          "[PVCPROVIDER] Added remote stream with ${stream.getTracks().length} tracks");
      _remoteStream = stream;
      print(
          '[PVCPROVIDER] Remote stream tracks: Audio: ${_remoteStream?.getAudioTracks().length}, Video: ${_remoteStream?.getVideoTracks().length}');
      notifyListeners();
    };
  }

  // Accept the incoming call
  // In the acceptCall method, enhance the error handling:
  // Accept the incoming call - Fixed version
  // Listen for call status changes (doctor ending the call)
  // Updated listener function with proper subscription management
  void _listenForCallStatusChanges() {
    print('[PVCPROVIDER] Setting up listener for call status changes');

    // Cancel any existing subscription first
    if (_callStatusSubscription != null) {
      print('[PVCPROVIDER] Cancelling previous call status subscription');
      _callStatusSubscription!.cancel();
      _callStatusSubscription = null;
    }

    // Only listen if we're in a call
    if (_currentDoctorId == null || _callStatus == CallStatus.idle) {
      print('[PVCPROVIDER] No active call to monitor');
      return;
    }

    var callDocRef = _callsCollection.doc('${_currentDoctorId}_$patientId');

    // Set up listener for the current call document
    _callStatusSubscription = callDocRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        print('[PVCPROVIDER] Call document no longer exists');
        _handleDoctorEndedCall();
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final callStatus = data['status'] as String?;

      print('[PVCPROVIDER] Call status update detected: $callStatus');

      // Handle different status changes
      if (callStatus == 'ended' &&
          (_isCallInProgress || _isCallConnected || _isCallIncoming)) {
        print('[PVCPROVIDER] Doctor ended the call');
        _handleDoctorEndedCall();
      } else if (callStatus == 'cancelled' && _isCallIncoming) {
        print(
            '[PVCPROVIDER] Doctor cancelled the call before patient answered');
        _handleDoctorEndedCall();
      }
    }, onError: (error) {
      print('[PVCPROVIDER] Error in call status listener: $error');
    });
  }

// Handle call ended by doctor
  // Update _handleDoctorEndedCall to cancel the subscription
  Future<void> _handleDoctorEndedCall() async {
    print('[PVCPROVIDER] Handling call ended by doctor');

    // Cancel the call status subscription
    if (_callStatusSubscription != null) {
      print('[PVCPROVIDER] Cancelling call status subscription');
      _callStatusSubscription!.cancel();
      _callStatusSubscription = null;
    }

    // Only proceed if we're in a call
    if (!_isCallInProgress && !_isCallConnected && !_isCallIncoming) {
      print('[PVCPROVIDER] No active call to handle');
      return;
    }

    // Clean up resources using existing methods
    if (_isCallConnected || _isCallInProgress) {
      // If we're in an active call, use the existing cleanup
      await endCall();
      navigatorKey.currentState?.pop();
    } else if (_isCallIncoming) {
      // If it's just an incoming call notification, clean up the state
      _isCallIncoming = false;
      _isNotification = false;
      _callStatus = CallStatus.ended;
      _currentDoctorId = null;
      notifyListeners();
    }

    // Show a temporary notification that the doctor ended the call
    // Only if we were in an active call (not just at incoming stage)
    if (_isCallConnected || _isCallInProgress) {
      _isNotification = true;
      _callStatus = CallStatus.ended;
      notifyListeners();

      // Auto-dismiss the notification after a few seconds
      Future.delayed(Duration(seconds: 5), () {
        if (_callStatus == CallStatus.ended) {
          _isNotification = false;
          _callStatus = CallStatus.idle;
          notifyListeners();
        }
      });
    }
  }

  Future<void> acceptCall(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    print('[PVCPROVIDER] Attempting to accept call');
    if (!_isCallIncoming || _currentDoctorId == null) {
      print(
          '[PVCPROVIDER] Cannot accept call: isCallIncoming=$_isCallIncoming, doctorId=$_currentDoctorId');
      return;
    }

    print('[PVCPROVIDER] Accepting call from doctor: $_currentDoctorId');
    _callStatus = CallStatus.initializing;
    _isCallInProgress = true;
    _isNotification = false;
    notifyListeners();

    try {
      // Verify renderers are initialized
      if (localVideo.textureId == null || remoteVideo.textureId == null) {
        print('[PVCPROVIDER] ERROR: Renderers not initialized');
        _callStatus = CallStatus.failed;
        notifyListeners();
        return;
      }

      // First ensure we have media permissions
      try {
        print('[PVCPROVIDER] Opening user media for call');
        await openUserMedia(localVideo, remoteVideo);

        // Add a short delay to ensure media is ready
        await Future.delayed(Duration(milliseconds: 200));
      } catch (mediaError) {
        print('[PVCPROVIDER] Error setting up media: $mediaError');
        _callStatus = CallStatus.permissionDenied;
        notifyListeners();
        return;
      }

      if (!_isMicPermissionGranted || !_isCameraPermissionGranted) {
        print(
            '[PVCPROVIDER] Call failed - missing permissions. Mic: $_isMicPermissionGranted, Camera: $_isCameraPermissionGranted');
        _callStatus = CallStatus.permissionDenied;
        notifyListeners();
        return;
      }

      // Create peer connection
      print('[PVCPROVIDER] Creating peer connection');
      _peerConnection = await createPeerConnection(configuration);
      print(
          '[PVCPROVIDER] Peer connection created: ${_peerConnection != null}');

      _registerPeerConnectionListeners();

      // Set up ICE candidates collection for this call
      var callDocRef = _callsCollection.doc('${_currentDoctorId}_$patientId');
      print('[PVCPROVIDER] Setting up ICE candidate exchange');
      CollectionReference candidatesCollection =
          callDocRef.collection('calleeCandidates');

      // Add local ICE candidates to DB
      _peerConnection!.onIceCandidate = (candidate) async {
        if (candidate == null) {
          print('[PVCPROVIDER] onIceCandidate complete');
          return;
        }
        print('[PVCPROVIDER] Adding local ICE candidate');
        await candidatesCollection.add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      };

      // Verify local stream is available
      if (_localStream == null || _localStream!.getTracks().isEmpty) {
        print('[PVCPROVIDER] Error: Local stream not available or empty');
        _callStatus = CallStatus.failed;
        notifyListeners();
        return;
      }

      // Add local tracks to peer connection
      print('[PVCPROVIDER] Adding local tracks to peer connection');
      try {
        print(
            '[PVCPROVIDER] Adding ${_localStream!.getTracks().length} tracks to peer connection');

        List<MediaStreamTrack> tracksToAdd = _localStream!.getTracks();
        for (var track in tracksToAdd) {
          print('[PVCPROVIDER] Adding track: ${track.kind} (${track.id})');
          await _peerConnection?.addTrack(track, _localStream!);
        }
      } catch (trackError) {
        print('[PVCPROVIDER] Error adding tracks: $trackError');
        _callStatus = CallStatus.failed;
        notifyListeners();
        return;
      }

      // Set up remote video renderer
      if (_remoteStream == null) {
        print('[PVCPROVIDER] Setting up remote video renderer');
        _remoteStream = await createLocalMediaStream('remote');

        // Ensure renderer has the stream
        if (remoteVideo.srcObject != _remoteStream) {
          remoteVideo.srcObject = _remoteStream;
        }
      }

      // Update call status
      _callStatus = CallStatus.connecting;
      notifyListeners();

      // Get the call doc
      print(
          '[PVCPROVIDER] Retrieving call document: ${_currentDoctorId}_$patientId');

      // Use a transaction to ensure document integrity
      bool success = await FirebaseFirestore.instance
          .runTransaction<bool>((transaction) async {
        DocumentSnapshot callDoc = await transaction.get(callDocRef);

        if (!callDoc.exists) {
          print('[PVCPROVIDER] Call document no longer exists');
          return false;
        }

        Map<String, dynamic> callData = callDoc.data() as Map<String, dynamic>;

        // Check if the call is still active
        if (callData['status'] != 'offering') {
          print('[PVCPROVIDER] Call is no longer in offering state');
          return false;
        }

        // Process SDP offer
        if (callData['offer'] != null) {
          print('[PVCPROVIDER] Processing SDP offer from transaction');

          // We'll set the remote description outside the transaction
          // Just verify the offer exists and continue
          return true;
        } else {
          print('[PVCPROVIDER] Error: No offer in call document');
          return false;
        }
      });

      if (!success) {
        print('[PVCPROVIDER] Transaction failed');
        _callStatus = CallStatus.failed;
        notifyListeners();
        return;
      }

      // Get the document again outside the transaction
      DocumentSnapshot callDoc = await callDocRef.get();
      Map<String, dynamic> callData = callDoc.data() as Map<String, dynamic>;

      // Process SDP offer
      print('[PVCPROVIDER] Processing SDP offer');
      var offer = RTCSessionDescription(
        callData['offer']['sdp'],
        callData['offer']['type'],
      );

      // Set remote description (doctor's offer)
      print('[PVCPROVIDER] Setting remote description (doctor\'s offer)');
      await _peerConnection?.setRemoteDescription(offer);

      // Create answer
      print('[PVCPROVIDER] Creating answer');
      RTCSessionDescription answer = await _peerConnection!.createAnswer();

      // Set local description (our answer)
      print('[PVCPROVIDER] Setting local description (our answer)');
      await _peerConnection!.setLocalDescription(answer);

      // Update call document with answer - using a specific method for reliability
      bool answerSuccess = await _sendAnswerToDoctor(callDocRef, answer);

      if (!answerSuccess) {
        print('[PVCPROVIDER] Failed to send answer to doctor');
        _callStatus = CallStatus.failed;
        notifyListeners();
        return;
      }

      // Listen for remote ICE candidates
      callDocRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            print('[PVCPROVIDER] Got new remote ICE candidate');
            Map<String, dynamic> data =
                change.doc.data() as Map<String, dynamic>;
            _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });
      });
      _listenForCallStatusChanges();
    } catch (e) {
      print('[PVCPROVIDER] Error in acceptCall: $e');
      _callStatus = CallStatus.failed;
      _isCallInProgress = false;
      notifyListeners();
    }
  }

  Future<void> checkForEndedCalls() async {
    print('[PVCPROVIDER] Checking for calls that were ended by the doctor');

    if (_currentDoctorId == null || _callStatus == CallStatus.idle) {
      print('[PVCPROVIDER] No active call to check');
      return;
    }

    try {
      var callDocRef = _callsCollection.doc('${_currentDoctorId}_$patientId');
      var callDoc = await callDocRef.get();

      if (!callDoc.exists) {
        print('[PVCPROVIDER] Call document no longer exists');
        _handleDoctorEndedCall();
        return;
      }

      final data = callDoc.data() as Map<String, dynamic>;
      final callStatus = data['status'] as String?;

      if (callStatus == 'ended' || callStatus == 'cancelled') {
        print(
            '[PVCPROVIDER] Found call ended by doctor while patient was away');
        _handleDoctorEndedCall();
      }
    } catch (e) {
      print('[PVCPROVIDER] Error checking for ended calls: $e');
    }
  }

  Future<bool> _sendAnswerToDoctor(
      DocumentReference callDocRef, RTCSessionDescription answer) async {
    try {
      print('[PVCPROVIDER] Updating call with answer');

      // Retry mechanism for updating the Firestore document
      int maxRetries = 3;
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          await callDocRef.update({
            'answer': {
              'type': answer.type,
              'sdp': answer.sdp,
            },
            'status': 'answered',
          });

          print('[PVCPROVIDER] Successfully sent answer to doctor');
          return true;
        } catch (e) {
          print(
              '[PVCPROVIDER] Error sending answer (attempt ${attempt + 1}): $e');

          if (attempt < maxRetries - 1) {
            // Wait before retrying
            await Future.delayed(Duration(milliseconds: 500));
            print('[PVCPROVIDER] Retrying answer update...');
          }
        }
      }

      print('[PVCPROVIDER] Failed to send answer after $maxRetries attempts');
      return false;
    } catch (e) {
      print('[PVCPROVIDER] Critical error in _sendAnswerToDoctor: $e');
      return false;
    }
  }

  // Reject the incoming call
  Future<void> rejectCall() async {
    print('[PVCPROVIDER] Rejecting incoming call');
    if (!_isCallIncoming || _currentDoctorId == null) {
      print(
          '[PVCPROVIDER] Cannot reject call: isCallIncoming=$_isCallIncoming, doctorId=$_currentDoctorId');
      return;
    }

    try {
      print('[PVCPROVIDER] Updating call document to rejected status');
      var callDocRef = _callsCollection.doc('${_currentDoctorId}_$patientId');
      await callDocRef.update({'status': 'rejected'});
      print('[PVCPROVIDER] Call successfully rejected in Firebase');
    } catch (e) {
      print('[PVCPROVIDER] Error rejecting call: $e');
    }

    // Cancel the call status subscription
    if (_callStatusSubscription != null) {
      print('[PVCPROVIDER] Cancelling call status subscription on reject');
      _callStatusSubscription!.cancel();
      _callStatusSubscription = null;
    }

    _isCallIncoming = false;
    _isNotification = false;
    _callStatus = CallStatus.idle;
    _currentDoctorId = null;
    print('[PVCPROVIDER] Call rejection complete, status: $_callStatus');
    notifyListeners();
  }

  // End ongoing call
  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    print('[PVCPROVIDER] Hanging up call');

    if (localVideo.srcObject != null) {
      print('[PVCPROVIDER] Stopping local video tracks');
      List<MediaStreamTrack> tracks = localVideo.srcObject?.getTracks() ?? [];
      print('[PVCPROVIDER] Found ${tracks.length} tracks to stop');
      tracks.forEach((track) {
        print('[PVCPROVIDER] Stopping track: ${track.kind} (${track.id})');
        track.stop();
      });
    } else {
      print('[PVCPROVIDER] No local video tracks to stop');
    }

    // Cancel the call status subscription
    if (_callStatusSubscription != null) {
      print('[PVCPROVIDER] Cancelling call status subscription on hangup');
      _callStatusSubscription!.cancel();
      _callStatusSubscription = null;
    }

    if (_remoteStream != null) {
      print('[PVCPROVIDER] Stopping remote stream tracks');
      _remoteStream!.getTracks().forEach((track) {
        print(
            '[PVCPROVIDER] Stopping remote track: ${track.kind} (${track.id})');
        track.stop();
      });
    } else {
      print('[PVCPROVIDER] No remote stream to stop');
    }

    if (_peerConnection != null) {
      print('[PVCPROVIDER] Closing peer connection');
      _peerConnection!.close();
    } else {
      print('[PVCPROVIDER] No peer connection to close');
    }

    if (_currentDoctorId != null) {
      print('[PVCPROVIDER] Updating call status in Firebase');
      var db = FirebaseFirestore.instance;
      var roomRef = _callsCollection.doc('${_currentDoctorId}_$patientId');

      try {
        // Update call status
        await roomRef.update({'status': 'ended'});
        print('[PVCPROVIDER] Call status updated to ended in Firebase');
      } catch (e) {
        print('[PVCPROVIDER] Error updating call status: $e');
      }
    } else {
      print('[PVCPROVIDER] No doctor ID, skipping Firebase update');
    }

    _isCallIncoming = false;
    _isNotification = false;
    _isCallInProgress = false;
    _isCallConnected = false;
    _callStatus = CallStatus.idle;
    _currentDoctorId = null;
    print('[PVCPROVIDER] Call ended, status reset to: $_callStatus');

    notifyListeners();
  }

  // End ongoing call (simplified version)
  Future<void> endCall() async {
    print(
        '[PVCPROVIDER] Ending call - isCallInProgress: $_isCallInProgress, isCallIncoming: $_isCallIncoming');
    if (!_isCallInProgress && !_isCallIncoming) {
      print('[PVCPROVIDER] No active call to end');
      return;
    }

    // Stop all tracks in local stream
    if (_localStream != null) {
      print(
          '[PVCPROVIDER] Stopping ${_localStream!.getTracks().length} local tracks');
      _localStream!.getTracks().forEach((track) {
        print(
            '[PVCPROVIDER] Stopping local track: ${track.kind} (${track.id})');
        track.stop();
      });
    } else {
      print('[PVCPROVIDER] No local stream to stop');
    }

    // Create a temporary renderer for the hangUp call if needed
    print('[PVCPROVIDER] Creating temporary renderer for hangUp');
    RTCVideoRenderer tempRenderer = RTCVideoRenderer();
    await tempRenderer.initialize();
    if (_localStream != null) {
      print('[PVCPROVIDER] Assigning local stream to temp renderer');
      tempRenderer.srcObject = _localStream;
    }

    print('[PVCPROVIDER] Calling hangUp with temp renderer');
    await hangUp(tempRenderer);

    // Clean up temp renderer
    print('[PVCPROVIDER] Disposing temp renderer');
    await tempRenderer.dispose();
    print('[PVCPROVIDER] Call end process completed');
  }

  // Toggle audio mute/unmute
  void toggleAudio() {
    print('[PVCPROVIDER] Toggling audio');
    if (_localStream == null) {
      print('[PVCPROVIDER] Cannot toggle audio - local stream is null');
      return;
    }

    final audioTracks = _localStream!.getAudioTracks();
    print('[PVCPROVIDER] Found ${audioTracks.length} audio tracks');
    if (audioTracks.isNotEmpty) {
      _isAudioEnabled = !_isAudioEnabled;
      print('[PVCPROVIDER] Setting audio enabled: $_isAudioEnabled');
      audioTracks.first.enabled = _isAudioEnabled;
      notifyListeners();
    } else {
      print('[PVCPROVIDER] No audio tracks to toggle');
    }
  }

  // Toggle video on/off
  void toggleVideo() {
    print('[PVCPROVIDER] Toggling video');
    if (_localStream == null) {
      print('[PVCPROVIDER] Cannot toggle video - local stream is null');
      return;
    }

    final videoTracks = _localStream!.getVideoTracks();
    print('[PVCPROVIDER] Found ${videoTracks.length} video tracks');
    if (videoTracks.isNotEmpty) {
      _isVideoEnabled = !_isVideoEnabled;
      print('[PVCPROVIDER] Setting video enabled: $_isVideoEnabled');
      videoTracks.first.enabled = _isVideoEnabled;
      notifyListeners();
    } else {
      print('[PVCPROVIDER] No video tracks to toggle');
    }
  }

  // Request permissions
  // Request permissions - improved implementation
  Future<bool> requestPermissions() async {
    print(
        '[PVCPROVIDER] Explicitly requesting camera and microphone permissions');

    // First check if permissions are already granted
    var micStatus = await Permission.microphone.status;
    var cameraStatus = await Permission.camera.status;

    print(
        '[PVCPROVIDER] Current permission status - Mic: $micStatus, Camera: $cameraStatus');

    // Request missing permissions
    if (!micStatus.isGranted) {
      print('[PVCPROVIDER] Requesting microphone permission');
      micStatus = await Permission.microphone.request();
      print('[PVCPROVIDER] Microphone permission result: $micStatus');
    }

    if (!cameraStatus.isGranted) {
      print('[PVCPROVIDER] Requesting camera permission');
      cameraStatus = await Permission.camera.request();
      print('[PVCPROVIDER] Camera permission result: $cameraStatus');
    }

    // Update internal state based on results
    _isMicPermissionGranted = micStatus.isGranted;
    _isCameraPermissionGranted = cameraStatus.isGranted;

    print(
        '[PVCPROVIDER] Final permission status - Mic: $_isMicPermissionGranted, Camera: $_isCameraPermissionGranted');

    // Only if both permissions are granted, try to open media
    if (_isMicPermissionGranted && _isCameraPermissionGranted) {
      print(
          '[PVCPROVIDER] Both permissions granted, initializing temporary renderers');
      RTCVideoRenderer tempLocalRenderer = RTCVideoRenderer();
      RTCVideoRenderer tempRemoteRenderer = RTCVideoRenderer();

      await tempLocalRenderer.initialize();
      await tempRemoteRenderer.initialize();

      try {
        // Test if we can actually access the media
        print('[PVCPROVIDER] Testing media access');
        await openUserMedia(tempLocalRenderer, tempRemoteRenderer);
        print('[PVCPROVIDER] Media access successful');
      } catch (e) {
        print('[PVCPROVIDER] Error accessing media despite permissions: $e');
        _isMicPermissionGranted = false;
        _isCameraPermissionGranted = false;
      } finally {
        // Clean up
        print('[PVCPROVIDER] Disposing temporary renderers');
        await tempLocalRenderer.dispose();
        await tempRemoteRenderer.dispose();
      }
    }

    // Notify listeners about permission state changes
    notifyListeners();

    return _isMicPermissionGranted && _isCameraPermissionGranted;
  }

  @override
  void dispose() {
    print('[PVCPROVIDER] Disposing provider');
    endCall();
    if (_callSubscription != null) {
      print('[PVCPROVIDER] Cancelling call subscription');
      _callSubscription?.cancel();
    }
    if (_callStatusSubscription != null) {
      print('[PVCPROVIDER] Cancelling call status subscription');
      _callStatusSubscription?.cancel();
    }
    print('[PVCPROVIDER] Provider disposed');
    super.dispose();
  }
}

// Call status enum
enum CallStatus {
  idle,
  incoming,
  permissionDenied,
  initializing,
  connecting,
  connected,
  rejected,
  ended,
  failed,
}
