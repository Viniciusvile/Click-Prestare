import 'package:click/pages/singleton.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CellAptoFinanceiro extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellAptoFinanceiro({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: 
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    height: 40,
                    width: 5,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 10),
                if(item["pago"] == 1)
                  Icon(MdiIcons.checkCircle, color: Colors.green, size: 20,),
                if(item["pago"] == 0)
                  Icon(MdiIcons.alertCircle, color: Colors.orange, size: 20,),
                SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            LabelDefault(title: "${getText('lb_apartamento')}: ", color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600, maxLines: 1,),
                            Flexible(fit: FlexFit.loose, child: LabelDefault(title: item['apto'], color: Theme.of(context).hintColor, size: 16)),
                          ],
                        ),
                      ),
                      LabelDefault(title: item["valorReal"].replaceAll("R\$", Singleton.instance.getCurrentMoeda()), size: 13),
                      Icon(MdiIcons.chevronRight)
                    ],
                  ),
                ),
              ],
            ),
        )
      ),
    );
  }
}
