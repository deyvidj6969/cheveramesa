import 'package:engineering/widgets/optioncard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildOptionCard(FontAwesomeIcons.calendarDay, '25 oct', 100),
          buildOptionCard(FontAwesomeIcons.clock, '12:30 p.m.', 120),
          buildOptionCard(FontAwesomeIcons.userFriends, '3 personas', 125),
        ],
      ),
    );
  }
}
