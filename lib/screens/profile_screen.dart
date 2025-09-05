import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/strapi_auth_provider.dart';
import '../models/strapi_user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<StrapiAuthProvider>(context);
    final StrapiUser? user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('No user data available.'))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username ?? user.email,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: isDark ? theme.colorScheme.onSurface.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(
                            user.confirmed == true ? 'Confirmed' : 'Unconfirmed',
                            style: TextStyle(
                              color: user.confirmed == true ? Colors.green[800] : Colors.orange[800],
                              fontFamily: 'Poppins',
                            ),
                          ),
                          backgroundColor: user.confirmed == true ? Colors.green[100] : Colors.orange[100],
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(
                            user.blocked == true ? 'Blocked' : 'Active',
                            style: TextStyle(
                              color: user.blocked == true ? Colors.red[800] : Colors.blue[800],
                              fontFamily: 'Poppins',
                            ),
                          ),
                          backgroundColor: user.blocked == true ? Colors.red[100] : Colors.blue[100],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
