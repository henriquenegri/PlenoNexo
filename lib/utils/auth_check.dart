import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AURA/screens/profissional/dashboard_profissional.dart';
import 'package:AURA/screens/usuario/home/home_screem_user.dart';
import 'package:AURA/screens/welcome/welcome_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final role = userData['role'];

                if (role == 'professional') {
                  return const DashboardProfissional();
                } else {
                  return const UserHomeScreen();
                }
              }

              // If user data is not found, default to user home screen
              return const UserHomeScreen();
            },
          );
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
