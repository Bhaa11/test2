// 2. مشغل الصوت المدمج: voice_message_player.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:io';

import '../../../core/constant/color.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioPath;
  final int duration;
  final bool isMe;

  const VoiceMessagePlayer({
    super.key,
    required this.audioPath,
    required this.duration,
    required this.isMe,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _playController;
  late AnimationController _waveController;

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _playController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.stopped && _currentPosition == Duration.zero;
        });

        if (_isPlaying) {
          _playController.forward();
          _waveController.repeat();
          _startPositionTimer();
        } else {
          _playController.reverse();
          _waveController.stop();
          _stopPositionTimer();
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentPosition = Duration.zero;
          _isPlaying = false;
        });
        _playController.reverse();
        _waveController.stop();
        _stopPositionTimer();
      }
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isPlaying && mounted) {
        setState(() {});
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          if (File(widget.audioPath).existsSync()) {
            await _audioPlayer.play(DeviceFileSource(widget.audioPath));
          } else {
            Get.snackbar('خطأ', 'ملف الصوت غير موجود');
            return;
          }
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('خطأ في تشغيل الصوت: $e');
      Get.snackbar('خطأ', 'فشل في تشغيل الرسالة الصوتية');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.isMe
            ? AppColor.white.withOpacity(0.2)
            : AppColor.lightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // زر التشغيل/الإيقاف
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: widget.isMe ? AppColor.white : AppColor.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isMe ? AppColor.white : AppColor.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isMe ? AppColor.primaryColor : AppColor.white,
                  ),
                ),
              )
                  : AnimatedBuilder(
                animation: _playController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _playController.value * 0.5,
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: widget.isMe ? AppColor.primaryColor : AppColor.white,
                      size: 20.sp,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // الموجات الصوتية والتقدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الموجات الصوتية
                SizedBox(
                  height: 20.h,
                  child: Row(
                    children: List.generate(20, (index) {
                      return AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          final progress = _getProgress();
                          final isActive = (index / 20) <= progress;
                          final waveHeight = _isPlaying
                              ? (8.h + (index % 3) * 4.h) * (0.5 + _waveController.value * 0.5)
                              : 4.h + (index % 3) * 2.h;

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            width: 2.w,
                            height: waveHeight,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (widget.isMe ? AppColor.white : AppColor.primaryColor)
                                  : (widget.isMe ? AppColor.white.withOpacity(0.3) : AppColor.grey2),
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

                SizedBox(height: 4.h),

                // شريط التقدم والوقت
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _getProgress(),
                        backgroundColor: widget.isMe
                            ? AppColor.white.withOpacity(0.3)
                            : AppColor.grey3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isMe ? AppColor.white : AppColor.primaryColor,
                        ),
                        minHeight: 2.h,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isPlaying || _currentPosition > Duration.zero
                          ? _formatDuration(_currentPosition)
                          : _formatDuration(_totalDuration.inSeconds > 0
                          ? _totalDuration
                          : Duration(seconds: widget.duration)),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: widget.isMe
                            ? AppColor.white.withOpacity(0.8)
                            : AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // أيقونة الميكروفون
          Icon(
            Icons.mic,
            size: 16.sp,
            color: widget.isMe
                ? AppColor.white.withOpacity(0.6)
                : AppColor.grey2,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    _playController.dispose();
    _waveController.dispose();
    super.dispose();
  }
}
