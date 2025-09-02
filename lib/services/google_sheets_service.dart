import 'dart:convert';
import 'package:http/http.dart' as http;

class DonationRecord {
  final String id;
  final String donor;
  final double amount;
  final String date;
  final String project;
  final String status;
  final String? email;
  final String? notes;
  final String? paymentMethod;

  DonationRecord({
    required this.id,
    required this.donor,
    required this.amount,
    required this.date,
    required this.project,
    required this.status,
    this.email,
    this.notes,
    this.paymentMethod,
  });

  factory DonationRecord.fromJson(Map<String, dynamic> json) {
    return DonationRecord(
      id: json['id'] ?? '',
      donor: json['donor'] ?? '',
      amount:
          (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      date: json['date'] ?? '',
      project: json['project'] ?? '',
      status: json['status'] ?? '',
      email: json['email'],
      notes: json['notes'],
      paymentMethod: json['paymentMethod'],
    );
  }
}

class GoogleSheetsService {
  // Replace with your actual Google Sheet ID
  static const String _sheetId = '11BH8c2lrXhsfzGxwKq2OOwn5qornyvWQvMqWpBhoAeE';
  static const String _apiKey = 'AIzaSyCtQtAgTiisbGw0FuW3HsLWeZ2jdA-XLTQ';
  static const String _range = 'Export!A1:N';

  static Future<List<DonationRecord>> fetchDonations() async {
    try {
      final url =
          'https://sheets.googleapis.com/v4/spreadsheets/$_sheetId/values/$_range?key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception(
              'Permission error: Your Google Sheet is not publicly accessible. '
              'Please open the sheet, click "Share" in the top right, '
              'change to "Anyone with the link" and set to "Viewer".');
        }
        throw Exception(
            'API request failed: ${response.statusCode} - ${response.body}');
      }

      final data = json.decode(response.body);

      if (data['values'] == null || !(data['values'] is List)) {
        return [];
      }

      final values = data['values'] as List;
      if (values.isEmpty) return [];

      // First row should be headers
      final headers = values[0] as List;

      // Find column indices for important fields
      final emailColumnIndex =
          _findColumnIndex(headers, ['email', 'e-mail', 'mail']);
      final firstNameColumnIndex = _findColumnIndex(
          headers, ['first name', 'firstname', 'first_name', 'first']);
      final lastNameColumnIndex = _findColumnIndex(
          headers, ['last name', 'lastname', 'last_name', 'last']);
      final amountColumnIndex = _findColumnIndex(
          headers, ['amount', 'total amount', 'donation amount', 'total']);
      final dateColumnIndex =
          _findColumnIndex(headers, ['date', 'payment date', 'donation date']);
      final projectColumnIndex = _findColumnIndex(
          headers, ['project', 'extra donation', 'donation type']);
      final statusColumnIndex =
          _findColumnIndex(headers, ['status', 'payment status']);
      final paymentMethodColumnIndex =
          _findColumnIndex(headers, ['method', 'payment method']);

      // Skip the header row (start at index 1)
      final dataRows = values.skip(1).toList();

