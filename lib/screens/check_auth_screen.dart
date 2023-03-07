import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/auth_service.dart';


class CheckAuthScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: FutureBuilder(
        future: authService.readToken(),
        
        builder: (BuildContext context, AsyncSnapshot<String> snapshot){

           
          Future.microtask(
              () async {
                final resp = await authService.readToken();
                if (resp != '' && resp != null) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => HomeScreen(),
                      transitionDuration: const Duration(seconds: 0),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LoginScreen(),
                      transitionDuration: const Duration(seconds: 0),
                    ),
                  );
                }
              },
            );
                 return Container();

          },
        ),
     ),
   );
  }
}