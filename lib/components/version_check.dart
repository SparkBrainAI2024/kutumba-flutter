import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kutumba/services/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class VersionCheck {
  static void customShowUpdateDialog(context, Map versionCheck) {
    String message = versionCheck['forceUpdate']
        ? 'Please update the app to continue.'
        : 'A newer version of the app is available.';

    showDialog(
      context: context,
      barrierDismissible: !versionCheck['forceUpdate'],
      builder: (context) => WillPopScope(
        onWillPop: () async => !versionCheck['forceUpdate'],
        child: AlertDialog(
          title: const Text('NEW Update Available'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(message),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                await launch(versionCheck['storeUrl']);

                if (!versionCheck['forceUpdate']) Navigator.of(context).pop();
              },
            ),
            if (!versionCheck['forceUpdate'])
              TextButton(
                child: const Text('Later'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  static checkLatestVersion(BuildContext context) async {
    ApiService _api = ApiService();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String packageName = packageInfo.packageName;
    String currentVersion = packageInfo.version;
    String platform = Platform.isAndroid ? 'Android' : 'IOS';

    Map jsonResult = await _api.checkVersion(platform, currentVersion);

    if (jsonResult['status']) {
      if (jsonResult['data']['update_required'] ?? false) {
        String androidStoreUrl =
            "https://play.google.com/store/apps/details?id=" + packageName;
        String iosStoreUrl =
            "https://apps.apple.com/us/app/kutumba-band-digital-album/id1541119392";

        customShowUpdateDialog(context, {
          'updateRequired': jsonResult['data']['update_required'] ?? false,
          'forceUpdate': jsonResult['data']['force_update'] ?? false,
          'packageName': packageName,
          'storeUrl': Platform.isAndroid ? androidStoreUrl : iosStoreUrl,
        });
      }
    }
  }
}
