import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellApto extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellApto({
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
                SizedBox(
                  width: MediaQuery.of(context).size.width - 170,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          LabelDefault(title: "${getText('lb_bloco')}: ", color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600, maxLines: 1,),
                          Flexible(fit: FlexFit.loose, child: LabelDefault(title: item['bloco'], color: Theme.of(context).hintColor, size: 16)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                      children: [
                        LabelDefault(title: "${getText('lb_apartamento')}: ", color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600, maxLines: 1,),
                        Flexible(fit: FlexFit.loose, child: LabelDefault(title: item['apto'], color: Theme.of(context).hintColor, size: 16)),
                      ],
                    ),
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
