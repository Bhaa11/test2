import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:record/record.dart';
import 'dart:async';

import 'message_manager.dart';

class ChatState {
// Reactive variables using GetX .obs
  final RxList<ZIMConversation> conversations = <ZIMConversation>[].obs;
  final RxList<ZIMMessage> messages = <ZIMMessage>[].obs;
  final RxList<ZIMConversation> archivedConversations = <ZIMConversation>[].obs;
  final RxList<ZIMMessage> starredMessages = <ZIMMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserID = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxMap<String, bool> userOnlineStatus = <String, bool>{}.obs;
  final RxMap<String, bool> messageReadStatus = <String, bool>{}.obs;
  final RxMap<String, bool> typingStatus = <String, bool>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxList<ZIMMessage> searchResults = <ZIMMessage>[].obs;

// متغيرات تسجيل الصوت
  final AudioRecorder audioRecorder = AudioRecorder();
  final RxBool isRecording = false.obs;
  final RxString recordingPath = ''.obs;
  final RxInt recordingDuration = 0.obs;

// متغيرات التحميل
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;
  final RxMap<String, bool> isDownloading = <String, bool>{}.obs;

// متغيرات المكالمات الصوتية - ZegoCloud
  final RxBool isInVoiceCall = false.obs;
  final RxBool isMicrophoneOn = true.obs;
  final RxBool isSpeakerOn = false.obs;
  final RxString currentCallUserID = ''.obs;
  final RxString currentRoomID = ''.obs;
  final RxInt callDuration = 0.obs;
  final RxBool isCallConnected = false.obs;
  final RxBool isCallConnecting = false.obs;
  final RxString callState = 'idle'.obs; // idle, calling, ringing, connected, ended
  final RxDouble localVolume = 0.0.obs;
  final RxDouble remoteVolume = 0.0.obs;
  final RxBool isZegoEngineInitialized = false.obs;

// متغيرات جديدة للميزات المطلوبة
  final RxMap<String, bool> blockedUsers = <String, bool>{}.obs;
  final RxMap<String, bool> blockedByMe = <String, bool>{}.obs; // جديد: لتتبع من قام بالحظر
  final RxMap<String, bool> mutedConversations = <String, bool>{}.obs;
  final RxMap<String, Map<String, dynamic>> conversationInfo = <String, Map<String, dynamic>>{}.obs;

// ZegoCloud Configuration - استخدم نفس القيم من main.dart
  static const int appID = 156821102;
  static const String appSign = "2fde9bdf21fc01dd44783d791afc1820fcb32940b5839c9ab066d335e9e99b9c";

// Timer للمكالمة
  Timer? callTimer;
  Timer? volumeTimer;

// إضافة مرجع لـ MessageManager
  MessageManager? messageManager;
}
