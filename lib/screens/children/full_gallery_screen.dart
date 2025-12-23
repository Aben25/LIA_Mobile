import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_colors.dart';
import '../../components/media_widget.dart';

class FullGalleryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> galleryMedia;
  final String childName;
  final int initialIndex;

  const FullGalleryScreen({
    super.key,
    required this.galleryMedia,
    required this.childName,
    this.initialIndex = 0,
  });

  @override
  State<FullGalleryScreen> createState() => _FullGalleryScreenState();
}

class _FullGalleryScreenState extends State<FullGalleryScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.childName}\'s Gallery',
          style: TextStyle(
            fontFamily: 'Specify',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        actions: [
          Text(
            '${_currentIndex + 1}/${widget.galleryMedia.length}',
            style: TextStyle(
              fontFamily: 'Specify',
              fontSize: 16,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Main image viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.galleryMedia.length,
              itemBuilder: (context, index) {
                final media = widget.galleryMedia[index];

                // Handle Strapi image structure
                String? imageUrl;
                final url = media['url'];
                if (url != null) {
                  imageUrl = url.startsWith('http')
                      ? url
                      : 'https://admin.loveinaction.co$url';
                }

                if (imageUrl == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            fontFamily: 'Specify',
                            fontSize: 18,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Check if it's a video
                final isVideo = imageUrl.toLowerCase().endsWith('.mp4') ||
                    imageUrl.toLowerCase().endsWith('.mov') ||
                    imageUrl.toLowerCase().endsWith('.avi') ||
                    imageUrl.toLowerCase().endsWith('.mkv') ||
                    imageUrl.toLowerCase().endsWith('.webm') ||
                    imageUrl.toLowerCase().endsWith('.m4v');

                if (isVideo) {
                  return Center(
                    child: MediaWidget(
                      url: imageUrl,
                      fit: BoxFit.contain,
                      showVideoControls: true,
                      autoPlay: false,
                      errorWidget: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load video',
                              style: TextStyle(
                                fontFamily: 'Specify',
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: MediaWidget(
                      url: imageUrl,
                      fit: BoxFit.contain,
                      showVideoControls: false,
                      errorWidget: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                fontFamily: 'Specify',
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Caption section
          if (widget.galleryMedia[_currentIndex]['caption'] != null &&
              widget.galleryMedia[_currentIndex]['caption']
                  .toString()
                  .isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                widget.galleryMedia[_currentIndex]['caption'].toString(),
                style: TextStyle(
                  fontFamily: 'Specify',
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Thumbnail navigation
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground,
                  width: 0.5,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.galleryMedia.length,
              itemBuilder: (context, index) {
                final media = widget.galleryMedia[index];
                final isSelected = index == _currentIndex;

                // Handle Strapi image structure
                String? imageUrl;
                final url = media['url'];
                if (url != null) {
                  imageUrl = url.startsWith('http')
                      ? url
                      : 'https://admin.loveinaction.co$url';
                }

                if (imageUrl == null) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 3)
                          : null,
                    ),
                    child: Icon(
                      Icons.image,
                      size: 32,
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _goToImage(index),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 3)
                          : Border.all(
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                              width: 1,
                            ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MediaWidget(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            showVideoControls: false,
                            errorWidget: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                              ),
                              child: Icon(
                                Icons.image,
                                size: 32,
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                              ),
                            ),
                          ),
                          // Video indicator overlay
                          if (imageUrl.toLowerCase().endsWith('.mp4') ||
                              imageUrl.toLowerCase().endsWith('.mov') ||
                              imageUrl.toLowerCase().endsWith('.avi') ||
                              imageUrl.toLowerCase().endsWith('.mkv') ||
                              imageUrl.toLowerCase().endsWith('.webm') ||
                              imageUrl.toLowerCase().endsWith('.m4v'))
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
