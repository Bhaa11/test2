// 1. إنشاء واجهة تسجيل الصوت: voice_recording_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../core/constant/color.dart';
import 'chat_controller.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final String conversationID;
  final dynamic conversationType;
  final VoidCallback onCancel;

  const VoiceRecordingWidget({
    super.key,
    required this.conversationID,
    required this.conversationType,
    required this.onCancel,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  Timer? _timer;
  int _recordingDuration = 0;
  bool _isLocked = false;
  double _slideOffset = 0.0;
  final double _lockThreshold = -100.0;
  final double _cancelThreshold = 100.0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _startRecording();
  }

  void _startRecording() {
    ChatController.instance.startRecording();
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _pulseController.stop();
    _waveController.stop();

    if (_recordingDuration >= 1) {
      ChatController.instance.stopRecording(widget.conversationID, widget.conversationType);
    }

    widget.onCancel();
  }

  void _cancelRecording() {
    _timer?.cancel();
    _pulseController.stop();
    _waveController.stop();
    ChatController.instance.isRecording.value = false;
    widget.onCancel();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.primaryColor.withOpacity(0.1),
            AppColor.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // شريط التحكم العلوي
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // أيقونة الإلغاء
                GestureDetector(
                  onTap: _cancelRecording,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // مؤشر التسجيل والوقت
                Expanded(
                  child: Row(
                    children: [
                      // نقطة التسجيل المتحركة
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(width: 12.w),

                      // نص التسجيل
                      Text(
                        'جاري التسجيل...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.grey2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      // عداد الوقت
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          _formatDuration(_recordingDuration),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // أيقونة القفل
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: _isLocked
                        ? AppColor.primaryColor.withOpacity(0.2)
                        : AppColor.lightGrey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    color: _isLocked ? AppColor.primaryColor : AppColor.grey2,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          // منطقة التحكم السفلية
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // موجات صوتية متحركة
                  ...List.generate(5, (index) {
                    return AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final animationValue = (_waveAnimation.value + delay) % 1.0;
                        final height = 20.h + (math.sin(animationValue * math.pi * 2) * 15.h);

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          width: 4.w,
                          height: height,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        );
                      },
                    );
                  }),

                  SizedBox(width: 20.w),

                  // زر الإرسال
                  GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.primaryColor, AppColor.secondColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColor.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }
}
