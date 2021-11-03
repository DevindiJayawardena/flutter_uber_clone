import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_uber_clone/AllScreens/searchScreen.dart';
import 'package:flutter_uber_clone/AllWidgets/divider.dart';
import 'package:flutter_uber_clone/AllWidgets/progressDialog.dart';
import 'package:flutter_uber_clone/Assistants/assistantMethods.dart';
import 'package:flutter_uber_clone/DataHandler/appData.dart';
import 'package:flutter_uber_clone/Models/directionDetails.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../configMaps.dart';
import 'loginScreen.dart';



class MainScreen extends StatefulWidget {

  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();  //this is to open the drawer

  //late DirectionDetails tripDirectionDetails = null;
  var tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};


  //now we're going to get the user's current location
  late Position currentPosition;
  var geoLocator = Geolocator(); //this 'geoLocator' is an instance of 'Geolocator()'
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 280.0;

  bool drawerOpen = true;

  late DatabaseReference rideRequestRef;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }


  void saveRideRequest(){
    rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen : false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen : false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude" : pickUp.latitude.toString(),
      "longitude" : pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude" : dropOff.latitude.toString(),
      "longitude" : dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id" : "waiting",
      "payment_method" : "cash",
      "pickup" : pickUpLocMap,
      "dropoff" : dropOffLocMap,
      "created_at" : DateTime.now().toString(),
      "rider_name" : userCurrentInfo.name,
      "rider_phone" : userCurrentInfo.phone,
      "pickup_address" : pickUp.placeName,
      "dropoff_address" : dropOff.placeName,
    };

    rideRequestRef.set(rideInfoMap);
  }



  //this is a function when the user wants to cancel a ride request
  void cancelRideRequest() {
    rideRequestRef.remove();
  }



  //this is a function to display that cancel ride, request ride container
  void displayRequestRideContainer(){
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }



  //this is a function which will reset the application
  resetApp(){
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition(); //we call this in order to get updated data
  }



  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 230.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }



  //here, we're going to get the user's current location
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14,);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your Address ::" + address);
  }



  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key : scaffoldKey, //this is to open the drawer
      appBar: AppBar(
        title: Text(
          "Main Screen",
          style : TextStyle(fontSize: 27, color: Colors.black54,),
        ),
      ),

      drawer: Container(
        color:Colors.white,
        width: 280.0,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.yellow[100],),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height : 65.0, width : 65.0,),
                      SizedBox(width : 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand bold",),),
                          SizedBox(height: 6.0),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.0,),

              //Drawer body controllers
              ListTile(
                leading: Icon(Icons.history, color : Colors.yellow[800]),
                title: Text("History", style: TextStyle(fontSize: 15.0,)),
              ),

              DividerWidget(),

              ListTile(
                leading: Icon(Icons.person, color : Colors.yellow[800]),
                title: Text("Visit Profile", style: TextStyle(fontSize: 15.0,)),
              ),

              DividerWidget(),

              ListTile(
                leading: Icon(Icons.info, color : Colors.yellow[800]),
                title: Text("About", style: TextStyle(fontSize: 15.0,)),
              ),

              DividerWidget(),

              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout_outlined, color : Colors.yellow[800]),
                  title: Text("Sign Out", style: TextStyle(fontSize: 15.0,)),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController= controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();   //here, we're going to get the user's current location
            },
          ),

          //this is the Hamburger button for drawer
          Positioned(
            top: 23.0,
            left: 32.0,
            child: GestureDetector(
              onTap: () {
                if(drawerOpen){
                  scaffoldKey.currentState!.openDrawer();
                }
                else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset : Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),


          Positioned(  //hey there container (SEARCH CONTAINER)
            left: 0.0,
            right: 0.0,
            bottom:0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 2.0),

                      Text(
                        "Hey There, ",
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      Text(
                        "Where to? ",
                        style: TextStyle(fontSize: 23.0, fontFamily: "Brand Bold"),
                      ),

                      SizedBox(height: 11.0),

                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(context,MaterialPageRoute(builder:(context)=>SearchScreen()));

                          //this is comes from 'searchScreen's 'getPlaceAddressDetails' method
                          if(res == "obtainDirection"){
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
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
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.search, color: Colors.yellow[700]),
                                SizedBox(width : 10.0),
                                Text(
                                  "Search Drop off Location", style: TextStyle(color : Colors.grey,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 18.0,),

                      Row(
                        children: <Widget>[
                          Icon(Icons.home, color : Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Provider.of<AppData>(context).pickUpLocation != null
                                    ? Provider.of<AppData>(context).pickUpLocation.placeName
                                    : "Add Home"
                              ),
                              SizedBox(height: 4.0,),
                              Text(
                                "Your living home address: ",
                                style: TextStyle(
                                  color: Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 10.0,),

                      DividerWidget(),

                      SizedBox(height: 10.0,),

                      Row(
                        children: <Widget>[
                          Icon(Icons.work, color : Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Add Work"),
                              SizedBox(height: 4.0,),
                              Text(
                                "Your office address: ",
                                style: TextStyle(
                                  color: Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(   //rideDetailsContainer
                height : rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.0,),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width : double.infinity,
                        color: Colors.yellow[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: <Widget>[
                              Image.asset("images/taxi.png", height : 70.0, width : 80.0,),

                              SizedBox(width : 60.0),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Car", style: TextStyle(fontSize : 18.0, fontFamily: "Brand Bold",),),
                                  Text(
                                    ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '') ,
                                    style: TextStyle(fontSize : 18.0, color: Colors.grey[700]),
                                  ),
                                ],
                              ),

                              Expanded(
                                child: Container(),
                              ),

                              Text(
                                ((tripDirectionDetails != null) ? '\Rs. ${AssistantMethods.calculateFares(tripDirectionDetails)}'
                                    : ''),
                                style: TextStyle(fontFamily: "Brand Bold", fontSize: 17.0),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height : 10.0),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 38.0),
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.moneyCheckAlt, size : 18.0, color : Colors.black54,),
                            SizedBox(width : 16.0),
                            Text("Cash"),
                            SizedBox(width : 6.0),
                            Icon(Icons.keyboard_arrow_down, color : Colors.black54, size : 16.0,),
                          ],
                        ),
                      ),

                      SizedBox(height : 24.0),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36.0),
                        child: RaisedButton(
                          onPressed: () {
                            displayRequestRideContainer();
                            print("Button is clicked!");
                          },
                          //color: Theme.of(context).accentColor,
                          color: Colors.yellow[700],
                          child : Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request",
                                  style: TextStyle(
                                    fontSize: 23.0, fontWeight: FontWeight.bold, color: Colors.white,
                                  ),
                                ),
                                Icon(FontAwesomeIcons.taxi, color : Colors.white, size: 24.0,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: requestRideContainerHeight,
              child : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height : 12.0),

                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: (){
                          print("Tap Event");
                        },
                        text : [
                          "Requesting a Ride...",
                          "Please wait...",
                          "Finding a Driver...",
                        ],
                        textStyle: TextStyle(
                          fontSize: 55.0,
                          fontFamily: "Signatra",
                        ),
                        colors : [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                        //alignment : AlignmentDirectional.topStart, // Alignment.topLeft
                      ),
                    ),

                    SizedBox(height : 22.0),

                    GestureDetector(
                      onTap: (){
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 55.0,
                        width : 55.0,
                        decoration: BoxDecoration(
                          color : Colors.white,
                          borderRadius: BorderRadius.circular(29.0),
                          border: Border.all(width : 2.0, color : Colors.grey,),
                        ),
                        child : Icon(Icons.close, size : 27.0),
                      ),
                    ),

                    SizedBox(height : 10.0),

                    Container(
                      width : double.infinity,
                      child : Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  //this is a separate function to get the direction from the pickup location to destination
  Future<void> getPlaceDirection() async{
    //here we're getting the place's direction for the pickup location and destination location
    var initialPos = Provider.of<AppData>(context, listen : false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen : false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude); //this is the position for pick up location
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude); //this is the position for drop off location

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait!"),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details!;
    });

    Navigator.pop(context); //pop the dialog box

    print("This is Encoded points ::");
    print(details!.encodedPoints); //these 'encodedPoints' points are set of points which contains set of
                                          // latitudes & longitudes

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if(decodedPolyLinePointsResult.isNotEmpty){
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }


    polylineSet.clear();


    setState((){
      Polyline polyline = Polyline(
        color: Colors.pinkAccent,
        polylineId: PolylineId("PolylineId"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width : 4,
        startCap : Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic : true,
      );

      polylineSet.add(polyline);
    });


    //to make the polyline to fit it to the map using the LatLngBounds
    LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(
        southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
      );
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude){
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
      );
    }
    else{
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }


    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    //we can create a marker for the pickup location
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Pick-up location",),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );


    //we can create a marker for the drop off location
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Drop-off location",),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );


    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });



    //this is the pickUpLocation Circle
    Circle pickUpLocCircle = Circle(
      fillColor: Colors.yellow,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId : CircleId("pickUpId"),
    );



    //this is the dropOffLocation Circle
    Circle dropOffLocCircle = Circle(
      fillColor: Colors.purple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.purpleAccent,
      circleId : CircleId("dropOffId"),
    );


    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

}
