import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../controller/chat/chat_controller.dart';
import '../../../core/constant/color.dart';

class VoiceCallPage extends StatefulWidget {
  final String userID;
  final String roomID;
  final bool isIncoming;

  const VoiceCallPage({
    super.key,
    required this.userID,
    required this.roomID,
    this.isIncoming = false,
  });

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage>
    with TickerProviderStateMixin {
  late ChatController controller;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _volumeAnimationController;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    controller = ChatController.instance;

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _volumeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await controller.endVoiceCall();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: _buildGradientBackground(),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackgroundWaves(),
                      _buildMainContent(),
                    ],
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primaryColor.withOpacity(0.9),
          AppColor.primaryColor.withOpacity(0.7),
          AppColor.black.withOpacity(0.8),
          AppColor.black,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColor.white,
                size: 24.sp,
              ),
              onPressed: () {
                // تصغير المكالمة (يمكن إضافة هذه الميزة لاحقاً)
              },
            ),
          ),
          Obx(() => Text(
            controller.getFormattedCallDuration(),
            style: TextStyle(
              color: AppColor.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          )),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColor.white,
                size: 20.sp,
              ),
              onPressed: _showCallOptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWaves() {
    return Positioned.fill(
      child: Center(
        child: AnimatedBuilder(
          animation: _waveAnimationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: List.generate(4, (index) {
                final delay = index * 0.25;
                final animationValue = (_waveAnimationController.value + delay) % 1.0;
                final scale = 1.0 + (animationValue * 1.5);
                final opacity = 1.0 - animationValue;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.white.withOpacity(opacity * 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserAvatar(),
        SizedBox(height: 32.h),
        _buildUserInfo(),
        SizedBox(height: 24.h),
        _buildCallStatus(),
        SizedBox(height: 40.h),
        _buildVolumeIndicators(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimationController.value * 0.05),
          child: Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.white.withOpacity(0.3),
                  AppColor.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.white.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.userID.isNotEmpty ? widget.userID[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          widget.userID,
          style: TextStyle(
            color: AppColor.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          String statusText = '';
          Color statusColor = AppColor.white.withOpacity(0.8);

          switch (controller.callState.value) {
            case 'calling':
              statusText = 'جاري الاتصال...';
              break;
            case 'ringing':
              statusText = 'يرن...';
              break;
            case 'connected':
              statusText = 'متصل';
              statusColor = Colors.green;
              break;
            default:
              statusText = 'جاري الاتصال...';
          }

          return Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCallStatus() {
    return Obx(() {
      if (!controller.isCallConnected.value) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'جاري الاتصال...',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildVolumeIndicators() {
    return Obx(() {
      if (!controller.isCallConnected.value) return const SizedBox();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildVolumeIndicator(
            'أنت',
            controller.localVolume.value,
            controller.isMicrophoneOn.value,
          ),
          _buildVolumeIndicator(
            widget.userID,
            controller.remoteVolume.value,
            true,
          ),
        ],
      );
    });
  }

  Widget _buildVolumeIndicator(String label, double volume, bool isEnabled) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final barHeight = isEnabled ? (volume * 5).clamp(0, 5) : 0;
              final isActive = index < barHeight;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 3.w,
                height: isActive ? (8 + index * 4).h : 8.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColor.white
                      : AppColor.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.volume_up_rounded,
            isActive: () => controller.isSpeakerOn.value,
            onTap: controller.toggleSpeaker,
            activeColor: AppColor.white,
            inactiveColor: AppColor.white.withOpacity(0.6),
          ),
          _buildControlButton(
            icon: Icons.mic_rounded,
            isActive: () => controller.isMicrophoneOn.value,
            onTap: controller.toggleMicrophone,
            activeColor: AppColor.white,
            inactiveColor: Colors.red,
          ),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool Function() isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Obx(() {
      final active = isActive();
      return GestureDetector(
        onTap: () {
          _buttonAnimationController.forward().then((_) {
            _buttonAnimationController.reverse();
          });
          onTap();
        },
        child: AnimatedBuilder(
          animation: _buttonAnimationController,
          builder: (context, child) {
            final scale = 1.0 - (_buttonAnimationController.value * 0.1);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? activeColor : inactiveColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  active ? icon : (icon == Icons.mic_rounded ? Icons.mic_off_rounded : icon),
                  color: active ? activeColor : inactiveColor,
                  size: 28.sp,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () async {
        await controller.endVoiceCall();
      },
      child: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, child) {
          return Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.call_end_rounded,
              color: AppColor.white,
              size: 32.sp,
            ),
          );
        },
      ),
    );
  }

  void _showCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppColor.grey3,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildCallOption(
              Icons.volume_up_rounded,
              'تشغيل السماعة',
              controller.toggleSpeaker,
            ),
            _buildCallOption(
              Icons.mic_off_rounded,
              'كتم الصوت',
              controller.toggleMicrophone,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCallOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColor.lightGrey,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColor.grey2, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColor.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();
    _volumeAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }
}
