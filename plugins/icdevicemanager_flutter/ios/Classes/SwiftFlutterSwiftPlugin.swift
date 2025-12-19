import Flutter
import UIKit

public class SwiftFlutterSwiftPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ic_bluetooth_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSwiftPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        ICSDKManager.channel=channel;
        ICSDKManager.sharedInstance.setDelegate()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var  arguments =  call.arguments;
        var  params:[String:Any] = [String:Any]()
        var  resultMap:[String:String] = [String:String]()
        if arguments is Dictionary<String, Any> {
            var  map:[String:Any] = arguments as! [String : Any]
            map.forEach { (key: String, value: Any) in
                params[key]=value;
                
            }
            
        }
        
        var jsonObj = params[ICMapKey.JsonValue];
        var macObj = params[ICMapKey.Mac];
        var enumObj = params[ICMapKey.EnumName];
        var intObj = params[ICMapKey.IntValue];
        var stringObj = params[ICMapKey.StringValue];
        
        
        
        
        var mac = "";
        var cmdValue = "";
        var device = ICDevice();
        var devList = [ICDevice]()
        var filePath = "";
        var weight = 0;
        
        
        if (jsonObj != nil){
            cmdValue = (jsonObj as? String)!;
        }
        if (macObj != nil) {
            mac = (macObj as? String)!;
            
        }
        if (intObj != nil){
            weight = intObj as! Int;
        }
        
        switch call.method{
        case ICWPublishEvent.InitSDK:
            ICSDKManager.sharedInstance.initSdk(config: ICDeviceManagerConfig())
            break
        case ICWPublishEvent.StartScan:
            ICSDKManager.sharedInstance.scanDevice()
            break
            
        case ICWPublishEvent.StopScan:
            ICSDKManager.sharedInstance.stopScan()
            break
        case ICWPublishEvent.AddDevice:
            ICSDKManager.sharedInstance.addDevice(macAddr: mac) { device, code in
                resultMap[ICMapKey.EnumName] = AddDeviceCallBackCode.init(type:code).rawValue
                result(resultMap)
                
            }
            
            break
            
        case ICWPublishEvent.AddDevices:
            
            devList = ICJson.jsonToDeviceArray(jsonString: cmdValue)
            
            ICSDKManager.sharedInstance.addDevices(devices: devList) { device, code in
                resultMap[ICMapKey.EnumName] = AddDeviceCallBackCode.init(type:code).rawValue
                result(resultMap)
                
            }
            break
            
        case ICWPublishEvent.DeleteDevice:
            
            ICSDKManager.sharedInstance.removeDevice(macAddr: mac) { device, code in
                resultMap[ICMapKey.EnumName] = RemoveDeviceCallBackCode.init(type:code).rawValue
                result(resultMap)
                
            }
            
            
            break
            
            
        case ICWPublishEvent.DeleteDevices:
            devList = ICJson.jsonToDeviceArray(jsonString: cmdValue)
            
            ICSDKManager.sharedInstance.removeDevices(devices: devList) { device, code in
                resultMap[ICMapKey.EnumName] = RemoveDeviceCallBackCode.init(type:code).rawValue
                result(resultMap)
                
            }
            break
        case ICWPublishEvent.OTADevice:
            
            
            if (stringObj != nil) {
                filePath = stringObj as! String
                
            }
            
            
            
            let mode =  OTAMode.init(rawValue: enumObj as! String)
            
            var sdkOTAMode:ICOTAMode
            if(mode == nil){
                sdkOTAMode = ICOTAMode.modeAuto
            }else{
                sdkOTAMode = ICuserConver.getSDKOTAMode(mode:mode!)
            }
            
            ICSDKManager.sharedInstance.upgradeDevice(macAddr: mac, path: filePath, icotaMode: sdkOTAMode)
            
            
            break
            
        case ICWPublishEvent.OTADevices:
            
         
            devList = ICJson.jsonToDeviceArray(jsonString: cmdValue)
            let mode =  OTAMode.init(rawValue: enumObj as! String)
            var sdkOTAMode:ICOTAMode
            if(mode == nil){
                sdkOTAMode = ICOTAMode.modeAuto
            }else{
                sdkOTAMode = ICuserConver.getSDKOTAMode(mode:mode!)
            }
            
            ICSDKManager.sharedInstance.upgradeDevices(devices: devList, path: filePath, icotaMode: sdkOTAMode)
            
            break
            
        case ICWPublishEvent.StopOTADevice:
            ICSDKManager.sharedInstance.stopUpgradeDevice(macAddr: mac)
            break
            
            
        case ICWPublishEvent.StopOTADevices:
            devList = ICJson.jsonToDeviceArray(jsonString: cmdValue)
            break
        case ICWPublishEvent.ScaleConfigWifi:
            
            let  ssidObj = params[ICMapKey.SSID] as! String
            let passwordObj = params[ICMapKey.Password] as! String
            
            ICSDKManager.sharedInstance.configWifi(macAddr:mac, ssid: ssidObj, password: passwordObj) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            
            break
            
            
            
        case ICWPublishEvent.ScaleUnitSetting:
            let unitString = enumObj as! String
            let unit = ScaleUnit.init(rawValue: unitString)
            var weightUnit:ICWeightUnit
            if(unit == nil){
                weightUnit = ICWeightUnit.kg
                
            }else {
                weightUnit = ICuserConver.getICWeightUnit(type: unit!)
            }
            
            
            ICSDKManager.sharedInstance.setScaleUnit(macAddr:mac, unit: weightUnit ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            
            break
            
        case ICWPublishEvent.RulerUnitSetting:
            
            let unit = RulerUnit.init(rawValue: enumObj as! String)
            var rulerUnit:ICRulerUnit
            if(unit == nil){
                rulerUnit = ICRulerUnit.CM
                
            }else {
                rulerUnit = ICuserConver.getICRulerUnit(type: unit!)
            }
            
            ICSDKManager.sharedInstance.setRulerUnit(macAddr:mac, unit: rulerUnit ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            
            break
            
        case ICWPublishEvent.RulerModeSetting:
            
        
            
            let mode = RulerMeasureMode.init(rawValue: enumObj as! String)
            
            var rulerMode:ICRulerMeasureMode
            
            if(mode == nil){
                rulerMode = ICRulerMeasureMode.length
                
            }else {
                rulerMode = ICuserConver.getRulerMode(type: mode!)
            }
            
            ICSDKManager.sharedInstance.setRulerMeasureMode(macAddr:mac, mode: rulerMode ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            break
        case ICWPublishEvent.RulerBodyPartSetting:
            
            let part = RulerBodyPartsType.init(rawValue: enumObj as! String)
            
            var rulerPart:ICRulerBodyPartsType
            
            if(part == nil){
                rulerPart = ICRulerBodyPartsType.partsTypeBicep
                
            }else {
                rulerPart = ICuserConver.getRulerPart(type: part!)
            }
            
            ICSDKManager.sharedInstance.setRulerBodyPartsType(macAddr:mac, part: rulerPart ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            break
            
        case ICWPublishEvent.KitchenUnitSetting:
            
            let unit = KitchenScaleUnit.init(rawValue: enumObj as! String)
            var kitchenUnit:ICKitchenScaleUnit
            if(unit == nil){
                kitchenUnit = ICKitchenScaleUnit.G
                
            }else {
                kitchenUnit = ICuserConver.getICKitchenUnit(type: unit!)
            }
            
            ICSDKManager.sharedInstance.setKitchenScaleUnit(macAddr:mac, unit: kitchenUnit ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            break
        case ICWPublishEvent.KitchenPowerOff:
            
            ICSDKManager.sharedInstance.powerOffKitchenScale(macAddr:mac) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
        case ICWPublishEvent.KitchenCMD:
            break
            
        case ICWPublishEvent.KitchenTareWeight:
            ICSDKManager.sharedInstance.deleteTareWeight(macAddr:mac) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
        case ICWPublishEvent.KitchenFactory:
            break
            
        case ICWPublishEvent.SetSkipMode:
            
            
            
            
            
            let skipMode = SkipMode.init(rawValue: enumObj as! String)
            
            var icSkipMope:ICSkipMode
            
            if(skipMode == nil){
                icSkipMope = ICSkipMode.init(rawValue: 0)
                
            }else {
                icSkipMope = ICuserConver.getSkipMode(mode:skipMode!)
            }
            
            var params:UInt = 0
            if(intObj != nil){
                params = intObj as! UInt
                
            }

            ICSDKManager.sharedInstance.startSkip(macAddr:mac, mode:icSkipMope,param: params ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            
            break
            
        case ICWPublishEvent.SkipStart:
            
        
            let skipMode = SkipMode.init(rawValue: enumObj as! String)
            
            var icSkipMope:ICSkipMode
            
            if(skipMode == nil){
                icSkipMope = ICSkipMode.init(rawValue: 0)
                
            }else {
                icSkipMope = ICuserConver.getSkipMode(mode:skipMode!)
            }
            
            var params:UInt = 0
            if(intObj != nil){
                params = intObj as! UInt
                
            }

            ICSDKManager.sharedInstance.startSkip(macAddr:mac, mode:icSkipMope,param: params ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
            
        case ICWPublishEvent.SkipStop:
            
            ICSDKManager.sharedInstance.stopSkip(macAddr:mac ) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
            
        case ICWPublishEvent.SkipLightSetting:
            let lightSetting = ICJson.jsonToLightSettingArray(jsonString: cmdValue)
            let lightMode = SkipLightMode.init(type: enumObj as! ICSkipLightMode)
            let iclightMode = ICuserConver.getSkipLightMode(mode: lightMode)
            
            ICSDKManager.sharedInstance.setSkipLightSetting(macAddr:mac ,lightEffects: lightSetting,mode:iclightMode) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
        case ICWPublishEvent.SkipSoundSetting:
            
            let soundSetting = ICJson.jsonToICSoundSetting(jsonString: cmdValue)
            
            ICSDKManager.sharedInstance.setSkipSoundSetting(macAddr:mac ,config:soundSetting) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
        case ICWPublishEvent.SkipSetWeight:
            ICSDKManager.sharedInstance.setWeight(macAddr:mac ,weight:weight) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
        case ICWPublishEvent.KitchenSetNutritionFacts:
           
            let type = KitchenScaleNutritionFactType.init(rawValue: enumObj as! String)
            let icKitchenSetNutritionFacts = ICuserConver.getICNutritionFactType(type: type!)
            
            ICSDKManager.sharedInstance.setNutritionFacts(macAddr:mac ,type: icKitchenSetNutritionFacts,value:weight) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
        case ICWPublishEvent.SetServerUrl:
            
            let url = stringObj as! String
            ICSDKManager.sharedInstance.setServerUrl(macAddr:mac ,server:url) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
        case ICWPublishEvent.SetOtherParams:
                       break;
        case ICWPublishEvent.SetScaleUIItems:
                      break;
        case ICWPublishEvent.SkipLockSt:
            ICSDKManager.sharedInstance.lockStSkip(macAddr:mac) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            
            break
            
        case ICWPublishEvent.QueryStAllNode:
            
            ICSDKManager.sharedInstance.queryStAllNode(macAddr:mac) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            
        case ICWPublishEvent.ChangeStName:
            let stName = stringObj as! String
            
            
            ICSDKManager.sharedInstance.changeStName(macAddr:mac, name: stName) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
        case ICWPublishEvent.ChangeStNo:
            let stId = params[ICMapKey.DstId] as! UInt
            let stNo = params[ICMapKey.StNo] as! UInt
            
            ICSDKManager.sharedInstance.changeStNo(macAddr:mac,dstId:stId,st_no:stNo) { code in
                resultMap[ICMapKey.EnumName] = SettingCallBackCode.init(type:code).rawValue
                result(resultMap)
            }
            break
            

        case ICWPublishEvent.SetUserInfo:
            
            let user = ICJson.jsonToICUser(jsonString: cmdValue)
            ICSDKManager.sharedInstance.syncUserInfo(userInfo: user)
            break
       
            
        case ICWPublishEvent.SetUserList:
            let userList = ICJson.jsonToUserInfoArray(jsonString: cmdValue)
            ICSDKManager.sharedInstance.syncUserList(userList: userList)
            break
            
        case ICWPublishEvent.CalcBodyFat:
            
            let weightData = ICJson.jsonToICWeight(jsonString:cmdValue);
            var userObj = params[ICMapKey.JsonValue2];
            if (userObj != nil) {
                var userJon = userObj as! String
                let user = ICJson.jsonToICUser(jsonString: userJon)
                let resultWeight = ICSDKManager.sharedInstance.reCalcBodyFatWithWeightData(weightData: weightData, userInfo:user )
                resultMap[ICMapKey.JsonValue] = ICJson.beanToJson(bean: resultWeight)
                result(resultMap)
                
            }
            
         
            break
        case  ICWPublishEvent.GetLogPath:
           let logPath = ICSDKManager.sharedInstance.getLogPath()
            resultMap[ICMapKey.StringValue] = logPath
            result(resultMap)
            
            break
        default:
            break
            
        }
        
       
    }
    
    
    
    
    
}
