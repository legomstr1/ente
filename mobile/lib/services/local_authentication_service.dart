import "dart:async";

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:photos/core/configuration.dart';
import "package:photos/ui/settings/TEMP/lock_screen_option_password.dart";
import "package:photos/ui/settings/TEMP/lock_screen_option_pin.dart";
import 'package:photos/ui/tools/app_lock.dart';
import 'package:photos/utils/auth_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/toast_util.dart';

class LocalAuthenticationService {
  LocalAuthenticationService._privateConstructor();
  static final LocalAuthenticationService instance =
      LocalAuthenticationService._privateConstructor();

  final Configuration _configuration = Configuration.instance;

  Future<bool> requestLocalAuthentication(
    BuildContext context,
    String infoMessage,
  ) async {
    if (await _isLocalAuthSupportedOnDevice()) {
      AppLock.of(context)!.setEnabled(false);
      final result = await requestAuthentication(context, infoMessage);
      AppLock.of(context)!.setEnabled(
        Configuration.instance.shouldShowLockScreen(),
      );
      if (!result) {
        showToast(context, infoMessage);
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  Future<bool> requestEnteAuthForLockScreen(BuildContext context) async {
    final String? savedPin = await _configuration.getPin();
    final String? savedPassword = await _configuration.getPassword();

    if (savedPassword != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return LockScreenOptionPassword(
              isAuthenticating: true,
              authPass: savedPassword,
            );
          },
        ),
      );
      if (result) {
        return true;
      }
    }
    if (savedPin != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return LockScreenOptionPin(
              isAuthenticating: true,
              authPin: savedPin,
            );
          },
        ),
      );
      if (result) {
        return true;
      }
    }
    return false;
  }

  Future<bool> requestLocalAuthForLockScreen(
    BuildContext context,
    bool shouldEnableLockScreen,
    String infoMessage,
    String errorDialogContent, [
    String errorDialogTitle = "",
  ]) async {
    if (await _isLocalAuthSupportedOnDevice()) {
      AppLock.of(context)!.disable();
      final result = await requestAuthentication(
        context,
        infoMessage,
      );
      if (result) {
        AppLock.of(context)!.setEnabled(shouldEnableLockScreen);
        await Configuration.instance
            .setShouldShowLockScreen(shouldEnableLockScreen);

        return true;
      } else {
        AppLock.of(context)!
            .setEnabled(Configuration.instance.shouldShowLockScreen());
      }
    } else {
      unawaited(
        showErrorDialog(
          context,
          errorDialogTitle,
          errorDialogContent,
        ),
      );
    }
    return false;
  }

  Future<bool> _isLocalAuthSupportedOnDevice() async {
    return LocalAuthentication().isDeviceSupported();
  }
}
