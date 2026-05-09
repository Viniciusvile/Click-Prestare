import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void bottomSheetAptos(context, list, selected, onSelect){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          child: Wrap(children: <Widget>[
            for(var item in list)
              ListTile(
                trailing: selected == item 
                          ? Icon(MdiIcons.checkCircle, color: Theme.of(context).primaryColor, size: 28)
                          : null,                
                title: LabelDefault(title: item, size:18, color: Colors.black),
                onTap: (){onSelect(item); }
              ),
         ],
        ),
       );
      }
    );
}
