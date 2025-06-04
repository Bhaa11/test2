import 'package:ecommercecourse/core/constant/color.dart';
import 'package:flutter/material.dart';

class CustomButtonAppBar extends StatefulWidget {
  final String textbutton;
  final IconData icon;
  final IconData filledIcon;
  final VoidCallback onPressed;
  final bool active;

  const CustomButtonAppBar({
    super.key,
    required this.textbutton,
    required this.icon,
    required this.filledIcon,
    required this.onPressed,
    required this.active,
  });

  @override
  State<CustomButtonAppBar> createState() => _CustomButtonAppBarState();
}

class _CustomButtonAppBarState extends State<CustomButtonAppBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomButtonAppBar oldWidget) {
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        splashColor: AppColor.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.2,
            maxHeight: MediaQuery.of(context).size.height * 0.08,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: MediaQuery.of(context).size.width * 0.065,
                    color: widget.active
                        ? AppColor.primaryColor.withOpacity(0.2)
                        : AppColor.grey2,
                  ),
                  ScaleTransition(
                    scale: _animation,
                    child: Icon(
                      widget.filledIcon,
                      size: MediaQuery.of(context).size.width * 0.065,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  widget.textbutton,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w600,
                    color: widget.active
                        ? AppColor.primaryColor
                        : AppColor.grey2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}