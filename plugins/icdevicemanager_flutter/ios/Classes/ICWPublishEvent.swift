//
//  ICWPublishEvent.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/8.
//

struct ICWPublishEvent{
     static let InitSDK = "InitSDK";
     static let AddDevice = "AddDevice";
     static let AddDevices = "AddDevices";
     static let DeleteDevice = "RemoveDevice";
     static let DeleteDevices = "RemoveDevices";

     static let OTADevice = "OTADevice";
     static let OTADevices = "OTADevices";
     static let StopOTADevice = "StopOTADevice";
     static let StopOTADevices = "StopOTADevices";

     static let StopScan = "StopScan";
     static let StartScan = "StartScan";
     static let SetUserInfo = "SetUserInfo";
     static let SetUserList = "SetUserList";



     static let ScaleUnitSetting = "setScaleUnit";
     static let ScaleConfigWifi = "configWifi";

     static let RulerUnitSetting = "RulerUnitSetting";
     static let RulerModeSetting = "RulerModeSetting";
     static let RulerBodyPartSetting = "RulerBodyPartSetting";


     static let KitchenUnitSetting = "KitchenUnitSetting";
     static let KitchenPowerOff = "KitchenPowerOff";
     static let KitchenCMD = "KitchenCMD";
     static let KitchenTareWeight = "KitchenTareWeight";
     static let KitchenFactory = "KitchenFactory";
     static let KitchenSetNutritionFacts = "KitchenSetNutritionFacts";

     static let SkipStop = "SkipStop";
     static let SkipStart = "SkipStart";
     static let SetSkipMode = "SetSkipMode";
     static let SkipLightSetting = "SkipLightSetting";
     static let SkipSoundSetting = "SkipSoundSetting";
     static let SkipLockSt = "SkipLockSt";
     static let SkipSetWeight = "SkipSetWeight";




     static let SetServerUrl = "setServerUrl";
     static let SetOtherParams = "setOtherParams";
     static let SetScaleUIItems = "setScaleUIItems";

     static let QueryStAllNode = "queryStAllNode";
     static let ChangeStName = "changeStName";
     static let ChangeStNo = "changeStNo";
     static let CalcBodyFat = "CalcBodyFat";
     static let GetLogPath = "LogPath";
    

}
