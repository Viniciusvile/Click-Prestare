import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

void bottomSheetPagamento(context, onSelect){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: Wrap(children: <Widget>[
          ListTile(
            // leading: Icon(MdiIcons.phone, color: Theme.of(context).primaryColor, size: 28),
            title: LabelDefault(title: getText('financeiro_dinheiro'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            onTap: () {
              onSelect("Dinheiro");
            }          
          ),
          ListTile(
            // leading: Icon(MdiIcons.whatsapp, color: Colors.green, size: 28),
            title: LabelDefault(title: getText('financeiro_pix'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            onTap: () {
              onSelect("Pix");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_boleto'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            onTap: () {
              onSelect("Boleto");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_cartao_debito'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            onTap: () {
              onSelect("Cartão Débito");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_cartao_credito'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            onTap: () {
              onSelect("Cartão Crédito");
            },          
          ),
          ListTile(
            // leading: Icon(MdiIcons.messageOutline, color: Colors.amber, size: 28),
            title: LabelDefault(title: getText('financeiro_outra'), size:18, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
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
