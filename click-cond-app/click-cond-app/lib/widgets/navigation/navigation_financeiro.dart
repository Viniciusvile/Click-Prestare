import 'package:auto_size_text/auto_size_text.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/background.dart';

class NavigationFinanceiro extends StatelessWidget {
  final String title;
  final Function(String selected) onPressed;

  const NavigationFinanceiro({
    Key? key,
    required this.title, 
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {   
    return Container(
      padding: new EdgeInsets.fromLTRB(15, 42, 20, 20),
      decoration: backgroundDecoration(),
      child:Stack(
        alignment: Alignment.centerLeft,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            }, icon: Icon(Icons.arrow_back, size: 30, color: Colors.white)
          ),         
              Padding(
                padding: EdgeInsets.fromLTRB(45, 0, 35, 0),
                child: Align(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    title,
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 18,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),    
              if(getUserType() == 'sindico')                                     
                Align(alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (selected){
                      onPressed(selected);
                    },
                    itemBuilder: (BuildContext context) {
                      return {getText('financeiro_inadimplentes'),getText('financeiro_nav_relatorio')}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                )
            ],
          )
      //   ]
      // )
    );
  }
}
