import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';

class ICConverUtil {
  static ICBleState nameOf(String name) {
    switch (name) {
      case "ICBleStateUnknown":
        return ICBleState.ICBleStateUnknown;
      case "ICBleStateUnsupported":
        return ICBleState.ICBleStateUnsupported;
      case "ICBleStateUnauthorized":
        return ICBleState.ICBleStateUnauthorized;

      case "ICBleStatePoweredOff":
        return ICBleState.ICBleStatePoweredOff;
      case "ICBleStatePoweredOn":
        return ICBleState.ICBleStatePoweredOn;
      case "ICBleStateException":
        return ICBleState.ICBleStateException;
    }
    return ICBleState.ICBleStateException;
  }

  static ICDeviceConnectState connectStateNameOf(String value) {
    if ("ICDeviceConnectStateConnected" == value) {
      return ICDeviceConnectState.ICDeviceConnectStateConnected;
    } else {
      return ICDeviceConnectState.ICDeviceConnectStateDisconnected;
    }
  }


  static ICAddDeviceCallBackCode AddDeviceCallBackCodeNameOf(String name) {
    switch (name) {
      case "ICAddDeviceCallBackCodeSuccess":
        return ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeSuccess;
      case "ICAddDeviceCallBackCodeFailedAndSDKNotInit":
        return ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeFailedAndSDKNotInit;
      case "ICAddDeviceCallBackCodeFailedAndExist":
        return ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeFailedAndExist;
    }
    return ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeFailedAndDeviceParamError;
  }


  static ICRemoveDeviceCallBackCode removeDeviceCallBackCodeNameOf(String name) {
    switch (name) {
      case "ICRemoveDeviceCallBackCodeSuccess":
        return ICRemoveDeviceCallBackCode.ICRemoveDeviceCallBackCodeSuccess;
      case "ICRemoveDeviceCallBackCodeFailedAndSDKNotInit":
        return ICRemoveDeviceCallBackCode.ICRemoveDeviceCallBackCodeFailedAndSDKNotInit;
      case "ICRemoveDeviceCallBackCodeFailedAndNotExist":
        return ICRemoveDeviceCallBackCode.ICRemoveDeviceCallBackCodeFailedAndNotExist;
    }
    return ICRemoveDeviceCallBackCode.ICRemoveDeviceCallBackCodeFailedAndDeviceParamError;
  }


  static ICSettingCallBackCode settingCodeNameOf(String name) {
    switch (name) {
      case "ICSettingCallBackCodeSuccess":
        return ICSettingCallBackCode.ICSettingCallBackCodeSuccess;
      case "ICSettingCallBackCodeSDKNotInit":
        return ICSettingCallBackCode. ICSettingCallBackCodeSDKNotInit;
      case "ICSettingCallBackCodeSDKNotStart":
        return ICSettingCallBackCode.ICSettingCallBackCodeSDKNotStart;
      case "ICSettingCallBackCodeDeviceNotFound":
        return ICSettingCallBackCode.ICSettingCallBackCodeDeviceNotFound;
      case "ICSettingCallBackCodeFunctionIsNotSupport":
        return ICSettingCallBackCode.ICSettingCallBackCodeFunctionIsNotSupport;
      case "ICSettingCallBackCodeDeviceDisConnected":
        return ICSettingCallBackCode.ICSettingCallBackCodeDeviceDisConnected;
      case "ICSettingCallBackCodeInvalidParameter":
        return ICSettingCallBackCode.ICSettingCallBackCodeInvalidParameter;
    }
    return ICSettingCallBackCode.ICSettingCallBackCodeFailed;
  }


  static ICWeightUnit weightUnitValueOf(int value) {
    switch (value) {
      case 0:
        return ICWeightUnit.ICWeightUnitKg;
      case 1:
        return ICWeightUnit.ICWeightUnitLb;
      case 2:
        return ICWeightUnit.ICWeightUnitSt;
      case 3:
        return ICWeightUnit.ICWeightUnitJin;
    }
    return ICWeightUnit.ICWeightUnitKg;
  }

