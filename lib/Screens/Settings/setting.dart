import 'dart:io';

import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/popup.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/textinput_dialog.dart';
import 'package:blackhole/Helpers/backup_restore.dart';
import 'package:blackhole/Helpers/config.dart';
import 'package:blackhole/Helpers/countrycodes.dart';
import 'package:blackhole/Helpers/picker.dart';
import 'package:blackhole/Helpers/supabase.dart';
import 'package:blackhole/Screens/Home/saavn.dart' as home_screen;
import 'package:blackhole/Screens/Settings/player_gradient.dart';
import 'package:blackhole/Screens/Top Charts/top.dart' as top_screen;
import 'package:blackhole/Services/ext_storage_provider.dart';
import 'package:blackhole/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BoxSwitchTile extends StatelessWidget {
  const BoxSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.keyName,
    required this.defaultValue,
    this.isThreeLine,
    this.onChanged,
  });

  final Text title;
  final Text? subtitle;
  final String keyName;
  final bool defaultValue;
  final bool? isThreeLine;
  final Function(bool, Box box)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (BuildContext context, Box box, Widget? widget) {
        return SwitchListTile(
          activeColor: Theme.of(context).colorScheme.secondary,
          title: title,
          subtitle: subtitle,
          isThreeLine: isThreeLine ?? false,
          dense: true,
          value: box.get(keyName, defaultValue: defaultValue) as bool? ??
              defaultValue,
          onChanged: (val) {
            box.put(keyName, val);
            onChanged?.call(val, box);
          },
        );
      },
    );
  }
}

class SpotifyCountry {
  Future<String> changeCountry({required BuildContext context}) async {
    String region =
        Hive.box('settings').get('region', defaultValue: 'India') as String;
    if (!ConstantCodes.localChartCodes.containsKey(region)) {
      region = 'India';
    }

    await showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        const Map<String, String> codes = ConstantCodes.localChartCodes;
        final List<String> countries = codes.keys.toList();
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              10,
              0,
              10,
            ),
            itemCount: countries.length,
            itemBuilder: (context, idx) {
              return ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  title: Text(
                    countries[idx],
                  ),
                  leading: Radio(
                    value: countries[idx],
                    groupValue: region,
                    onChanged: (value) {
                      top_screen.localSongs = [];
                      region = countries[idx];
                      top_screen.fetched = false;
                      top_screen.fetchFinished.value = false;
                      Hive.box('settings').put('region', region);
                      Navigator.pop(context);
                    },
                  ),
                  selected: region == countries[idx],
                  onTap: () {
                    top_screen.localSongs = [];
                    region = countries[idx];
                    top_screen.fetched = false;
                    top_screen.fetchFinished.value = false;
                    Hive.box('settings').put('region', region);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
    return region;
  }
}
