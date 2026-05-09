import 'package:click/widgets/alerts/modal_bottom_sheet_data.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

openSideMenuBottomSheet(BuildContext context, List<SidemenuListBottomSheetData> list, bool displayCheckedButtons) async {
  return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext bc){
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(MdiIcons.close, color: Colors.black, size: 27,)
                  )
                ],),
              ),
              for(var item in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                  child: InkWell(
                    onTap: (){
                      item.onPressed();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300, strokeAlign: 1)
                      ),
                      child: Row(
                        children: [
                          if(item.icon != null)
                            Image(image: AssetImage(item.icon!), width: 15, color: Colors.black,),
                          if(item.icon != null)
                            const SizedBox(width: 20),
                          Wrap(
                            direction: Axis.vertical,
                            children: [
                              LabelDefault(title: item.title, maxLines: 99,),
                              if(item.subTitle != null)
                                const SizedBox(height: 5),
                              if(item.subTitle != null)
                                SizedBox(width: MediaQuery.of(context).size.width-150, child: LabelDefault(title: item.subTitle!, color: Colors.black, size: 12, maxLines: 99,)),
                            ],
                          ),
                          const Spacer(),
                          if(displayCheckedButtons)
                            if(item.isChecked)
                              Icon(MdiIcons.checkCircle, color: Theme.of(context).primaryColor,)
                        ],
                      ),
                    ),
                  ),
                )
              ],
          ),
        );
      }
    );
}
