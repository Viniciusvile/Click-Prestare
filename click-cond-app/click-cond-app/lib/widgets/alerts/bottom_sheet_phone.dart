import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void bottomSheetPhone(BuildContext context, String number) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Wrap(
        children: [
          ListTile(
            leading: Icon(MdiIcons.phone, color: Theme.of(context).primaryColor, size: 28),
            title: LabelDefault(title: getText('telefone'), size: 18, color: Colors.black),
            onTap: () {
              launchUrl(Uri.parse('tel:$number'));
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.whatsapp, color: Colors.green, size: 28),
            title: LabelDefault(title: "WhatsApp", size: 18, color: Colors.black),
            onTap: () {
              openWhatsApp(context, number, '');
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: "SMS", size: 18, color: Colors.black),
            onTap: () {
              sendSMS(number, '');
            },
          ),
        ],
      );
    },
  );
}
