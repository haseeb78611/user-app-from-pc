
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:khuwari_user_app/screens/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../Services/toast.dart';
import '../Widgets/internet_connection_alert_dialog.dart';


class SlidesScreen extends StatefulWidget {
  final query;
  final name;
  final id; // id is mid or final
  const SlidesScreen({super.key,
    required this.query,
    required this.name,
    required this.id
  });
  @override
  State<SlidesScreen> createState() => _SlidesScreenState(query : query, name : name, id: id);
}
class _SlidesScreenState extends State<SlidesScreen> {
  final query;
  final name;
  final id;
  _SlidesScreenState({this.query, this.name, this.id});

  bool loading = false;
  double _progress = 0.0;

  saveFile(String url, String fileName) async {
    try{
      if(await permissionCheck(Permission.storage)){
        if(await Connectivity().checkConnectivity() != ConnectivityResult.none) {
          print(await Connectivity().checkConnectivity());
          FileDownloader.downloadFile(url: url, name: fileName,
            onDownloadCompleted: (path) {
              setState(() {loading = false;});
              print('File Downloaded');
              Toast().show('$fileName Downloaded');
            },
            onDownloadError: (errorMessage) {
              setState(() {loading = false;});
              Toast().show(errorMessage);
            },
            onProgress: (fileName, progress) {
              setState(() {
                _progress = progress/100;
              });
              print('This is progress : ' + progress.abs().toString());
            },
          );
        }else{
          setState(() {loading = false;});
          showDialog(context: context, builder: (context) {
            return InternetAlertDialog();
          },);
        }
      }else{
        setState(() {loading = false;});
      }
    }catch(e){
      setState(() {loading = false;});
      print(e);
    }
  }
  Future<bool> permissionCheck(Permission permission) async{
    if(await permission.isGranted){
      return true;
    }
    else{
      setState(() {loading = false;});
      var result = await permission.request();
      if(result ==  PermissionStatus.granted){
        Toast().show('Permission Granted');
        setState(() {loading = true;});
        return true;
      }
      else{
        Toast().show('Permission Denied');
        return false;
      }
    }

  }
  downloadFile(String url, String fileName) async {
    setState(() {loading = true;});
    await saveFile(url, fileName);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(name)
        ),
        body: Stack(
          children: [
            StreamBuilder(
              stream: query.child(id).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent>snapshot) {
                if(snapshot.hasData){
                  Map<dynamic,dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  var list ;
                  list = List.empty();
                  map.remove('name');
                  map.remove('id');
                  list = map.values.toList();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var path = list[index]['url'];
                      var name = list[index]['name'];
                      var time = list[index]['time'];
                      return InkWell(
                        onTap: () {
                        },
                        child: Card(
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8,),
                                        Icon(Icons.picture_as_pdf, size: 50,),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 2,
                                              height: 100,
                                              color: Colors.white,
                                            ),

                                            Container(
                                              height: 100,
                                              width: 80,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  InkWell(
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => PDf(path: path, name: name),));
                                                      },
                                                      child: Icon(Icons.remove_red_eye, color: Colors.white, size: 30,)),
                                                  InkWell(
                                                      onTap: (){
                                                        downloadFile(path, name);
                                                      },
                                                      child: Icon(Icons.download, color: Colors.white, size: 30))
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                        SizedBox(width: 10,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                      );
                    },);
                }
                else{
                  return StreamBuilder<ConnectivityResult>(
                      stream: Connectivity().onConnectivityChanged,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.active){
                          return Center(child: CircularProgressIndicator());
                        }
                        else{
                          return Center(child: Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_outlined, size: 200, color: Colors.black,));
                        }
                      }
                  );
                }
              },
            ),
            loading ?
            Positioned(
                bottom: 80,
                right: 50,
                left : 50,
                child:  Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 20,
                  child: LiquidLinearProgressIndicator(
                    value: _progress,
                    direction: Axis.horizontal,
                    valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                    center: Text('${_progress*100}%', style: TextStyle(color: Colors.black),),
                  ),
                )
            )
                :
            Container(height : 0)
          ],
        )

    );
  }
}
