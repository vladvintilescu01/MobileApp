import 'package:flutter/material.dart';

// MyAccountPage constructor that accepts user data
class MyAccountPage extends StatelessWidget {
  final String username;
  final String email;
  final String phoneNumber;

  // Constructor to accept user data
  const MyAccountPage({
    Key? key,
    required this.username,
    required this.email,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            _buildUserInfoRow('Username', username),
            _buildUserInfoRow('Email', email),
            _buildUserInfoRow('Phone Number', phoneNumber),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to Update Profile (you can implement this page later)
                Navigator.pushNamed(context, '/updateProfile');
              },
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Change Password (you can implement this page later)
                Navigator.pushNamed(context, '/updatePassword');
              },
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // For now, just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log out not implemented yet')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build rows for user info
  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
