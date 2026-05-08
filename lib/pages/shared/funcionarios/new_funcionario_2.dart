import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/cells/cell_permissoes_funcionario.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class NewFuncionario2 extends StatefulWidget {
  const NewFuncionario2({Key? key}) : super(key: key);

  @override
  _NewFuncionario2PageState createState() => _NewFuncionario2PageState();
}

class _NewFuncionario2PageState extends State<NewFuncionario2> {
  late List<int> list = [1,2,3,4,1,2,3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(  
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 149, 218, 1),           
        ),    
        child: Column(
          children: [
            NavigationDefault(title: "Permissões do Funcionário"),
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                height: MediaQuery.of(context).size.height - 110,
                decoration: BoxMainRounded(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("${getText('libere_funcoes')}:",  textAlign: TextAlign.center, style: TextStyle(fontSize: 22,fontWeight: FontWeight.w900, color: Theme.of(context).hintColor),),
                      for(var item in list) 
                        GestureDetector(
                          onTap: (){
                            print("");
                          },
                          child: CellPermissoesFuncionario(item: 1, hasArrow: true),
                        ),
                      SizedBox(height: 10),                                         
                      SizedBox(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        child: DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                          onPressed: () {
                            var nav = Navigator.of(context);
                            nav.pop();
                            nav.pop();
                          }
                        ),
                      ),
                      SizedBox(height: 10),                                         
                    ]
                  ),
                ),
              ),
            ),
          ],
        ), 
      ),
    );
  }
}
