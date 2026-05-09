import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class ModalAgendaReserva extends StatefulWidget {

  const ModalAgendaReserva({Key? key, required this.onPressed, this.selected, required this.allowedDays, }) : super(key: key);
  final Function(DateTime) onPressed;
  final DateTime? selected;
  final Map allowedDays;

  @override
  _ModalAgendaReservaState createState() => _ModalAgendaReservaState();
}

class _ModalAgendaReservaState extends State<ModalAgendaReserva> {
  
  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
  }

  checkDate(item){
    try{
      var date = new DateTime(item.year, item.month, item.day, 0, 0);      
      return widget.allowedDays.containsKey(date);
    }catch(e){
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Container(
      padding: EdgeInsets.all(30),
      height: 455,
        margin: EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black,offset: Offset(0,5),
            blurRadius: 15
            ),
          ]
        ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2100, 3, 14),
        focusedDay: DateTime.now(),
        locale: 'pt_BR',                            
        // selectedDayPredicate: widget.selected != null ? (day) => isSameDay(day, widget.selected!) : null,
        availableCalendarFormats: const {CalendarFormat.month: ''},
        onDaySelected: (selectedDay, focusedDay) {
          var date = new DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0, 0);
          if(widget.allowedDays.containsKey(date)){ //se for sabado ou domindo, depois alterar para os dias não permitidos
            setState(() {                              
              widget.onPressed(selectedDay);
            });
          }            
        },
        calendarBuilders: CalendarBuilders(
          todayBuilder: (context, day, focusedDay) {
            return Container(
              child: Center(
                child: 
                  widget.selected != null && isSameDay(day, widget.selected!) 
                  ? Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        background: Paint()..color = Colors.yellow
                        ..strokeWidth = 17
                        ..style = PaintingStyle.stroke,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        background: Paint()..color = checkDate(day) ? Theme.of(context).primaryColor : Colors.grey.shade300
                        ..strokeWidth = 17
                        ..style = PaintingStyle.stroke,
                      ),
                      textAlign: TextAlign.center,
                    )
                // LabelDefault(title: day.day.toString(), color: Style.primaryColor, size: 14, weight: FontWeight.bold,)
              ));
          },
          defaultBuilder: (context, day, focusedDay)  {
             return Container(
              child: Center(
                child: 
                  widget.selected != null && isSameDay(day, widget.selected!) 
                  ? Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        background: Paint()..color = Colors.yellow
                        ..strokeWidth = 17
                        ..style = PaintingStyle.stroke,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        background: Paint()..color = checkDate(day) ? Theme.of(context).primaryColor : Colors.grey.shade300
                        ..strokeWidth = 17
                        ..style = PaintingStyle.stroke,
                      ),
                      textAlign: TextAlign.center,
                    )
                // LabelDefault(title: day.day.toString(), color: Style.primaryColor, size: 14, weight: FontWeight.bold,)
              ));              
          },          
        ),
        // calendarStyle: CalendarStyle(
          // defaultDecoration: BoxDecoration(
          //   color: Style.primaryColor,
          //   shape: BoxShape.circle,
          // ),
        //   weekendDecoration: BoxDecoration(
        //     color: Style.primaryColor,
        //     shape: BoxShape.circle,
        //   ),
        //   defaultTextStyle: TextStyle(color: Colors.white),
          // selectedDecoration: BoxDecoration(
          //   color: Style.dateSelected,
          //   shape: BoxShape.circle,
          // ),
          // todayDecoration: BoxDecoration(
          //   color: Colors.grey.shade300,
          //   shape: BoxShape.rectangle,
          // ),
        // ),
      ),
    );
  }
}
