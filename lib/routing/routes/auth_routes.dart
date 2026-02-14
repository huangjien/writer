import 'package:go_router/go_router.dart';

import 'package:writer/features/auth/screens/sign_in_screen.dart';
import 'package:writer/features/auth/screens/sign_up_screen.dart';
import 'package:writer/features/auth/screens/forgot_password_screen.dart';
import 'package:writer/features/auth/screens/reset_password_screen.dart';
import 'package:writer/features/auth/screens/user_management_screen.dart';
import 'package:writer/features/about/about_screen.dart';

final authRoutes = [
  GoRoute(
    path: '/signin',
    name: 'signin',
    builder: (context, ref) => const SignInScreen(),
  ),
  GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, ref) => const SignUpScreen(),
  ),
  GoRoute(
    path: '/forgot-password',
    name: 'forgot-password',
    builder: (context, ref) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: '/reset-password',
    name: 'reset-password',
    builder: (context, ref) => const ResetPasswordScreen(),
  ),
  GoRoute(
    path: '/user-management',
    name: 'user-management',
    builder: (context, ref) => const UserManagementScreen(),
  ),
  GoRoute(
    path: '/about',
    name: 'about',
    builder: (context, ref) => const AboutScreen(),
  ),
];
