import 'package:flutter/material.dart';
import 'package:flutter_uber_clone/Models/address.dart';

class AppData extends ChangeNotifier{

  var pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

}