import 'package:flutter/material.dart';
import 'dart:math'; // IMPORT INI YANG HILANG
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum LoadingType { 
  circular, 
  linear, 
  dots, 
  shimmer, 
  skeleton,
  fullscreen,
  overlay 
}

class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double? size;
  final bool showMessage;

  const LoadingWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return _buildCircularLoading();
      case LoadingType.linear:
        return _buildLinearLoading();
      case LoadingType.dots:
        return _buildDotsLoading();
      case LoadingType.shimmer:
        return _buildShimmerLoading();
      case LoadingType.skeleton:
        return _buildSkeletonLoading();
      case LoadingType.fullscreen:
        return _buildFullscreenLoading();
      case LoadingType.overlay:
        return _buildOverlayLoading();
    }
  }

  Widget _buildCircularLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppSizes.spaceM),
            Text(
              message!,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinearLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
          backgroundColor: (color ?? AppColors.primary).withOpacity(0.2),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: AppSizes.spaceM),
          Text(
            message!,
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDotsLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotsLoadingAnimation(
            color: color ?? AppColors.primary,
            size: size ?? 12,
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppSizes.spaceM),
            Text(
              message!,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return _ShimmerLoading(
      child: Column(
        children: List.generate(3, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Container(
                        height: 12,
                        width: double.infinity * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(AppSizes.paddingM),
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Container(
                          height: 12,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullscreenLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildCircularLoading(),
    );
  }

  Widget _buildOverlayLoading() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: _buildCircularLoading(),
    );
  }
}

// Dots Loading Animation - PERBAIKAN DENGAN IMPORT MATH
class _DotsLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<_DotsLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            // PERBAIKAN: Menggunakan sin dan pi dari dart:math
            final scale = (sin(animationValue * pi) * 0.5) + 0.5;
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Shimmer Loading Effect
class _ShimmerLoading extends StatefulWidget {
  final Widget child;

  const _ShimmerLoading({required this.child});

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Specific Loading Widgets
class InvoiceLoadingWidget extends StatelessWidget {
  const InvoiceLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      type: LoadingType.circular,
      message: 'Memuat invoice...',
    );
  }
}

class AnalyticsLoadingWidget extends StatelessWidget {
  const AnalyticsLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      type: LoadingType.shimmer,
      message: 'Memuat data analytics...',
    );
  }
}

class PdfGeneratingWidget extends StatelessWidget {
  const PdfGeneratingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      type: LoadingType.dots,
      message: 'Membuat PDF...',
    );
  }
}
