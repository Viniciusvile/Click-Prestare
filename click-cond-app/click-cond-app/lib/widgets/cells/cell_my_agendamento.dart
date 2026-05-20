import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellMyAgendamento extends StatelessWidget {
  final item;

  const CellMyAgendamento({
    Key? key,
    required this.item, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String apto = item['apto']?.toString() ?? '';
    final String blocoRaw = item['bloco']?.toString() ?? '';
    String blocoText = '';
    if (blocoRaw.isNotEmpty) {
      final blocoLower = blocoRaw.toLowerCase();
      if (blocoLower.contains('bloco') || 
          blocoLower.contains('bloque') || 
          blocoLower.contains('block')) {
        blocoText = blocoRaw;
      } else {
        blocoText = '${getText('lb_bloco')} $blocoRaw';
      }
    }
    final String aptoBlocoTitle = '${getText('lb_apto')} $apto $blocoText';

    final String status = item['status']?.toString() ?? 'pendente';
    String statusText = getText('lb_pendente');
    Color statusColor = Colors.orange;
    if (status == 'aprovado') {
      statusText = getText('lb_aprovado');
      statusColor = Colors.green;
    } else if (status == 'recusado') {
      statusText = getText('lb_recusado');
      statusColor = Colors.red;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 10, 20),
          child: 
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.house_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: aptoBlocoTitle, size: 14),
                        ],
                      ),
                    ), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                        SizedBox(width: 5),
                        LabelDefault(title: item['data_criacao'], size: 14),
                      ],
                    )
                    
                  ],
                ),   
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                        height: 100,
                        width: 5,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    // CircleAvatar(                      
                    //   radius: 40,
                     //   backgroundImage: NetworkImage(item['photo'])
                    // ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 100, 
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Flexible(fit: FlexFit.loose, child: LabelDefault(title: item['nomeMorador'] ?? 'Síndico', color: Theme.of(context).hintColor, size: 20, weight: FontWeight.w600, maxLines: 1,)),
                          // SizedBox(height: 10),
                          LabelDefault(title: "${getText('area_social_data_reserva')} "+item['data'], size: 15, maxLines: 2),
                          SizedBox(height: 5),
                          LabelDefault(title: "${getText('area_social_hora_reserva')} "+item['horaDe']+' - '+item['horaAte'], size: 15, maxLines: 2),                          
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  LabelDefault(title: "$statusText:", size: 18, color: statusColor, weight: FontWeight.bold),
                                  SizedBox(width: 5),
                                  LabelDefault(title: item['nomeArea'], size: 18, color: Theme.of(context).primaryColor, weight: FontWeight.bold),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
        )
      ),
    );
  }
}