      // Convert the raw data into structured objects
      final List<DonationRecord> donations = [];
      for (int index = 0; index < dataRows.length; index++) {
        final row = dataRows[index];

        // Debug logging for first few rows
        if (index < 3) {
          print(
              '🔍 [SHEETS] Row $index: ${row.map((e) => '${e.runtimeType}: $e').toList()}');
        }

        // Parse the amount
        double amount = 0.0;
        try {
          final amountCol = amountColumnIndex >= 0
              ? row[amountColumnIndex]
              : (row.length > 1 ? row[1] : '0');
          final amountString =
              amountCol?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
          amount = double.tryParse(amountString) ?? 0.0;
        } catch (e) {
          print('Error parsing amount for row $index: $e');
        }

        // Try to get email from any column that looks like it could contain an email
        String? email;

        // First check the identified email column
        if (emailColumnIndex >= 0 &&
            row.length > emailColumnIndex &&
            row[emailColumnIndex] != null) {
          email = row[emailColumnIndex].toString();
        } else {
          // Otherwise scan all columns for something that looks like an email
          for (int i = 0; i < row.length; i++) {
            final value = row[i];
            if (value != null &&
                value.toString().contains('@') &&
                value.toString().contains('.')) {
              email = value.toString();
              break;
            }
          }
        }

        // Get first and last name
        final firstName =
            firstNameColumnIndex >= 0 && row.length > firstNameColumnIndex
                ? row[firstNameColumnIndex]
                : (row.length > 9 ? row[9] : '');
        final lastName =
            lastNameColumnIndex >= 0 && row.length > lastNameColumnIndex
                ? row[lastNameColumnIndex]
                : (row.length > 10 ? row[10] : '');

        // Build donor name
        final donor = '${firstName ?? ''} ${lastName ?? ''}'.trim().isEmpty
            ? 'Anonymous'
            : '${firstName ?? ''} ${lastName ?? ''}'.trim();

        // Get other fields with better parsing
        String date = '';
        if (dateColumnIndex >= 0 &&
            row.length > dateColumnIndex &&
            row[dateColumnIndex] != null) {
          final dateValue = row[dateColumnIndex];
          if (dateValue is DateTime) {
            date = dateValue.toIso8601String().split('T')[0];
          } else {
            date = dateValue.toString();
          }
        } else if (row.isNotEmpty && row[0] != null) {
          final dateValue = row[0];
          if (dateValue is DateTime) {
            date = dateValue.toIso8601String().split('T')[0];
          } else {
            date = dateValue.toString();
          }
        }

        // Ensure date is not empty and has a meaningful value
        if (date.isEmpty || date.toLowerCase() == 'null') {
          date = DateTime.now().toIso8601String().split('T')[0];
        }

        String project = '';
        if (projectColumnIndex >= 0 &&
            row.length > projectColumnIndex &&
            row[projectColumnIndex] != null) {
          final projectValue = row[projectColumnIndex];
          project = projectValue.toString();
        } else if (row.length > 5 && row[5] != null) {
          final projectValue = row[5];
          project = projectValue.toString();
        }

        String status = '';
        if (statusColumnIndex >= 0 &&
            row.length > statusColumnIndex &&
            row[statusColumnIndex] != null) {
          final statusValue = row[statusColumnIndex];
          if (statusValue is bool) {
            status = statusValue ? 'Completed' : 'Pending';
          } else {
            status = statusValue.toString();
          }
        } else if (row.length > 3 && row[3] != null) {
          final statusValue = row[3];
          if (statusValue is bool) {
            status = statusValue ? 'Completed' : 'Pending';
          } else {
            status = statusValue.toString();
          }
        }

        // Ensure status is not empty and has a meaningful value
        if (status.isEmpty || status.toLowerCase() == 'null') {
          status = 'Pending';
        }

        String? notes = null;
        if (row.length > 7 && row[7] != null) {
          final notesValue = row[7];
          if (notesValue is bool) {
            notes = notesValue ? 'Yes' : 'No';
          } else {
            notes = notesValue.toString();
          }
        }

        String? paymentMethod = null;
        if (paymentMethodColumnIndex >= 0 &&
            row.length > paymentMethodColumnIndex &&
            row[paymentMethodColumnIndex] != null) {
          final methodValue = row[paymentMethodColumnIndex];
          if (methodValue is bool) {
            paymentMethod = methodValue ? 'Yes' : 'No';
          } else {
            paymentMethod = methodValue.toString();
          }
        } else if (row.length > 2 && row[2] != null) {
          final methodValue = row[2];
          if (methodValue is bool) {
            paymentMethod = methodValue ? 'Yes' : 'No';
          } else {
            paymentMethod = methodValue.toString();
          }
        }

        final donation = DonationRecord(
          id: 'donation-$index',
          donor: donor,
          amount: amount,
          date: date,
          project: project,
          status: status,
          email: email,
          notes: notes,
          paymentMethod: paymentMethod,
        );

        // Debug logging for first few donations
        if (index < 3) {
          print(
              '🔍 [SHEETS] Parsed donation $index: ${donation.donor}, \$${donation.amount}, ${donation.date}, ${donation.project}, ${donation.status}');
        }

        donations.add(donation);
      }

      return donations;
    } catch (error) {
      print('Error fetching donations: $error');
      rethrow;
    }
  }

  // Helper function to find column index by name (case insensitive)
  static int _findColumnIndex(List headers, List<String> possibleNames) {
    if (headers.isEmpty) return -1;

    for (final name in possibleNames) {
      final index = headers.indexWhere((h) =>
          h != null && h.toString().toLowerCase().contains(name.toLowerCase()));
      if (index >= 0) return index;
    }
    return -1;
  }

  static Future<bool> submitDonation({
    required String donor,
    required double amount,
    required String project,
    String? email,
    String? notes,
    String? paymentMethod,
  }) async {
    try {
      // For development/demo purposes only
      // In a real app, you would use a server endpoint to securely handle this
      print(
          'Donation submitted: $donor, \$${amount.toStringAsFixed(2)}, $project');

      // Since direct API writes require OAuth 2.0 auth (not just API key),
      // we'd normally post this to a backend that handles the actual Google Sheets update

      // Return true to simulate success for the demo
      return true;
    } catch (error) {
      print('Error submitting donation: $error');
      return false;
    }
  }
}
