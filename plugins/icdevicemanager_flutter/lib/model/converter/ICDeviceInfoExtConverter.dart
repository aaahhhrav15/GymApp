import 'dart:convert';


import 'package:icdevicemanager_flutter/model/device/ICDeviceInfoExt.dart';
import 'package:json_annotation/json_annotation.dart';


class ICDeviceInfoExtConverter implements JsonConverter<ICDeviceInfoExt, String> {
  const ICDeviceInfoExtConverter();

  @override
  ICDeviceInfoExt fromJson(String data) {
    return ICDeviceInfoExt.fromJson( json.decode(data));
  }

  @override
  String toJson(ICDeviceInfoExt data) => json.encode(data);
}
