import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFff9966), Color(0xFFff5e62)], // Vibrant orange-pink gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_reset,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Reset Your Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Enter your registered email to receive a password reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 32),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: "Enter your email",
                  hintStyle: TextStyle(color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => resetPassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Send Reset Link",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetPassword(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage(context, "Please enter an email address");
      return;
    }

    if (!isValidEmail(email)) {
      showMessage(context, "Please enter a valid email");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showMessage(context, "Password reset link sent to $email");
      Navigator.pop(context); // Navigate back to the login screen
    } on FirebaseAuthException catch (e) {
      handleAuthError(context, e);
    } catch (e) {
      showMessage(context, "An unexpected error occurred");
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    ));
  }

  void handleAuthError(BuildContext context, FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case "invalid-email":
        errorMessage = "Invalid email format";
        break;
      case "user-not-found":
        errorMessage = "No user found for this email";
        break;
      default:
        errorMessage = "An unexpected error occurred";
    }
    showMessage(context, errorMessage);
  }
}
