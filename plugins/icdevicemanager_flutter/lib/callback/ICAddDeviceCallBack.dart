



import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';

class ICAddDeviceCallBack {
  final void Function(ICDevice icDevice, ICAddDeviceCallBackCode code) callBack;
  ICAddDeviceCallBack({required this.callBack});
}