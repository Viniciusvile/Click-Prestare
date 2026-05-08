import 'package:click/pages/shared/my_condominium.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CardMenu extends StatelessWidget {
  const CardMenu({
    Key? key,
    required this.item,
  }) : super(key: key);

  final HomeMenuModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 6.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.pool, size: 90, color: Colors.blue),
            Image(
              image: item.image,
              fit: BoxFit.cover,
              height: 60,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: LabelDefault(title: item.nome, size: 20, color: Theme.of(context).hintColor, weight: FontWeight.w400, maxLines: 2, align: TextAlign.center,)
            ),
          ],
        ),
      ),
    );
  }
}
