import 'package:auto_size_text/auto_size_text.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/local_storage.dart';

class CardCondominium extends StatelessWidget {
  const CardCondominium({
    Key? key,
    required this.item,
  }) : super(key: key);

  final item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: Card(
        child: Container(          
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            children: [
              ClipRRect(
                 borderRadius: BorderRadius.circular(4.0),
                 child: Container(
                   height: 130,
                   width: 5,
                   color: Color(0xFF61C99C),
                 ),
              ),
              SizedBox(width: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item["photo"], 
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 140,
                  fit: BoxFit.cover,
                )
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 190,
                    child: AutoSizeText(
                      item["nome"],
                      textScaleFactor: 1.0,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // SizedBox(height:1),
                  if(getUserType() == "morador")
                    Row(children: [
                        Icon(Icons.home_outlined, color: Theme.of(context).hintColor, size: 30,),
                        SizedBox(width: 5),
                        LabelDefault(title: "Apto " + item["apto"].toString(), size: 14),
                      ],
                    ),
                  if(getUserType() != "morador")
                    Row(children: [
                        Icon(MdiIcons.homeGroup, color: Theme.of(context).hintColor, size: 30,),
                        SizedBox(width: 5),
                        LabelDefault(title: item["num_aptos"].toString() + " ${getText('lb_apartamentos')}", size: 14),
                      ],
                    ),
                  // SizedBox(height:20),
                  SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LabelDefault(title: getText('lb_ultima_atualizacao'), size: 14),
                        if(getUserType() != 'funcionario')
                          LabelDefault(title: getText('lb_saldo'), size: 14),
                      ],
                    ),
                  ),
                  // SizedBox(height:5),
                  SizedBox(
                    width: 210,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LabelDefault(title: item['data_financeiro'] ?? "-", size: 16, weight: FontWeight.bold),
                        if(item["saldo"] != null && getUserType() != 'funcionario')
                          Text(item["saldo"].toString().replaceAll("R\$", item["moeda"] ?? "R\$"), 
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: item["saldo"].toString().contains('-') ? Colors.red[300] : Color(0xFF61C99C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}
