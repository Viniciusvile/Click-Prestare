
import 'package:click/pages/sindico/login.dart';
import 'package:click/pages/sindico/signup/signup_sindico.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/background.dart';
import 'package:click/widgets/buttons/alternative_button.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class Hello extends StatefulWidget {
  const Hello({Key? key}) : super(key: key);

  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<Hello> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(   
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 149, 218, 1),           
        ),    
        child: Column(
          children: [
            Container(
              padding: new EdgeInsets.fromLTRB(30, 80, 30, 0),
              decoration: backgroundDecoration(),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getText('ola')}, ${getText('sindico')}',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    getText('view_hello_text'),
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15.0),
                height: MediaQuery.of(context).size.height,
                decoration: BoxMainRounded(),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    SizedBox(
                      height: 80,
                      child: DefaultButton(title: getText('vamos_cadastrar').toString().toUpperCase(), hasArrow: true, aligment: FractionalOffset.topCenter,
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => SignupSindico(),));
                        }
                      ),
                    ),
                    SizedBox(height: 10),
                    AlternativeButton(title: getText('possuo_cadastro').toString().toUpperCase(), backgroundColor: Colors.white, textColor: Theme.of(context).primaryColor, borderColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => LoginSindico(loginType: 'sindico',)),);
                      },
                    )
                  ],
                ),
              )
            ),
            Align(                
              alignment: Alignment.bottomCenter,
              child: Image(
                height: MediaQuery.of(context).size.width * 0.3,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                image: AssetImage('assets/images/city.png'),
              ),
            ), 
          ],
        ), 
      )
        
        
        
        

      
    );
  }
}
