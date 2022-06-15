import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Center(
            // child: Text(
            //   'LOADING...',
            //   style: TextStyle(
            //       color: Color.fromARGB(255, 162, 162, 162),
            //       fontSize: 14,
            //       height: 1.4,
            //       decoration: TextDecoration.none
            //   )
            // ),
            child: Image.asset(
          "assets/images/loading.gif",
        )));
  }
}
