// 3. مدير المكالمات الصوتية: voice_call_manager.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'dart:async';
import 'dart:convert';

import '../../core/constant/color.dart';
import '../../view/screen/chat/video_call_page.dart';
import 'chat_state.dart';

class VoiceCallManager {
  final ChatState _state;

  VoiceCallManager(this._state);

  // ═══════════════ تهيئة ZegoCloud SDK ═══════════════
  Future<void> initializeZegoSDK() async {
    try {
      if (_state.isZegoEngineInitialized.value) {
        print('ZegoCloud SDK مهيأ مسبقاً');
        return;
      }

      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
        ChatState.appID,
        ZegoScenario.Communication,
        appSign: ChatState.appSign,
      ));

      ZegoExpressEngine.onRoomStateUpdate = _onRoomStateUpdate;
      ZegoExpressEngine.onRoomUserUpdate = _onRoomUserUpdate;
      ZegoExpressEngine.onPublisherStateUpdate = _onPublisherStateUpdate;
      ZegoExpressEngine.onPlayerStateUpdate = _onPlayerStateUpdate;
      ZegoExpressEngine.onCapturedSoundLevelUpdate = _onCapturedSoundLevelUpdate;
      ZegoExpressEngine.onRemoteSoundLevelUpdate = _onRemoteSoundLevelUpdate;
      ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;

