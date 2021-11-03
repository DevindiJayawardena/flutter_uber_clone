import 'package:flutter/material.dart';
import 'package:flutter_uber_clone/AllWidgets/divider.dart';
import 'package:flutter_uber_clone/AllWidgets/progressDialog.dart';
import 'package:flutter_uber_clone/Assistants/requestAssistant.dart';
import 'package:flutter_uber_clone/DataHandler/appData.dart';
import 'package:flutter_uber_clone/Models/address.dart';
import 'package:flutter_uber_clone/Models/placePredictions.dart';
import 'package:provider/provider.dart';
import '../configMaps.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {

    //using the provider we have to retrieve the address
    String placeAddress = Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 210.0,
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, top: 40.0, right: 25.0, bottom: 30.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 5.0,),

                    Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child : Text(
                            "Set Drop off Location",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0,),

                    Row(
                      children: <Widget>[
                        Image.asset("images/pickicon.png", height: 16.0, width : 16.0,),
                        SizedBox(width: 5.0,),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Pickup Location",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense : true,
                                  contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.0,),

                    Row(
                      children: <Widget>[
                        Image.asset("images/desticon.png", height: 16.0, width : 16.0,),

                        SizedBox(width: 5.0,),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                //whenever user writes something in this text field it will trigger this below 'onChanged'
                                onChanged: (val){
                                  findPlace(val);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Where to?",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense : true,
                                  contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),
            ),


            //tile for displaying predictions
            SizedBox(height: 14.0,),

            (placePredictionList.length > 0)
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0,),
                    child: ListView.separated(
                      padding: EdgeInsets.all(6.0),
                      itemBuilder: (context, index){
                        return PredictionTile(placePredictions: placePredictionList[index],);
                      },
                      separatorBuilder: (BuildContext context, int index) => DividerWidget(),
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),

          ],
        ),
      ),
    );
  }



  void findPlace(String placeName) async{
    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:lk";

      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if(res == "failed"){
        return;
      }
      print("Places Predictions Response :: ");
      print(res);

      if(res["status"] == "OK"){
        var predictions = res["predictions"];
        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }

}





class PredictionTile extends StatelessWidget {

  final PlacePredictions placePredictions;
  PredictionTile({Key? key, required this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
        padding: MaterialStateProperty.all(EdgeInsets.all(10.0,)),
      ),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        //padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            SizedBox(height : 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.add_location),
                SizedBox(width : 15.0,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 4.0,),
                      Text(
                        placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 16.0,),
                      ),
                      SizedBox(height: 3.0,),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(height: 0.0,),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width : 10.0),
          ],
        ),
      ),
    );
  }



  void getPlaceAddressDetails(String placeId, context) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: 'Setting Drop-off location. Please wait!',),
    );

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    Navigator.pop(context); //to pop up the progress bar

    if(res == "failed"){
      return;
    }

    if(res["status"] == "OK"){
      Address address = Address(
        longitude: res["result"]["geometry"]["location"]["lng"],
        latitude: res["result"]["geometry"]["location"]["lat"],
        placeFormattedAddress: '',
        placeName: res["result"]["name"],
        placeId: placeId,
      );
      //address.placeName = res["result"]["name"];
      //address.placeId = placeId;
      //address.latitude = res["result"]["geometry"]["location"]["lat"];
      //address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen : false).updateDropOffLocationAddress(address);
      print("This is Drop off location :: ");
      print(address.placeName);

      Navigator.pop(context, "obtainDirection"); //once we get the searched place successfully, we have to close
                                        // this screen & return back to the mainScreen
    }
  }


}


