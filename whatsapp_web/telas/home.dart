import 'package:flutter/material.dart';
import 'package:whatsappweb/telas/home_mobile.dart';
import 'package:whatsappweb/telas/home_web.dart';
import 'package:whatsappweb/uteis/responsivo.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsivo(
        mobile: HomeMobile(),
        tablet: HomeWeb(),
        web: HomeWeb()
    );
  }
}
