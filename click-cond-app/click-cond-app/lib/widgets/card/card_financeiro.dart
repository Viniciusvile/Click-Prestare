import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CardFinanceiro extends StatefulWidget {
  const CardFinanceiro({
    Key? key,
    required this.saldoAtual,
    required this.dia,
    required this.mes
  }) : super(key: key);

  final String mes;
  final String saldoAtual;
  final String dia;

  @override
  _CardFinanceiroState createState() => _CardFinanceiroState();
}

  class _CardFinanceiroState extends State<CardFinanceiro> {  
    var passenable = false;
      
    @override
    Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        shape: BoxShape.rectangle,
        gradient: LinearGradient(colors: [Color.fromRGBO(43, 196, 243, 1), Color.fromRGBO(0, 174, 238, 1),
            Color.fromRGBO(0, 149, 218, 1)])
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelDefault(title: widget.mes, size: 22, color: Colors.white),
              Column(
                children: [
                  Text(widget.saldoAtual, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  LabelDefault(title: '${getText('financeiro_saldo_dia')} '+widget.dia, size: 13, color: Colors.white),
                  SizedBox(height: 10),  
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  }

