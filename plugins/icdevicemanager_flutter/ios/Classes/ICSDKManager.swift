//
//  ICSDKManager.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/8.
//

import Flutter

class ICSDKManager :NSObject,
                    ICDeviceManagerDelegate,
                    ICScanDeviceDelegate
{
    
    
    
    
    private override init() {
        
    }
    
    static let sharedInstance: ICSDKManager = ICSDKManager()
    
    static var  channel:FlutterMethodChannel? = nil;
    
    
    func setDelegate(){
        ICDeviceManager.shared().delegate=self;
    }
    
    
    func  getICDeviceByMac(strMac:String ) -> ICDevice {
        let icDevice =  ICDevice();
        icDevice.macAddr = strMac;
        return icDevice;
    }
    
    
    
    
    func initSdk(config:ICDeviceManagerConfig){
        ICDeviceManager.shared().initMgr(with: config );
        
    }
    
    
    
    
    func addDevice( macAddr:String?, uiCallBack: ICAddDeviceCallBack? ) {
        if (macAddr == nil){
            return;
        }
        let myDevice = ICDevice();
        myDevice.macAddr=macAddr!
        
        ICDeviceManager.shared().add(myDevice,callback: uiCallBack );
        
        
    }
    
    
    
    
    func addDevices( devices:[ICDevice]?, uiCallBack:@escaping ICAddDeviceCallBack ) {
        if (devices == nil){
            return;
        }
        ICDeviceManager.shared().add(devices,callback: uiCallBack );
        
    }
    
    
    func removeDevice( macAddr:String?, uiCallBack:@escaping ICRemoveDeviceCallBack ) {
        if (macAddr == nil){
            return;
        }
        let myDevice = ICDevice();
        myDevice.macAddr=macAddr!;
        
        ICDeviceManager.shared().remove(myDevice,callback: uiCallBack );
        
    }
    
    
    
    func removeDevices(devices:[ICDevice]?, uiCallBack:@escaping ICRemoveDeviceCallBack ) {
        ICDeviceManager.shared().remove(devices,callback: uiCallBack );
        
    }
    
    
    
    func upgradeDevice( macAddr: String?, path: String?, icotaMode: ICOTAMode) {
        if (macAddr == nil){
            return;
        }
        if (path==nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().upgradeDevice(dev, filePath:path,mode: icotaMode);
        
    }
    
    
    
    
    func upgradeDevices( devices:[ICDevice]?, path: String?, icotaMode: ICOTAMode) {
        if (devices == nil){
            return;
        }
        if (path==nil){
            return;
        }
        ICDeviceManager.shared().upgradeDevices(devices, filePath:path,mode: icotaMode);
        
    }
    
    
    
    func stopUpgradeDevice( macAddr: String?) {
        if (macAddr == nil){
            return;
        }
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        ICDeviceManager.shared().stopUpgradeDevice(dev);
        
    }
    
    
    
    func  scanDevice() {
        ICDeviceManager.shared().scanDevice(self);
    }
    
    
    
    func  stopScan() {
        ICDeviceManager.shared().stopScan();
    }
    
    
    
    func configWifi( macAddr:String?,  ssid:String,  password:String,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().configWifi(dev, ssid: ssid, password: password, callback: callback);
        
        
        
    }
    
    
    func setScaleUnit( macAddr:String?, unit:ICWeightUnit,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        print(unit.self)
        
        ICDeviceManager.shared().getSettingManager().setScaleUnit(dev, unit: unit, callback:callback);
        
        
    }
    
    
    func setRulerUnit( macAddr:String?, unit:ICRulerUnit,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setRulerUnit(dev, unit: unit, callback:callback);
        
        
    }
    
    
    func setRulerBodyPartsType( macAddr:String?, part:ICRulerBodyPartsType,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setRulerBodyPartsType(dev, type: part, callback:callback);
        
        
    }
    
    
    
    
    
    func setRulerMeasureMode( macAddr:String?, mode:ICRulerMeasureMode,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setRulerMeasureMode(dev, mode: mode, callback:callback);
        
        
    }
    
    
    func setKitchenScaleUnit( macAddr:String?, unit:ICKitchenScaleUnit,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setKitchenScaleUnit(dev, unit: unit, callback:callback);
        
        
    }
    
    func deleteTareWeight( macAddr:String?, callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().deleteTareWeight(dev, callback:callback);
        
        
    }
    
    
    func powerOffKitchenScale( macAddr:String?, callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().powerOffKitchenScale(dev, callback:callback);
        
        
    }
    
    func setNutritionFacts( macAddr:String?,
                            type:ICKitchenScaleNutritionFactType,
                            value:Int,
                            callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setNutritionFacts(dev, type:type,value:value,callback:callback);
        
        
    }
    
    
    func setServerUrl( macAddr:String?,
                       server:String,
                       callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setServerUrl(dev,server:server,callback:callback);
        
        
    }
    
    func setOtherParams( macAddr:String?,params:Any){
        
    }
    
    
    func queryStAllNode( macAddr:String?,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().queryStAllNode(dev,callback:callback);
    }
    
    
    func changeStName( macAddr:String?,name:String?,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        if (name == nil){
            return;
        }
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().changeStName(dev,name:name,callback:callback);
    }
    
    
    
    func changeStNo( macAddr:String?, dstId:UInt,  st_no:UInt,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().changeStNo(dev,dstId:dstId,   st_no:st_no,callback:callback);
    }
    
    
    func syncUserInfo(userInfo: ICUserInfo?) {
        if (userInfo == nil){
            return;
        }
        ICDeviceManager.shared().update(userInfo!);
    }
    
    func syncUserList(userList:[ICUserInfo]?) {
        if (userList == nil){
            return;
        }
        ICDeviceManager.shared().setUserList(userList!);
    }
    
    
    
    
    func setWeight( macAddr:String?, weight:Int, callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setWeight(dev, weight:weight,callback:callback);
    }
    
    
    
    func startSkip( macAddr:String?,mode:ICSkipMode, param:UInt, callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().startSkip(dev, mode:mode,param:param,callback:callback);
    }
    
    
    
    func stopSkip( macAddr:String?,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().stopSkip(dev,callback:callback);
    }
    
    func setSkipLightSetting( macAddr:String?,lightEffects:[ICSkipLightSettingData]?,mode:ICSkipLightMode,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        if (lightEffects == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setSkipLightSetting(dev,lightEffects:lightEffects,mode:mode,callback:callback);
    }
    
    
    
    func setSkipSoundSetting( macAddr:String?,config:ICSkipSoundSettingData?,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        if (config == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().setSkipSoundSetting(dev,config:config,callback:callback);
    }
    
    
    
    
    func lockStSkip( macAddr:String?,callback:@escaping ICSettingCallback){
        if (macAddr == nil){
            return;
        }
        
        let dev = ICDevice();
        dev.macAddr=macAddr!;
        
        ICDeviceManager.shared().getSettingManager().lockStSkip(dev,callback:callback);
    }
    
    
    func reCalcBodyFatWithWeightData( weightData:ICWeightData,userInfo :ICUserInfo )->WeightData {
        let icWeight:ICWeightData = ICDeviceManager.shared().getBodyFatAlgorithmsManager().reCalcBodyFat(with: weightData, userInfo: userInfo)
        return WeightData.init(data: icWeight)
    }
    
    func getLogPath(  )->String {
    
        return ICDeviceManager.shared().getLogPath()
    }
    
    
    
    
    
    func sendMsgToFlutter( name:String,  obj:Any) {
        
        DispatchQueue.main.async {
            if (ICSDKManager.channel != nil) {
                ICSDKManager.channel!.invokeMethod(name, arguments: obj)
            }
        }
        
        
    }
    
    
    
    
    func onScanResult(_ deviceInfo: ICScanDeviceInfo!) {
        print("mac地址："+deviceInfo.macAddr)
        let info = ScanDeviceInfo.init(deviceInfo:deviceInfo);
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(info);
        let json = String(data: jsonData, encoding: String.Encoding.utf8);
        
        
        
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.DeviceScan, obj: map);
    }
    
    
    func onInitFinish(_ bSuccess: Bool) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.BoolValue]=bSuccess;
        sendMsgToFlutter(name :ICWUploadEvent.InitSDK, obj: map);
        
        
    }
    
    
    func onBleState(_ state: ICBleState) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.EnumName] = BleState.init(type: state).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.BluetoothChange, obj: map);
        
    }
    
    func onDeviceConnectionChanged(_ device: ICDevice!, state: ICDeviceConnectState) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.EnumName] = DeviceConnectState.init(type: state).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.ConnectChange, obj: map);
    }
    
    func onReceiveElectrodeData(_ device: ICDevice!, data: ICElectrodeData!) {
        
    }
    
    func onReceiveRulerMeasureModeChanged(_ device: ICDevice!, mode: ICRulerMeasureMode) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.EnumName] = RulerMeasureMode.init(type: mode).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.RulerModeChange, obj: map);
    }
    func onReceiveDeviceInfo(_ device: ICDevice!, deviceInfo: ICDeviceInfo!) {
        var  map:[String:Any] = [String:Any]();
        let bean = DeviceInfo.init(data: deviceInfo)
        let json = ICJson.beanToJson(bean: bean)
        
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.DeviceInfo, obj: map);
        
    }
    
    func onNodeConnectionChanged(_ device: ICDevice!, nodeId: UInt, state: ICDeviceConnectState) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.IntValue]=nodeId
        map[ICMapKey.EnumName] = DeviceConnectState.init(type: state).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.NodConnectChange, obj: map);
    }
    
    
    func onReceiveMeasureStepData(_ device: ICDevice!, step: ICMeasureStep, data: NSObject!) {
        
        var json :String? = ""
        if(data.isKind(of:ICWeightCenterData.self)){
            let temp = data as! ICWeightCenterData
            let weight:WeightCenterData = WeightCenterData.init(data: temp)
            json = ICJson.beanToJson(bean: weight)
        }else {
            let temp = data as! ICWeightData
            let weight:WeightData = WeightData.init(data: temp)
            json = ICJson.beanToJson(bean: weight)
        }
        
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        map[ICMapKey.EnumName] = MeasureStep.init(type: step.rawValue).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.ScaleStepData, obj: map);
        
    }
    func onReceiveWeightData(_ device: ICDevice!, data: ICWeightData!) {
        let weight=WeightData.init(data: data)
        let json = ICJson.beanToJson(bean: weight)
        
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.ScaleData, obj: map);
    }
    
    
    func onReceiveKitchenScaleData(_ device: ICDevice!, data: ICKitchenScaleData!) {
        let bean = KitchenData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.KitchenData, obj: map);
        
    }
    
    
    func onReceiveKitchenScaleUnitChanged(_ device: ICDevice!, unit: ICKitchenScaleUnit) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.EnumName] = KitchenScaleUnit.init(type: unit).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.KitchenScaleUnitChanged, obj: map);
    }
    
    func onReceiveCoordData(_ device: ICDevice!, data: ICCoordData!) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        
        let bean = CoordData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        
        map[ICMapKey.JsonValue] = json
        sendMsgToFlutter(name :ICWUploadEvent.ScaleCoordData, obj: map);
    }
    
    func onReceiveRulerData(_ device: ICDevice!, data: ICRulerData!) {
        let bean = RulerData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.RulerData, obj: map);
    }
    
    func onReceiveRulerHistoryData(_ device: ICDevice!, data: ICRulerData!) {
        let bean = RulerData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.RulerHistoryData, obj: map);
    }
    
    func onReceiveWeightCenterData(_ device: ICDevice!, data: ICWeightCenterData!) {
        let bean = WeightCenterData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.ScaleCenterData, obj: map);
    }
    
    func onReceiveWeightHistoryData(_ device: ICDevice!, data: ICWeightHistoryData!) {
        let bean = WeightHistoryData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.ScaleHistoryData, obj: map);
    }
    
    
    
    func onReceiveWeightUnitChanged(_ device: ICDevice!, unit: ICWeightUnit) {
        var  map:[String:Any] = [String:Any]();
        map[ICMapKey.Mac]=device.macAddr
        print("onReceiveWeightUnitChanged  ")
        print(unit.rawValue)
        map[ICMapKey.EnumName] = ScaleUnit.init(type: unit).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.ScaleUnitChange, obj: map);
    }
    
    
    func onReceiveRulerUnitChanged(_ device: ICDevice!, unit: ICRulerUnit) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.EnumName] = RulerUnit(type: unit).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.RulerUnitChange, obj: map);
    }
    
    
    
    func onReceiveSkipData(_ device: ICDevice!, data: ICSkipData!) {
        let bean = SkipData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.SkipData, obj: map);
    }
    
    func onReceiveHistorySkipData(_ device: ICDevice!, data: ICSkipData!) {
        let bean = SkipData.init(data: data)
        let json = ICJson.beanToJson(bean: bean)
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.JsonValue]=json;
        sendMsgToFlutter(name :ICWUploadEvent.SkipHistoryData, obj: map);
    }
    
    
    func onReceiveBattery(_ device: ICDevice!, battery: UInt, ext: NSObject!) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.IntValue] = battery
        sendMsgToFlutter(name :ICWUploadEvent.Battery, obj: map);
    }
    
    func onReceiveUpgradePercent(_ device: ICDevice!, status: ICUpgradeStatus, percent: UInt) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.IntValue] = percent
        map[ICMapKey.EnumName] = UpgradeStatus.init(type: status).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.Upgrade, obj: map);
    }
    
    
    
    func onReceiveConfigWifiResult(_ device: ICDevice!, state: ICConfigWifiState) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.EnumName] = ConfigWifiState.init(type: state).rawValue
        sendMsgToFlutter(name :ICWUploadEvent.ConfigWifi, obj: map);
        
    }
    
    func onReceiveHR(_ device: ICDevice!, hr: Int32) {
        var  map:[String:Any] = [String:Any]()
        map[ICMapKey.Mac]=device.macAddr
        map[ICMapKey.IntValue]=hr
        sendMsgToFlutter(name :ICWUploadEvent.HrData, obj: map);
        
    }
    
    
    
}
