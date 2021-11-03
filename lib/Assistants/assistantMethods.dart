
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_uber_clone/Assistants/requestAssistant.dart';
import 'package:flutter_uber_clone/DataHandler/appData.dart';
import 'package:flutter_uber_clone/Models/address.dart';
import 'package:flutter_uber_clone/Models/allUsers.dart';
import 'package:flutter_uber_clone/Models/directionDetails.dart';
import 'package:flutter_uber_clone/configMaps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods{

  //this is a method
  static Future<String>  searchCoordinateAddress(Position position, context) async{
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyB2jI4biZI9Lq9-dGXmnMnNq_XHGlS3iZc";

    var response = await RequestAssistant.getRequest(url);

    if(response != 'failed'){
      //placeAddress = response["results"][0]["formatted_address"];
      
      st1 = response["results"][0]["address_components"][0]["long_name"]; //house number
      //st2 = response["results"][0]["address_components"][1]["long_name"]; // street number
      //st3 = response["results"][0]["address_components"][5]["long_name"];
      //st4 = response["results"][0]["address_components"][6]["long_name"]; //country
      placeAddress = st1 ;
      //placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickUpAddress = new Address(placeName: placeAddress, longitude: position.longitude, latitude: position.latitude, placeId: '', placeFormattedAddress: '', );
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;


      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }



  //here's a separate method to getting the direction details. here we must pass two parameters like starting (pickup)
  // and the ending(drop-off) locations. that is we will draw routes between two places. here we return the
  // 'directionDetails' at last. that's why this method type is in 'static Future<DirectionDetails>'
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async{
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed"){
      return null;
    }

    //Here it created an instance of the 'DirectionDetails' class
    DirectionDetails directionDetails = DirectionDetails(
        distanceValue: res["routes"][0]["legs"][0]["distance"]["value"],
        durationValue: res["routes"][0]["legs"][0]["duration"]["value"],
        distanceText: res["routes"][0]["legs"][0]["distance"]["text"],
        durationText: res["routes"][0]["legs"][0]["duration"]["text"],
        encodedPoints: res["routes"][0]["overview_polyline"]["points"]
    );

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }



  static int calculateFares(DirectionDetails directionDetails){
    //in terms of USD per each minute
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.2;
    //in terms per km.
    double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.2;

    double totalFareamount = timeTraveledFare + distanceTraveledFare;

    //1$ = 199.89Rs  //here we converted it to local currency (Sri Lankan Rupees)
    double totalLocalFareAmount = totalFareamount * 199.89;

    return totalLocalFareAmount.truncate();
  }



  static void getCurrentOnlineUserInfo() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser)!;
    String userId = firebaseUser.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot){
      if(dataSnapShot.value != null){
        userCurrentInfo = Users.fromSnapshot(dataSnapShot);
      }
    });
  }

}









