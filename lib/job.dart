import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'api.dart';
class job extends StatefulWidget {
  const job({Key? key}) : super(key: key);

  @override
  State<job> createState() => _jobState();
}

class _jobState extends State<job> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  List<String> _status = ["Pending", "Released", "Blocked"];
  String _singleValue = "Text alignment right";
  String _verticalGroupValue = "Pending";
  String baggaeNumber="";
  api common = api();
  List<Widget> listWidget=[];
  var items = [
    'Waiting For Wash',
    'Washing',
    'Ironing',
    'Waiting For Pickup',

  ];
  String dropdownvalue = 'Waiting For Wash';
  void initState() {
    getBaggage();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            child: Icon(Icons.refresh),
            onTap: (){
              onRefresh();
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("request").where("baggageNumber",isEqualTo: baggaeNumber).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                    if (snapshot.hasData) {
                      listWidget.clear();
                      snapshot.data?.docs.forEach((element) {
                        bool isSoftwash=false;
                        bool isDrywash=false;
                        bool isNormalwash=false;



                       try {
                         isSoftwash=element.get('Soft Wash');
                       } catch (error) {
                           isSoftwash=false;
                       }

                       try {
                         isDrywash =element.get('Dry Wash');
                       } catch (error) {
                          isDrywash=false;
                       }

                       try {
                          isNormalwash=element.get('normalWash');
                       } catch (error) {
                          isNormalwash=false;
                       }



                        listWidget.add(

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Name : '+element['userName'],style: TextStyle(color: Colors.black),),
                                isDrywash?Text("Dry Wash Quantity :"+element['Dry Washqty'].toString()):Text("Dry Wash :None"),
                                isSoftwash?Text("Soft Wash Quantity :"+element['Soft Washqty'].toString()):Text("Soft Wash :None"),
                                isNormalwash?Text("Normal Wash Quantity :"+element['normalWashqty'].toString()):Text("Normal Wash:None"),

                                DropdownButton(

                                  // Initial Value
                                  value: dropdownvalue,

                                  // Down Arrow Icon
                                  icon: const Icon(Icons.keyboard_arrow_down),


                                  // Array list of items
                                  items: items.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (String? newValue) {
                                    dropdownvalue = newValue.toString();
                                    print(dropdownvalue);
                                    var data={"status":newValue};
                                    common.updateFirebase(element.reference.id, data,"request");





                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,vertical: 16,
                                  ),
                                  child: RoundedLoadingButton(
                                    width: 150,
                                    child: Text('Done Washing', style: TextStyle(color: Colors.white)),
                                    controller: _btnController,
                                    onPressed: (){
                                      finishedWork(element.reference.id);

                                    },
                                  ),
                                ),

                              ],
                            ),
                          )

                        );

                      });
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: (Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: listWidget,)));
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error_outline);
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  void getBaggage() async{
    baggaeNumber=await  common.getPref("baggageNumber");
    setState(() { });
  }

  void onRefresh() {

    setState(() {  });
  }

  void finishedWork(String refId) {
    var data={"status":"Completed.Waiting For Pickup"};
    common.updateFirebase(refId, data, "request");
    _btnController.success();

  }


}
