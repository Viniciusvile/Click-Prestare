import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CellAptoInadimplente extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellAptoInadimplente({
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
                Icon(Icons.house_outlined, size: 26, color: Theme.of(context).hintColor,),
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
                      LabelDefault(title: '(${item["qtd"].toString()})', size: 13),
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
