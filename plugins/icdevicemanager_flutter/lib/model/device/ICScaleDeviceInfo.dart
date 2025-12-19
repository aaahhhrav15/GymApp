


import 'package:icdevicemanager_flutter/model/converter/ICDeviceInfoExtConverter.dart';
import 'package:icdevicemanager_flutter/model/device/ICDeviceInfoExt.dart';
import 'package:json_annotation/json_annotation.dart';

import '../other/ICConstant.dart';


part 'ICScaleDeviceInfo.g.dart';
@JsonSerializable()
class ICScaleDeviceInfo   {


  String mac = "";

  String model = "";

  String sn = "";

  String firmwareVer = "";

  String softwareVer = "";

  String hardwareVer = "";

  String manufactureName = "";

  @ICDeviceInfoExtConverter()
  ICDeviceInfoExt? extInfo ;

  int kg_scale_division = 0;

  int lb_scale_division = 0;

  bool isSupportHr = false;

  bool isSupportGravity = false;

  bool isSupportBalance = false;

  bool isSupportOTA = false;

  bool isSupportOffline = false;

  int bfDataCalcType = 0;

  bool isSupportUserInfo = false;

  int maxUserCount = 0;

  int batteryType = 0;

  ICBFAType bfaType = ICBFAType.ICBFATypeUnknown;
  ICBFAType bfaType2 = ICBFAType.ICBFATypeUnknown;

  bool isSupportUnitKg = false;

  bool isSupportUnitLb = false;

  bool isSupportUnitStLb = false;

  bool isSupportUnitJin = false;

  bool isSupportChangePole = false;

  int pole = 0;

  int impendenceType = 0;
  int impendenceCount = 0;
  int impendencePrecision = 0;

  int impendenceProperty = 0;

  bool enableMeasureImpendence = false;

  bool enableMeasureHr = false;

  bool enableMeasureBalance = false;

  bool enableMeasureGravity = false;

  ICScaleDeviceInfo();
}
