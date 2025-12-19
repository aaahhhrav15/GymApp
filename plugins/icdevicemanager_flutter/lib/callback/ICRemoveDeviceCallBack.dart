

import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';

class ICRemoveDeviceCallBack {
  final void Function(ICDevice icDevice, ICRemoveDeviceCallBackCode code) callBack;
  ICRemoveDeviceCallBack({required this.callBack});
}