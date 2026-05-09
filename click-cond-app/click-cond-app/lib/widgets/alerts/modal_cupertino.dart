import 'package:click/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalCupertino extends StatefulWidget {
  final String type;
  final Function(String) onPressed;
  final DateTime? initialDate;
  final DateTime? minimumDate;

  const ModalCupertino({
    Key? key, 
    required this.onPressed, required this.initialDate, required this.type, this.minimumDate, 
    }) : super(key: key);

  @override
  _ModalCupertinoState createState() => _ModalCupertinoState();
}

class _ModalCupertinoState extends State<ModalCupertino> {
  var date = "";

  @override
  void initState(){
    super.initState();
    if(widget.initialDate != null){
      date = widget.type == "datetime" ? convertDateTimeToString(widget.initialDate!)
                            : widget.type == "date" ? convertDateFormatToString(widget.initialDate!)
                            : convertTimeFormatToString(widget.initialDate!);
    }else{
      date = widget.type == "datetime" ? convertDateTimeToString(DateTime.now())
                            : widget.type == "date" ? convertDateFormatToString(DateTime.now())
                            : convertTimeFormatToString(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                child: const Text('Pronto'),
                onPressed: () { 
                  widget.onPressed(date);
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          SizedBox(
            height: 340,
            child: 
              CupertinoTheme(
                data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 18,
                        ),
                    ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: widget.initialDate,
                  use24hFormat: true,
                  minimumDate: widget.minimumDate ?? widget.initialDate,
                  mode: widget.type == "datetime" ? CupertinoDatePickerMode.dateAndTime
                        : widget.type == "date" ? CupertinoDatePickerMode.date 
                        : CupertinoDatePickerMode.time,
                  onDateTimeChanged: (DateTime newDateTime) {
                    date =  widget.type == "datetime" ? convertDateTimeToString(newDateTime)
                              : widget.type == "date" ? convertDateFormatToString(newDateTime)
                              : convertTimeFormatToString(newDateTime);
                  },
                ),
              ) 
          ),
        ],
      ),
    );
  }
}
