import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

void bottomSheetConta(context, onSelect){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: Wrap(children: <Widget>[
          ListTile(
            // leading: Icon(MdiIcons.phone, color: Theme.of(context).primaryColor, size: 28),
            title: LabelDefault(title: getText('financeiro_conta_corrente'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Conta corrente");
            }          
          ),
          ListTile(
            // leading: Icon(MdiIcons.whatsapp, color: Colors.green, size: 28),
            title: LabelDefault(title:  getText('financeiro_conta_poupanca'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Poupança");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title:  getText('financeiro_conta_outrae'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Outra");
            },          
          ),
         ],
        ),
       );
      }
    );
}
