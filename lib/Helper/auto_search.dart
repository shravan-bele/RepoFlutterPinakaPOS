
import 'package:flutter/foundation.dart';


// Mock Test Item Class
class ProductItem {
  final String label;
  dynamic value;

  ProductItem({required this.label, this.value});

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(label: json['label'], value: json['value']);
  }
}

class SearchProduct {

  List _productList = <dynamic>[];
  List get productList => _productList;
  bool isOnline = true;
  // Build #1.1.226: Fixed - updated xCountryCode to global string to fix the destinationController not getting auto search result because country code is empty
  // Cause: SearchAutoSuggest _autoSuggest; is initializing second time when AddDestination calls, that time xCountryCode is empty
  //String xCountryCode ="";

  set productList(List value) {
    _productList = value;

  }
  SearchProduct(){

  }

  Future<List> getProductResults() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Search for "Pizza" and show the results on the map.
    // _searchExample();

    // Search for auto suggestions and log the results to the console.
    // return _autoSuggestExample();
    if (kDebugMode) {
      print("1 object######################### ${_productList.length} \n");
    }
    return _productList;
  }
  listentextchange(String text){
    fetchSimpleData();
   // _autoSuggestExample(text , isChooseOnMapAvailable);
    if (kDebugMode) {
      // print("2 object#########################$_placelist \n");
    }
  }

  Future<List> fetchSimpleData() async {
    // await Future.delayed(Duration(milliseconds: 2000));
    _productList.clear();
    _productList.add(ProductItem(label: "Milk",value: ""));
    _productList.add(ProductItem(label: "Milk1",value: ""));
    return _productList;
  }

  Future<List> _autoSuggestExample(String text, bool isChooseOnMapAvailable) async {

    if (kDebugMode) {
      print("_autoSuggestExample ######################### $text, $_productList \n");
      _productList.forEach((element) {
        print("place#########################${element.label} \n");
      });
    }
    if(text.isEmpty){
      return [];
    }

    _productList.clear();

   ///perform search and update the productList

    return _productList;
  }

  // void searchResult(String text,  List<Suggestion>? list){
  //   if (searchError != null) {
  //     ///Add logs for the errors
  //     if (kDebugMode) {
  //       print("Auto suggest Error (Online): $text, $searchError");
  //     }
  //     return;
  //   }
  //   // If error is null, list is guaranteed to be not empty.
  //   int listLength = list!.length;
  //   if (kDebugMode) {
  //     print("Auto suggest results: $listLength.");
  //   }
  //   _productList.clear();
  //
  //  ///read the items from list and add to the product items before showing on UI
  //   // for (ProductItem autoSuggestResult in list) {
  //   //   String addressText = "Not a place.";
  //   //   Place? place = autoSuggestResult.place;
  //   //   // List _list = <dynamic>[];
  //   //   if (place != null) {
  //   //     var address = place.address.addressText.split(',');
  //   //     addressText = place.address.addressText;//.substring(0,55);
  //   //     if (kDebugMode) {
  //   //       print("place : ${place.address.addressText}.");
  //   //     }
  //   //     // addressText = place.address.street + place.address.state;
  //   //     _productList.add(ProductItem(label: addressText,value: place));
  //   //   }
  //   // }
  //   if (kDebugMode) {
  //     // _placelist.forEach((element) {
  //       // print("4 object#########################${element.label} \n");
  //     // });
  //
  //   }
  // }
}