      _state.isZegoEngineInitialized.value = true;
      print('ZegoCloud SDK تم تهيئته بنجاح');
    } catch (e) {
      print('خطأ في تهيئة ZegoCloud SDK: $e');
      _state.isZegoEngineInitialized.value = false;
    }
  }

  Future<bool> _ensureZegoEngineInitialized() async {
    if (!_state.isZegoEngineInitialized.value) {
      await initializeZegoSDK();
    }
    return _state.isZegoEngineInitialized.value;
  }

  // ═══════════════ ZegoCloud Event Handlers ═══════════════
  void _onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode, Map<String, dynamic> extendedData) {
    print('Room state update: $roomID, state: $state, error: $errorCode');

    if (state == ZegoRoomState.Connected) {
      _state.isCallConnected.value = true;
      _state.isCallConnecting.value = false;
      _state.callState.value = 'connected';
      _startCallTimer();
      _startVolumeMonitoring();
    } else if (state == ZegoRoomState.Disconnected) {
      if (_state.isInVoiceCall.value) {
        _endVoiceCall();
      }
    }
  }

  void _onRoomUserUpdate(String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
    print('Room user update: $roomID, type: $updateType, users: ${userList.length}');

    if (updateType == ZegoUpdateType.Add) {
      for (var user in userList) {
        if (user.userID != _state.currentUserID.value) {
          print('User joined: ${user.userID}');
        }
      }
    } else if (updateType == ZegoUpdateType.Delete) {
      for (var user in userList) {
        if (user.userID != _state.currentUserID.value) {
          print('User left: ${user.userID}');
          if (_state.isInVoiceCall.value) {
            _endVoiceCall();
          }
        }
      }
    }
  }

  void _onRoomStreamUpdate(String roomID, ZegoUpdateType updateType, List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    print('Room stream update: $roomID, type: $updateType, streams: ${streamList.length}');

    if (updateType == ZegoUpdateType.Add) {
      for (var stream in streamList) {
        if (stream.user.userID != _state.currentUserID.value) {
          ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
          print('Started playing stream: ${stream.streamID}');
        }
      }
    } else if (updateType == ZegoUpdateType.Delete) {
      for (var stream in streamList) {
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
        print('Stopped playing stream: ${stream.streamID}');
      }
    }
  }

  void _onPublisherStateUpdate(String streamID, ZegoPublisherState state, int errorCode, Map<String, dynamic> extendedData) {
    print('Publisher state update: $streamID, state: $state, error: $errorCode');
  }

  void _onPlayerStateUpdate(String streamID, ZegoPlayerState state, int errorCode, Map<String, dynamic> extendedData) {
    print('Player state update: $streamID, state: $state, error: $errorCode');
  }

  void _onCapturedSoundLevelUpdate(double soundLevel) {
    _state.localVolume.value = soundLevel;
  }

  void _onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    if (soundLevels.isNotEmpty) {
      _state.remoteVolume.value = soundLevels.values.first;
    }
  }

  // ═══════════════ المكالمات الصوتية ═══════════════

  Future<void> startVoiceCall(String targetUserID) async {
    try {
      if (_state.isInVoiceCall.value) {
        Get.snackbar('تنبيه', 'لديك مكالمة نشطة بالفعل');
        return;
      }

      if (!await _ensureZegoEngineInitialized()) {
        Get.snackbar('خطأ', 'فشل في تهيئة نظام المكالمات');
        return;
      }

      final callID = 'voice_${DateTime.now().millisecondsSinceEpoch}';
      final roomID = 'room_$callID';

      final config = ZIMCallInviteConfig();
      config.timeout = 60;
      config.extendedData = jsonEncode({
        "type": "voice_call",
        "callID": callID,
        "roomID": roomID
      });

      await ZIM.getInstance()!.callInvite([targetUserID], config);

      _state.currentCallUserID.value = targetUserID;
      _state.currentRoomID.value = roomID;
      _state.callState.value = 'calling';
      _state.isCallConnecting.value = true;

      Get.to(() => VoiceCallPage(
        userID: targetUserID,
        roomID: roomID,
        isIncoming: false,
      ));

      Get.snackbar('مكالمة صوتية', 'جاري الاتصال بـ $targetUserID...');

    } catch (e) {
      print('خطأ في بدء المكالمة الصوتية: $e');
      Get.snackbar('خطأ', 'فشل في بدء المكالمة الصوتية');
      _resetCallState();
    }
  }

  // ═══════════════ Call Invitation Handlers ═══════════════

  void onCallInvitationReceived(ZIM zim, ZIMCallInvitationReceivedInfo info, String callID) {
    try {
      final extendedData = info.extendedData;
      Map<String, dynamic>? callData;

      if (extendedData.isNotEmpty) {
        try {
          callData = jsonDecode(extendedData);
        } catch (e) {
          print('خطأ في تحليل بيانات المكالمة: $e');
        }
      }

      final roomID = callData?['roomID'] ?? 'room_$callID';
      _showIncomingCallDialog(info.inviter, callID, roomID);
    } catch (e) {
      print('خطأ في معالجة دعوة المكالمة: $e');
    }
  }

  void onCallInvitationAccepted(ZIM zim, ZIMCallInvitationAcceptedInfo info, String callID) {
    try {
      final extendedData = info.extendedData;
      Map<String, dynamic>? callData;

      if (extendedData.isNotEmpty) {
        try {
          callData = jsonDecode(extendedData);
        } catch (e) {
          print('خطأ في تحليل بيانات المكالمة: $e');
        }
      }

      final roomID = callData?['roomID'] ?? _state.currentRoomID.value;
      _joinVoiceCall(info.invitee, callID, roomID);
    } catch (e) {
      print('خطأ في معالجة قبول المكالمة: $e');
    }
  }

  void onCallInvitationRejected(ZIM zim, ZIMCallInvitationRejectedInfo info, String callID) {
    Get.snackbar('مكالمة مرفوضة', 'تم رفض المكالمة من ${info.invitee}');
    _resetCallState();
    if (Get.currentRoute.contains('VoiceCallPage')) {
      Get.back();
    }
  }

  void onCallInvitationCancelled(ZIM zim, ZIMCallInvitationCancelledInfo info, String callID) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    Get.snackbar('مكالمة ملغاة', 'تم إلغاء المكالمة');
    _resetCallState();
  }

  void onCallInvitationEnded(ZIM zim, ZIMCallInvitationEndedInfo info, String callID) {
    _endVoiceCall();
  }

  // ═══════════════ عرض حوار المكالمة الواردة ═══════════════

  void _showIncomingCallDialog(String callerID, String callID, String roomID) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColor.white,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.secondColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  callerID.isNotEmpty ? callerID[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callerID,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black,
                    ),
                  ),
                  Text(
                    'مكالمة صوتية واردة',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.grey2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.white, size: 30),
                  onPressed: () async {
                    Get.back();
                    await _rejectCall(callID);
                  },
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white, size: 30),
                  onPressed: () async {
                    Get.back();
                    await _acceptCall(callID, callerID, roomID);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ═══════════════ قبول/رفض المكالمة ═══════════════

  Future<void> _acceptCall(String callID, String callerID, String roomID) async {
    try {
      await ZIM.getInstance()!.callAccept(callID, ZIMCallAcceptConfig());

      _state.currentCallUserID.value = callerID;
      _state.currentRoomID.value = roomID;
      _state.callState.value = 'ringing';

      Get.to(() => VoiceCallPage(
        userID: callerID,
        roomID: roomID,
        isIncoming: true,
      ));

      await _joinVoiceCall(callerID, callID, roomID);
    } catch (e) {
      print('خطأ في قبول المكالمة: $e');
      _resetCallState();
    }
  }

  Future<void> _rejectCall(String callID) async {
    try {
      await ZIM.getInstance()!.callReject(callID, ZIMCallRejectConfig());
      _resetCallState();
    } catch (e) {
      print('خطأ في رفض المكالمة: $e');
    }
  }

  // ═══════════════ الانضمام للمكالمة ═══════════════

  Future<void> _joinVoiceCall(String userID, String callID, String roomID) async {
    try {
      if (!await _ensureZegoEngineInitialized()) {
        throw Exception('فشل في تهيئة نظام المكالمات');
      }

      _state.isInVoiceCall.value = true;
      _state.isCallConnecting.value = true;
      _state.currentCallUserID.value = userID;
      _state.currentRoomID.value = roomID;

      final user = ZegoUser(_state.currentUserID.value, _state.currentUserName.value);
      final roomConfig = ZegoRoomConfig.defaultConfig();
      roomConfig.isUserStatusNotify = true;

      await ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig);
      await ZegoExpressEngine.instance.startPublishingStream('${_state.currentUserID.value}_audio');
      await ZegoExpressEngine.instance.muteMicrophone(!_state.isMicrophoneOn.value);
      await ZegoExpressEngine.instance.muteSpeaker(!_state.isSpeakerOn.value);

      print('تم الانضمام للمكالمة الصوتية: $roomID');

    } catch (e) {
      print('خطأ في الانضمام للمكالمة: $e');
      _state.isInVoiceCall.value = false;
      _state.isCallConnecting.value = false;
      Get.snackbar('خطأ', 'فشل في الانضمام للمكالمة: ${e.toString()}');
    }
  }

  // ═══════════════ إنهاء المكالمة ═══════════════

  Future<void> endVoiceCall() async {
    try {
      if (_state.isInVoiceCall.value && _state.currentRoomID.value.isNotEmpty) {
        await ZIM.getInstance()!.callEnd(_state.currentRoomID.value, ZIMCallEndConfig());
      }
      await _endVoiceCall();
    } catch (e) {
      print('خطأ في إنهاء المكالمة: $e');
      await _endVoiceCall();
    }
  }

  Future<void> _endVoiceCall() async {
    try {
      if (_state.isInVoiceCall.value && _state.isZegoEngineInitialized.value) {
        await ZegoExpressEngine.instance.stopPublishingStream();
        await ZegoExpressEngine.instance.logoutRoom(_state.currentRoomID.value);
      }

      _stopCallTimer();
      _stopVolumeMonitoring();
      _resetCallState();

      if (Get.currentRoute.contains('VoiceCallPage')) {
        Get.back();
      }
    } catch (e) {
      print('خطأ في تنظيف حالة المكالمة: $e');
    }
  }

  void _resetCallState() {
    _state.isInVoiceCall.value = false;
    _state.isCallConnected.value = false;
    _state.isCallConnecting.value = false;
    _state.isMicrophoneOn.value = true;
    _state.isSpeakerOn.value = false;
    _state.currentCallUserID.value = '';
    _state.currentRoomID.value = '';
    _state.callDuration.value = 0;
    _state.callState.value = 'idle';
    _state.localVolume.value = 0.0;
    _state.remoteVolume.value = 0.0;
  }

  // ═══════════════ التحكم في الصوت ═══════════════

  Future<void> toggleMicrophone() async {
    try {
      if (!_state.isZegoEngineInitialized.value) return;

      _state.isMicrophoneOn.value = !_state.isMicrophoneOn.value;
      await ZegoExpressEngine.instance.muteMicrophone(!_state.isMicrophoneOn.value);
      print('Microphone ${_state.isMicrophoneOn.value ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('خطأ في التحكم بالميكروفون: $e');
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      if (!_state.isZegoEngineInitialized.value) return;

      _state.isSpeakerOn.value = !_state.isSpeakerOn.value;
      await ZegoExpressEngine.instance.muteSpeaker(!_state.isSpeakerOn.value);
      print('Speaker ${_state.isSpeakerOn.value ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('خطأ في التحكم بالسماعة: $e');
    }
  }

  // ═══════════════ عداد وقت المكالمة ═══════════════

  void _startCallTimer() {
    _state.callTimer?.cancel();
    _state.callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.isInVoiceCall.value && _state.isCallConnected.value) {
        _state.callDuration.value++;
      }
    });
  }

  void _stopCallTimer() {
    _state.callTimer?.cancel();
    _state.callTimer = null;
  }

  void _startVolumeMonitoring() {
    _state.volumeTimer?.cancel();
    _state.volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_state.isInVoiceCall.value) {
        timer.cancel();
      }
    });
  }

  void _stopVolumeMonitoring() {
    _state.volumeTimer?.cancel();
    _state.volumeTimer = null;
  }

  String getFormattedCallDuration() {
    final minutes = _state.callDuration.value ~/ 60;
    final seconds = _state.callDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _state.callTimer?.cancel();
    _state.volumeTimer?.cancel();

    if (_state.isZegoEngineInitialized.value) {
      ZegoExpressEngine.destroyEngine();
      _state.isZegoEngineInitialized.value = false;
    }
  }
}
