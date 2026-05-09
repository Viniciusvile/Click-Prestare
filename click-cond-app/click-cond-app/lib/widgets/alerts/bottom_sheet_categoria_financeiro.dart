import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

void bottomSheetCategoriaFinanceiro(context, onSelect){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: Wrap(children: <Widget>[
          ListTile(
            // leading: Icon(MdiIcons.phone, color: Theme.of(context).primaryColor, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_consumo'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Consumo");
            }          
          ),
          ListTile(
            // leading: Icon(MdiIcons.whatsapp, color: Colors.green, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_manutencao'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Manutenção");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_pessoal'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Pessoal");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_impostos'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Impostos");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_adms'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Administrativas");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_categ_outras'), size:18, color: Colors.black),
            onTap: () {
              onSelect("Outras");
            },          
          ),
         ],
        ),
       );
      }
    );
}
