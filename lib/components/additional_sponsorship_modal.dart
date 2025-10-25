import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../utils/network_error_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/strapi_auth_provider.dart';

class AdditionalSponsorshipModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final int sponsorId;
  final String sponsorEmail;
  final VoidCallback? onSuccess;

  const AdditionalSponsorshipModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.sponsorId,
    required this.sponsorEmail,
    this.onSuccess,
  });

  @override
  State<AdditionalSponsorshipModal> createState() =>
      _AdditionalSponsorshipModalState();
}

class _AdditionalSponsorshipModalState
    extends State<AdditionalSponsorshipModal> {
  int _numberOfChildren = 1;
  bool _isSubmitting = false;
  String? _submitStatus; // 'success' or 'error'
  String _errorMessage = '';

  int get _totalCost => _numberOfChildren * 25;

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _submitStatus = null;
      _errorMessage = '';
    });

    try {
      // Get JWT token from auth provider
      final auth = Provider.of<StrapiAuthProvider>(context, listen: false);
      final jwt = auth.jwt;

      debugPrint('🔍 [AdditionalSponsorshipModal] Starting submission...');
      debugPrint(
          '🔍 [AdditionalSponsorshipModal] Sponsor ID: ${widget.sponsorId}');
      debugPrint(
          '🔍 [AdditionalSponsorshipModal] Sponsor Email: ${widget.sponsorEmail}');
      debugPrint(
          '🔍 [AdditionalSponsorshipModal] Number of Children: $_numberOfChildren');
      debugPrint(
          '🔍 [AdditionalSponsorshipModal] JWT available: ${jwt != null && jwt.isNotEmpty}');

      if (jwt == null || jwt.isEmpty) {
        throw Exception('Authentication required');
      }

      if (widget.sponsorId == 0) {
        throw Exception(
            'Invalid sponsor information. Please try refreshing the app.');
      }

      // Call API to update sponsorship request
      final response = await http.post(
        Uri.parse('https://admin.loveinaction.co/api/sponsorships'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'data': {
            'sponsorshipStatus': 'submitted',
            'numberOfChildren': _numberOfChildren,
            'sponsor': widget.sponsorId,
          }
        }),
      );

      debugPrint(
          '🔍 [AdditionalSponsorshipModal] Response status: ${response.statusCode}');
      debugPrint(
          '🔍 [AdditionalSponsorshipModal] Response body: ${response.body}');

      if (!response.statusCode.toString().startsWith('2')) {
        final errorData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw Exception(
            errorData['error'] ?? 'HTTP error! status: ${response.statusCode}');
      }

      final result = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
      debugPrint('🔍 [AdditionalSponsorshipModal] Success result: $result');

      setState(() {
        _submitStatus = 'success';
      });

      // Call success callback and close modal after delay
      Future.delayed(const Duration(seconds: 2), () {
        widget.onSuccess?.call();
        widget.onClose();
        // Reset form state
        setState(() {
          _numberOfChildren = 1;
          _submitStatus = null;
        });
      });
    } catch (error) {
      debugPrint('Error submitting additional sponsorship request: $error');
      setState(() {
        _submitStatus = 'error';
        _errorMessage = NetworkErrorHandler.getErrorMessage(error);
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (!widget.isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sponsor Another Child',
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? AppColors.darkMutedForeground
                            : AppColors.lightMutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        'Expand your impact by sponsoring additional children.',
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Success State
                      if (_submitStatus == 'success')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Request Submitted!',
                                style: TextStyle(
                                  fontFamily: 'Specify',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thank you for expanding your support. We\'ll process your request for $_numberOfChildren additional ${_numberOfChildren == 1 ? 'child' : 'children'} and update you soon.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Specify',
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                            ],
                          ),
                        )
                      // Form
                      else ...[
                        // Number of children input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How many additional children would you like to sponsor?',
                              style: TextStyle(
                                fontFamily: 'Specify',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _numberOfChildren.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null &&
                                    parsed >= 1 &&
                                    parsed <= 10) {
                                  setState(() {
                                    _numberOfChildren = parsed;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                hintText: '1',
                              ),
                              style: TextStyle(
                                fontFamily: 'Specify',
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Cost breakdown
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cost Breakdown',
                                    style: TextStyle(
                                      fontFamily: 'Specify',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkForeground
                                          : AppColors.lightForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${25} × $_numberOfChildren ${_numberOfChildren == 1 ? 'child' : 'children'} = \$${_totalCost}/month',
                                style: TextStyle(
                                  fontFamily: 'Specify',
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This amount will be charged to your existing payment method on file.',
                                style: TextStyle(
                                  fontFamily: 'Specify',
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Payment method info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your existing payment method will be used for additional children.',
                                  style: TextStyle(
                                    fontFamily: 'Specify',
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error message
                        if (_submitStatus == 'error' &&
                            _errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      fontFamily: 'Specify',
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_submitStatus == 'error' &&
                            _errorMessage.isNotEmpty)
                          const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: widget.onClose,
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Specify',
                                    fontSize: 16,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Submit Request',
                                        style: TextStyle(
                                          fontFamily: 'Specify',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
