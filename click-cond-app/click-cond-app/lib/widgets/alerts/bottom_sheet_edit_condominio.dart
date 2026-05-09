import 'package:click/pages/sindico/edit_condominio_address.dart';
import 'package:click/pages/sindico/edit_condominio_dados.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

void bottomSheetEditCondominio(context, onSelect){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: Wrap(children: <Widget>[
          ListTile(
            // leading: Icon(MdiIcons.phone, color: Theme.of(context).primaryColor, size: 28),
            title: LabelDefault(title: getText('condominio_edit_dados'), size:18, color: Colors.black),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const EditCondominioDados())).then((value) {
                onSelect(true);
              });
            }          
          ),
          ListTile(
            // leading: Icon(MdiIcons.whatsapp, color: Colors.green, size: 28),
            title: LabelDefault(title: getText('condominio_edit_endereco'), size:18, color: Colors.black),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const EditCondominioAddress())).then((value) {
                onSelect(true);
              });
            },          
          ),
         ],
        ),
       );
      }
    );
}
