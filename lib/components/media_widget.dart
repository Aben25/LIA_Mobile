import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_colors.dart';

/// A widget that displays either an image or video based on the URL extension
class MediaWidget extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showVideoControls;
  final bool autoPlay;

  const MediaWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.showVideoControls = true,
    this.autoPlay = false,
  });

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  bool _isVideoError = false;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _checkIfVideo();
  }

  void _checkIfVideo() {
    final url = widget.url.toLowerCase();
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    _isVideo = videoExtensions.any((ext) => url.endsWith(ext));

    if (_isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isVideoLoading = true;
      _isVideoError = false;
    });

    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoController!.initialize();

      if (widget.autoPlay) {
        _videoController!.play();
      }

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If it's a video
    if (_isVideo) {
      if (_isVideoLoading) {
        return widget.placeholder ??
            Container(
              color: AppColors.primary.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
      }

      if (_isVideoError || _videoController == null) {
        return widget.errorWidget ??
            Container(
              color: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.videocam_off,
                size: 48,
                color: AppColors.primary,
              ),
            );
      }

      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: widget.width != null && widget.height != null
                  ? SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
            ),
            if (widget.showVideoControls)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                    setState(() {});
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // If it's an image
    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ??
            Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Container(
              color: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.image_not_supported,
                size: 48,
                color: AppColors.primary,
              ),
            );
      },
    );
  }
}