  static ICWeightUnit weightUnitNameOf(String name) {
    switch (name) {
      case "ICWeightUnitKg":
        return ICWeightUnit.ICWeightUnitKg;
      case "ICWeightUnitLb":
        return ICWeightUnit.ICWeightUnitLb;
      case "ICWeightUnitSt":
        return ICWeightUnit.ICWeightUnitSt;
      case "ICWeightUnitJin":
        return ICWeightUnit.ICWeightUnitJin;
    }
    return ICWeightUnit.ICWeightUnitKg;
  }

  static ICRulerUnit rulerUnitNameOf(String name) {
    switch (name) {
      case "ICRulerUnitCM":
        return ICRulerUnit.ICRulerUnitCM;
      case "ICRulerUnitInch":
        return ICRulerUnit.ICRulerUnitInch;
      case "ICRulerUnitFtInch":
        return ICRulerUnit.ICRulerUnitFtInch;
    }
    return ICRulerUnit.ICRulerUnitCM;
  }

  static ICRulerUnit rulerUnitValueOf(int value) {
    switch (value) {
      case 0:
        return ICRulerUnit.ICRulerUnitCM;
      case 1:
        return ICRulerUnit. ICRulerUnitInch;
      case 2:
        return ICRulerUnit.ICRulerUnitFtInch;
    }
    return ICRulerUnit.ICRulerUnitCM;
  }

  static ICRulerMeasureMode rulerMeasureModeValueOf(int value) {
    switch (value) {
      case 1:
        return ICRulerMeasureMode.ICRulerMeasureModeLength;
      case 2:
        return ICRulerMeasureMode.ICRulerMeasureModeGirth;
    }
    return ICRulerMeasureMode.ICRulerMeasureModeLength;
  }

  static ICRulerMeasureMode rulerMeasureModeNameOf(String value) {
    switch (value) {
      case "ICRulerMeasureModeLength":
        return ICRulerMeasureMode.ICRulerMeasureModeLength;
      case "ICRulerMeasureModeGirth":
        return ICRulerMeasureMode.ICRulerMeasureModeGirth;
    }
    return ICRulerMeasureMode.ICRulerMeasureModeLength;
  }


  static ICRulerBodyPartsType rulerBodyPartsValueOf(int value) {
    switch (value) {
      case 1:
        return ICRulerBodyPartsType.ICRulerPartsTypeShoulder;
      case 2:
        return ICRulerBodyPartsType.ICRulerPartsTypeBicep;
      case 3:
        return ICRulerBodyPartsType.ICRulerPartsTypeChest;
      case 4:
        return ICRulerBodyPartsType.ICRulerPartsTypeWaist;
      case 5:
        return ICRulerBodyPartsType.ICRulerPartsTypeHip;
      case 6:
        return ICRulerBodyPartsType.ICRulerPartsTypeThigh;
      case 7:
        return ICRulerBodyPartsType.ICRulerPartsTypeCalf;
    }
    return ICRulerBodyPartsType.ICRulerPartsTypeShoulder;
  }

  static ICConfigWifiState wifiStateNameOf(String value) {
    switch (value) {
      case "ICConfigWifiStateSuccess":
        return ICConfigWifiState.ICConfigWifiStateSuccess;
      case "ICConfigWifiStateWifiConnecting":
        return ICConfigWifiState.ICConfigWifiStateWifiConnecting;
      case "ICConfigWifiStateServerConnecting":
        return ICConfigWifiState.ICConfigWifiStateServerConnecting;
      case "ICConfigWifiStateWifiConnectFail":
        return ICConfigWifiState.ICConfigWifiStateWifiConnectFail;
      case "ICConfigWifiStateServerConnectFail":
        return ICConfigWifiState.ICConfigWifiStateServerConnectFail;
      case "ICConfigWifiStatePasswordFail":
        return ICConfigWifiState.ICConfigWifiStatePasswordFail;
    }
    return ICConfigWifiState.ICConfigWifiStateFail;
  }

