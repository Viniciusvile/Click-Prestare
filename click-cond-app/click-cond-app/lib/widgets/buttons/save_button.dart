import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

import 'default_button.dart';

class SaveButton extends StatelessWidget {
    final bool isEdit;
    final Function() onPressedDelete;
    final Function() onPressedSave;

  const SaveButton({
    Key? key, 
    required this.isEdit, 
    required this.onPressedDelete,
    required this.onPressedSave
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        padding: EdgeInsets.fromLTRB(10,0,10,10),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                onPressed: () {
                  // print('ssss');
                  onPressedSave();
                }
              ),
            ),
              SizedBox(height: 15), 
              if(isEdit)
                InkWell(
                  onTap: (){onPressedDelete();},
                  child: Align(
                    alignment: Alignment.center,
                    child: LabelDefault(title: getText("btn_delete"), size: 18, color: Colors.red)
                  ),
                ),
          ],
        ),
      );
  }
}
