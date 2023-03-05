import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:khuwari_user_app/screens/select_type_screen.dart';

class _MainScaffold extends StatefulWidget {
  const _MainScaffold({Key? key}) : super(key: key);

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  final database =  FirebaseDatabase.instance.ref();
  final _advancedDrawerController = AdvancedDrawerController();
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          onPressed: _handleMenuButtonPressed,
          icon: ValueListenableBuilder<AdvancedDrawerValue>(
            valueListenable: _advancedDrawerController,
            builder: (_, value, __) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: Icon(
                  value.visible ? Icons.clear : Icons.menu,
                  key: ValueKey<bool>(value.visible),
                ),
              );
            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: database.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            var list = snapshot.data!.snapshot.children.toList();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (
                        context) =>
                        SelectTypeScreen(semester: list[index]
                            .child('semester')
                            .value as String,)));
                  },
                  child: Card(
                    color: Colors.blue,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text(
                          list[index]
                              .child('semester')
                              .value as String,
                          style: TextStyle(fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),),
                          Text('Semester', style: TextStyle(fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                        ]
                    ),
                  ),
                );
              },);
          }
          else {
            return StreamBuilder<ConnectivityResult>(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return Center(child: CircularProgressIndicator());
                  }
                  else {
                    return Center(child: Icon(Icons
                        .signal_wifi_statusbar_connected_no_internet_4_outlined,
                      size: 200, color: Colors.black,));
                  }
                }
            );
          }
        },
      ),
    );
  }
}