  static ICUpgradeStatus upgradeStatusNameOf(String value) {
    switch (value) {
      case "ICUpgradeStatusSuccess":
        return ICUpgradeStatus.ICUpgradeStatusSuccess;
      case "ICUpgradeStatusUpgrading":
        return ICUpgradeStatus.ICUpgradeStatusUpgrading;
      case "ICUpgradeStatusFail":
        return ICUpgradeStatus.ICUpgradeStatusFail;
      case "ICUpgradeStatusFailFileInvalid":
        return ICUpgradeStatus.ICUpgradeStatusFailFileInvalid;
      case "ICUpgradeStatusFailNotSupport":
        return ICUpgradeStatus.ICUpgradeStatusFailNotSupport;
    }
    return ICUpgradeStatus.ICUpgradeStatusFailNotSupport;
  }

  static ICMeasureStep measureStepNameOf(String value) {
    switch (value) {
      case "ICMeasureStepMeasureWeightData":
        return ICMeasureStep.ICMeasureStepMeasureWeightData;
      case "ICMeasureStepMeasureCenterData":
        return ICMeasureStep.ICMeasureStepMeasureCenterData;
      case "ICMeasureStepAdcStart":
        return ICMeasureStep.ICMeasureStepAdcStart;
      case "ICMeasureStepAdcResult":
        return ICMeasureStep.ICMeasureStepAdcResult;
      case "ICMeasureStepHrStart":
        return ICMeasureStep.ICMeasureStepHrStart;
      case "ICMeasureStepHrResult":
        return ICMeasureStep.ICMeasureStepHrResult;
      case "ICMeasureStepMeasureOver":
        return ICMeasureStep.ICMeasureStepMeasureOver;
    }

    return ICMeasureStep.ICMeasureStepMeasureWeightData;
  }

  static ICKitchenScaleUnit kitChenScaleUnitNameOf(String name) {
    switch (name) {
      case "ICKitchenScaleUnitG":
        return ICKitchenScaleUnit. ICKitchenScaleUnitG;
      case "ICKitchenScaleUnitMl":
        return ICKitchenScaleUnit. ICKitchenScaleUnitMl;
      case "ICKitchenScaleUnitLb":
        return ICKitchenScaleUnit.ICKitchenScaleUnitLb;
      case "ICKitchenScaleUnitOz":
        return ICKitchenScaleUnit.ICKitchenScaleUnitOz;
      case "ICKitchenScaleUnitMg":
        return ICKitchenScaleUnit.ICKitchenScaleUnitMg;
      case "ICKitchenScaleUnitMlMilk":
        return ICKitchenScaleUnit.ICKitchenScaleUnitMlMilk;
      case "ICKitchenScaleUnitFlOzWater":
        return ICKitchenScaleUnit.ICKitchenScaleUnitFlOzWater;
      case "ICKitchenScaleUnitFlOzMilk":
        return ICKitchenScaleUnit.ICKitchenScaleUnitFlOzMilk;
    }
    return ICKitchenScaleUnit.ICKitchenScaleUnitG;
  }

  static ICKitchenScaleUnit kitchenScaleValueOf(int value) {
    switch (value) {
      case 0:
        return ICKitchenScaleUnit. ICKitchenScaleUnitG;
      case 1:
        return ICKitchenScaleUnit.ICKitchenScaleUnitMl;
      case 2:
        return ICKitchenScaleUnit.ICKitchenScaleUnitLb;
      case 3:
        return ICKitchenScaleUnit.ICKitchenScaleUnitOz;
      case 4:
        return ICKitchenScaleUnit.ICKitchenScaleUnitMg;
      case 5:
        return ICKitchenScaleUnit.ICKitchenScaleUnitMlMilk;
      case 6:
        return ICKitchenScaleUnit.ICKitchenScaleUnitFlOzWater;
      case 7:
        return ICKitchenScaleUnit.ICKitchenScaleUnitFlOzMilk;
    }
    return ICKitchenScaleUnit.ICKitchenScaleUnitG;
  }
}
