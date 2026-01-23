/// Error Localization Service
///
/// This service provides methods for displaying localized error messages
/// based on standardized error codes from the backend API.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/api_error_response.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

/// Service for localizing error messages from API responses
class ErrorLocalizationService {
  ErrorLocalizationService._();

  /// Get localized error message for a given error response
  ///
  /// Maps error codes to localized strings using AppLocalizations.
  /// Falls back to a generic error message if code is unknown.
  ///
  /// Args:
  ///   context: The build context for accessing AppLocalizations
  ///   error: The error response from the backend
  ///   fallback: Optional fallback message to use if code is unknown
  ///
  /// Returns:
  ///   The localized error message
  static String getLocalizedMessage(
    BuildContext context,
    ApiErrorResponse error, {
    String? fallback,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Map error codes to localized strings
    switch (error.code) {
      case 'unauthorized':
        return l10n.errorUnauthorized;
      case 'forbidden':
        return l10n.errorForbidden;
      case 'session_expired':
        return l10n.errorSessionExpired;
      case 'validation_error':
        return l10n.errorValidation;
      case 'invalid_input':
        return l10n.errorInvalidInput;
      case 'duplicate_title':
        return l10n.errorDuplicateTitle;
      case 'not_found':
        return l10n.errorNotFound;
      case 'service_unavailable':
        return l10n.errorServiceUnavailable;
      case 'ai_not_configured':
        return l10n.errorAiNotConfigured;
      case 'supabase_error':
        return l10n.errorSupabaseError;
      case 'rate_limited':
        return l10n.errorRateLimited;
      case 'internal_error':
        return l10n.errorInternal;
      case 'bad_gateway':
        return l10n.errorBadGateway;
      case 'gateway_timeout':
        return l10n.errorGatewayTimeout;
      default:
        return fallback ?? l10n.errorInternal;
    }
  }

  /// Show a localized error snackbar
  ///
  /// Displays a SnackBar with the localized error message.
  /// Optionally includes the request ID for debugging.
  ///
  /// For authentication errors (unauthorized, session_expired), this will
  /// redirect to the login page instead of showing an error message.
  ///
  /// Args:
  ///   context: The build context
  ///   error: The error response from the backend
  ///   fallback: Optional fallback message to use if code is unknown
  ///   duration: How long to show the snackbar
  ///   showRequestId: Whether to include request ID in the message
  ///   ref: The Ref for accessing providers (required for redirect)
  static void showErrorSnackBar(
    BuildContext context,
    ApiErrorResponse error, {
    String? fallback,
    Duration duration = const Duration(seconds: 3),
    bool showRequestId = false,
    Ref? ref,
  }) {
    // For auth errors, redirect to login instead of showing error
    if (isAuthError(error) && ref != null) {
      final service = ref.read(authRedirectServiceProvider);
      service.redirectToLogin(ref);
      return;
    }

    String message = getLocalizedMessage(context, error, fallback: fallback);

    // Append request ID if enabled and available
    if (showRequestId && error.requestId != null) {
      message = '$message (ID: ${error.requestId})';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a localized error dialog
  ///
  /// Displays an AlertDialog with the localized error message.
  /// Includes an OK button to dismiss the dialog.
  ///
  /// For authentication errors (unauthorized, session_expired), this will
  /// redirect to the login page instead of showing an error dialog.
  ///
  /// Args:
  ///   context: The build context
  ///   error: The error response from the backend
  ///   fallback: Optional fallback message to use if code is unknown
  ///   ref: The Ref for accessing providers (required for redirect)
  static Future<void> showErrorDialog(
    BuildContext context,
    ApiErrorResponse error, {
    String? fallback,
    Ref? ref,
  }) async {
    // For auth errors, redirect to login instead of showing error
    if (isAuthError(error) && ref != null) {
      final service = ref.read(authRedirectServiceProvider);
      service.redirectToLogin(ref);
      return;
    }

    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: AppLocalizations.of(context)!.error,
        content: Text(getLocalizedMessage(context, error, fallback: fallback)),
        actions: [
          AppButtons.text(
            onPressed: () => Navigator.of(context).pop(),
            label: AppLocalizations.of(context)!.close,
          ),
        ],
      ),
    );
  }

  /// Check if an error response indicates an authentication issue
  ///
  /// Returns true if the error is unauthorized or session expired.
  static bool isAuthError(ApiErrorResponse error) {
    return error.code == 'unauthorized' || error.code == 'session_expired';
  }

  /// Check if an error response indicates a permission issue
  ///
  /// Returns true if the error is forbidden.
  static bool isPermissionError(ApiErrorResponse error) {
    return error.code == 'forbidden';
  }

  /// Check if an error response indicates a resource not found
  ///
  /// Returns true if the error is not_found.
  static bool isNotFoundError(ApiErrorResponse error) {
    return error.code == 'not_found';
  }

  /// Check if an error response indicates a validation issue
  ///
  /// Returns true if the error is validation_error or invalid_input.
  static bool isValidationError(ApiErrorResponse error) {
    return error.code == 'validation_error' || error.code == 'invalid_input';
  }

  /// Check if an error response indicates a server error (5xx)
  ///
  /// Returns true if the error is internal_error, bad_gateway, or gateway_timeout.
  static bool isServerError(ApiErrorResponse error) {
    return error.code == 'internal_error' ||
        error.code == 'bad_gateway' ||
        error.code == 'gateway_timeout';
  }

  /// Check if an error response indicates a service unavailable issue
  ///
  /// Returns true if the error is service_unavailable or ai_not_configured.
  static bool isServiceUnavailableError(ApiErrorResponse error) {
    return error.code == 'service_unavailable' ||
        error.code == 'ai_not_configured';
  }
}
