//
//  ICConstant.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/9.
//


enum BleState:String,Codable{
    
    init(type:ICBleState){
        switch type{
        case .unsupported: self = .ICBleStateUnsupported
        case .unauthorized: self = .ICBleStateUnauthorized
        case .poweredOff:self = .ICBleStatePoweredOff
        case .poweredOn:self = .ICBleStatePoweredOn
        default:self = .ICBleStateUnknown;
            
        }
        
    };
    
    
    /**
     * 未知状态
     **/
    case ICBleStateUnknown = "ICBleStateUnknown",
         
         /**
          * 手机不支持BLE
          **/
         ICBleStateUnsupported = "ICBleStateUnsupported",
         
         /**
          * 应用未获取蓝牙授权
          **/
         ICBleStateUnauthorized = "ICBleStateUnauthorized",
         
         /**
          * 蓝牙关闭
          **/
         ICBleStatePoweredOff = "ICBleStatePoweredOff",
         
         /**
          * 蓝牙打开
          **/
         ICBleStatePoweredOn = "ICBleStatePoweredOn"
    
}
enum  DeviceType:String,Codable{
    
    init(type:ICDeviceType){
        switch type{
        case .weightScale: self = .ICDeviceTypeWeightScale
            
        case .fatScale:self = .ICDeviceTypeFatScale
            
        case .fatScaleWithTemperature:self = .ICDeviceTypeFatScaleWithTemperature
        case .ruler:self = .ICDeviceTypeRuler
        case .HR:self = .ICDeviceTypeHR
        case .balance:self = .ICDeviceTypeBalance
        case .kitchenScale:self = .ICDeviceTypeKitchenScale
        case .skip:self = .ICDeviceTypeSkip
            
        default:self = .ICDeviceTypeUnKnown;
            
        }
        
    };
    
    
    
    
    /// 未知
    ///*/
    case ICDeviceTypeUnKnown="ICDeviceTypeUnKnown",
         
         /// 体重秤
         ///*/
         ICDeviceTypeWeightScale="ICDeviceTypeWeightScale",
         
         /// 脂肪秤
         ///*/
         ICDeviceTypeFatScale="ICDeviceTypeFatScale",
         
         /// 脂肪秤(带温度显示)
         ///*/
         ICDeviceTypeFatScaleWithTemperature="ICDeviceTypeFatScaleWithTemperature",
         
         /// 厨房秤
         ///*/
         ICDeviceTypeKitchenScale="ICDeviceTypeKitchenScale",
         
         /// 围尺
         ///*/
         ICDeviceTypeRuler="ICDeviceTypeRuler",
         
         /// 平衡秤
         ///*/
         ICDeviceTypeBalance="ICDeviceTypeBalance",
         
         /// 跳绳
         ///*/
         ICDeviceTypeSkip="ICDeviceTypeSkip",
         
         /// HR
         ///*/
         ICDeviceTypeHR="ICDeviceTypeHR"
}



enum DeviceSubType :String,Codable{
    
    init(type:ICDeviceSubType){
        switch type{
        case .eightElectrode: self = .ICDeviceSubTypeEightElectrode
            
        case .eightElectrode2:self = .ICDeviceSubTypeEightElectrode2
            
        case .height:self = .ICDeviceSubTypeHeight
        case .scaleDual:self = .ICDeviceSubTypeScaleDual
        case .lightEffect:self = .ICDeviceSubTypeLightEffect
        case .sound:self = .ICDeviceSubTypeSound
        case .lightAndSound:self = .ICDeviceSubTypeLightAndSound
        case .color:self = .ICDeviceSubTypeColor
        case .baseSt:self = .ICDeviceSubTypeBaseSt
        case .ropeS2:self = .ICDeviceSubTypeRopeS2
            
        default:self = .ICDeviceSubTypeDefault;
            
        }
        
    };
    
    
    
    /**
     * 默认
     **/
    case  ICDeviceSubTypeDefault = "ICDeviceSubTypeDefault",
          
          /**
           * 8电极设备
           **/
          ICDeviceSubTypeEightElectrode="ICDeviceSubTypeEightElectrode",
          
          /**
           * 身高设备
           **/
          ICDeviceSubTypeHeight="ICDeviceSubTypeHeight",
          /**
           * 8电极设备2
           **/
          ICDeviceSubTypeEightElectrode2="ICDeviceSubTypeEightElectrode2",
          /**
           * 双模设备
           **/
          ICDeviceSubTypeScaleDual="ICDeviceSubTypeScaleDual",
          /**
           * 跳绳带灯效
           **/
          ICDeviceSubTypeLightEffect="ICDeviceSubTypeLightEffect",
          /**
           * 彩屏秤
           **/
          ICDeviceSubTypeColor="ICDeviceSubTypeColor",
          /**
           * 跳绳带语音
           **/
          ICDeviceSubTypeSound="ICDeviceSubTypeSound",
          
          /**
           * 跳绳带灯效和语音
           **/
          ICDeviceSubTypeLightAndSound="ICDeviceSubTypeLightAndSound",
          
          /**
           * 基站
           */
          ICDeviceSubTypeBaseSt="ICDeviceSubTypeBaseSt",
          
          /**
           * iComon S2
           */
          ICDeviceSubTypeRopeS2="ICDeviceSubTypeRopeS2"
    
}


enum DeviceCommunicationType:String ,Codable{
    
    
    init(type:ICDeviceCommunicationType){
        switch type{
        case .broadcast: self = .ICDeviceCommunicationTypeBroadcast
            
        case .connect:self = .ICDeviceCommunicationTypeConnect
            
        default:self = .ICDeviceCommunicationTypeUnknown;
            
        }
        
    };
    
    /**
     未知
     */
    case  ICDeviceCommunicationTypeUnknown="ICDeviceCommunicationTypeUnknown",
          
          /**
           连接式
           */
          ICDeviceCommunicationTypeConnect="ICDeviceCommunicationTypeConnect",
          
          /**
           广播式
           */
          ICDeviceCommunicationTypeBroadcast = "ICDeviceCommunicationTypeBroadcast"
    
}




enum DeviceConnectState:String,Codable{
    
    init(type:ICDeviceConnectState){
        switch type{
        case .connected:self = .ICDeviceConnectStateConnected
            
        default:self = .ICDeviceConnectStateDisconnected;
            
        }
        
    };
    
    /**
     * 已连接
     **/
    case ICDeviceConnectStateConnected,
         
         /**
          * 已断开
          **/
         ICDeviceConnectStateDisconnected
    
}

enum AddDeviceCallBackCode :String,Codable{
    
    init(type:ICAddDeviceCallBackCode){
        switch type{
        case .success:self = .ICAddDeviceCallBackCodeSuccess
        case .failedAndSDKNotInit:self = .ICAddDeviceCallBackCodeFailedAndSDKNotInit
        case .failedAndExist:self = .ICAddDeviceCallBackCodeFailedAndExist
        default:self = .ICAddDeviceCallBackCodeFailedAndDeviceParamErro;
            
        }
        
    };
    
    /**
     * 添加成功
     */
    case  ICAddDeviceCallBackCodeSuccess,
          
          /**
           * 添加失败,SDK未初始化
           */
          ICAddDeviceCallBackCodeFailedAndSDKNotInit,
          
          /**
           * 添加失败，设备已存在
           */
          ICAddDeviceCallBackCodeFailedAndExist,
          
          /**
           * 添加失败，设备参数有错
           */
          ICAddDeviceCallBackCodeFailedAndDeviceParamErro
    
}


enum RemoveDeviceCallBackCode:String,Codable{
    
    
    
    init(type:ICRemoveDeviceCallBackCode){
        switch type{
        case .success:self = .ICRemoveDeviceCallBackCodeSuccess
        case .failedAndSDKNotInit:self = .ICRemoveDeviceCallBackCodeFailedAndNotExist
        case .failedAndNotExist:self = .ICRemoveDeviceCallBackCodeFailedAndNotExist
        default:self = .ICRemoveDeviceCallBackCodeFailedAndDeviceParamError;
            
        }
        
    };
    /**
     * 删除成功
     */
    case  ICRemoveDeviceCallBackCodeSuccess="ICRemoveDeviceCallBackCodeSuccess",
          
          /**
           * 删除失败,SDK未初始化
           */
          ICRemoveDeviceCallBackCodeFailedAndSDKNotInit="ICRemoveDeviceCallBackCodeFailedAndSDKNotInit",
          
          /**
           * 删除失败，设备不存在
           */
          ICRemoveDeviceCallBackCodeFailedAndNotExist="ICRemoveDeviceCallBackCodeFailedAndNotExist",
          
          /**
           * 删除失败，设备参数有错
           */
          ICRemoveDeviceCallBackCodeFailedAndDeviceParamError="ICRemoveDeviceCallBackCodeFailedAndDeviceParamError"
    
}

enum MeasureStep:String,Codable{
    
    init(type:UInt){
        
        switch type{
        case 0:self = .ICMeasureStepMeasureWeightData
        case 1:self = .ICMeasureStepMeasureCenterData
        case 2:self = .ICMeasureStepAdcStart
        case 3:self = .ICMeasureStepAdcResult
        case 4:self = .ICMeasureStepHrStart
        case 5:self = .ICMeasureStepHrResult
        case 6:self = .ICMeasureStepMeasureOver
        default:self = .ICMeasureStepMeasureWeightData;
            
        }
        
    };
    
    case ICMeasureStepMeasureWeightData="ICMeasureStepMeasureWeightData",
         ICMeasureStepMeasureCenterData="ICMeasureStepMeasureCenterData",
         ICMeasureStepAdcStart="ICMeasureStepAdcStart",
         ICMeasureStepAdcResult="ICMeasureStepAdcResult",
         ICMeasureStepHrStart="ICMeasureStepHrStart",
         ICMeasureStepHrResult="ICMeasureStepHrResult",
         ICMeasureStepMeasureOver="ICMeasureStepMeasureOver"
}


enum ScaleUnit:String,Codable{
    
    init(type:ICWeightUnit){
        switch type{
        case .kg:self = .ICWeightUnitKg
        case .lb:self = .ICWeightUnitLb
        case .st:self = .ICWeightUnitSt
        case .jin:self = .ICWeightUnitJin
        default:self = .ICWeightUnitKg
        }
    };
    
    
    case ICWeightUnitKg="ICWeightUnitKg",
         ICWeightUnitLb="ICWeightUnitLb",
         ICWeightUnitSt="ICWeightUnitSt",
         ICWeightUnitJin="ICWeightUnitJin"
    
}




enum RulerUnit:String,Codable{
    
    init(type:ICRulerUnit){
        switch type{
        case .CM:self = .ICRulerUnitCM
        case .inch:self = .ICRulerUnitInch
        case .ftInch:self = .ICRulerUnitFtInch
        default:self = .ICRulerUnitCM
        }
    };
    
    
    case ICRulerUnitCM="ICRulerUnitCM",
         ICRulerUnitInch="ICRulerUnitInch",
         ICRulerUnitFtInch="ICRulerUnitFtInch"
    
    
}




enum KitchenScaleUnit:String,Codable{
    
    init(type:ICKitchenScaleUnit){
        
        switch type{
        case .oz:self = .ICKitchenScaleUnitOz
        case .mg:self = .ICKitchenScaleUnitMg
        case .G:self = .ICKitchenScaleUnitG
        case .ml:self = .ICKitchenScaleUnitMl
        case .lb:self = .ICKitchenScaleUnitLb
        case .mlMilk:self = .ICKitchenScaleUnitMlMilk
        case .flOzWater:self = .ICKitchenScaleUnitFlOzWater
        case .flOzMilk:self = .ICKitchenScaleUnitFlOzMilk
            
        default:self = .ICKitchenScaleUnitG;
            
        }
        
    };
    
    
    /**
     * 克
     */
    case ICKitchenScaleUnitG = "ICKitchenScaleUnitG",
         
         /**
          * ml
          */
         ICKitchenScaleUnitMl = "ICKitchenScaleUnitMl",
         
         /**
          * 磅
          */
         ICKitchenScaleUnitLb = "ICKitchenScaleUnitLb",
         
         /**
          * 盎司
          */
         ICKitchenScaleUnitOz = "ICKitchenScaleUnitOz",
         /**
          * 毫克
          */
         ICKitchenScaleUnitMg = "ICKitchenScaleUnitMg",
         /**
          * ml(牛奶)
          */
         ICKitchenScaleUnitMlMilk = "ICKitchenScaleUnitMlMilk",
         /**
          * 盎司(水)
          */
         ICKitchenScaleUnitFlOzWater = "ICKitchenScaleUnitFlOzWater",
         /**
          * 盎司(牛奶)
          */
         ICKitchenScaleUnitFlOzMilk = "ICKitchenScaleUnitFlOzMilk"
}



enum BFAType:String,Codable{
    
    init(type:UInt){
        switch type{
            
        case 0:self = .ICBFATypeWLA01
        case 1:self = .ICBFATypeWLA02
        case 2:self = .ICBFATypeWLA03
        case 3:self = .ICBFATypeWLA04
        case 4:self = .ICBFATypeWLA05
        case 5:self = .ICBFATypeWLA06
        case 6:self = .ICBFATypeWLA07
        case 7:self = .ICBFATypeWLA08
        case 8:self = .ICBFATypeWLA09
        case 9:self = .ICBFATypeWLA10
        case 10:self = .ICBFATypeWLA11
        case 11:self = .ICBFATypeWLA12
        case 12:self = .ICBFATypeWLA13
        case 13:self = .ICBFATypeWLA14
        case 14:self = .ICBFATypeWLA15
        case 15:self = .ICBFATypeWLA16
        case 16:self = .ICBFATypeWLA17
        case 17:self = .ICBFATypeWLA18
        case 18:self = .ICBFATypeWLA19
        case 19:self = .ICBFATypeWLA20
        case 20:self = .ICBFATypeWLA21
        case 21:self = .ICBFATypeWLA22
        case 22:self = .ICBFATypeWLA23
        case 23:self = .ICBFATypeWLA24
        case 24:self = .ICBFATypeWLA25
        case 25:self = .ICBFATypeWLA26
        case 26:self = .ICBFATypeWLA27
        case 27:self = .ICBFATypeWLA28
        case 28:self = .ICBFATypeWLA29
        case 100:self = .ICBFATypeUnknown
        case 101:self = .ICBFATypeRev
            
        default:
            self = .ICBFATypeWLA01
        }
    };
    
    
    
    case ICBFATypeWLA01 = "ICBFATypeWLA01",
         
         ICBFATypeWLA02 = "ICBFATypeWLA02",
         
         ICBFATypeWLA03 = "ICBFATypeWLA03",
         
         ICBFATypeWLA04 = "ICBFATypeWLA04",
         
         ICBFATypeWLA05 = "ICBFATypeWLA05",
         
         ICBFATypeWLA06 = "ICBFATypeWLA06",
         
         ICBFATypeWLA07 = "ICBFATypeWLA07",
         
         ICBFATypeWLA08 = "ICBFATypeWLA08",
         
         ICBFATypeWLA09 = "ICBFATypeWLA09",
         
         ICBFATypeWLA10 = "ICBFATypeWLA10",
         
         ICBFATypeWLA11 = "ICBFATypeWLA11",
         
         ICBFATypeWLA12 = "ICBFATypeWLA12",
         
         ICBFATypeWLA13 = "ICBFATypeWLA13",
         
         ICBFATypeWLA14 = "ICBFATypeWLA14",
         
         ICBFATypeWLA15 = "ICBFATypeWLA15",
         
         ICBFATypeWLA16 = "ICBFATypeWLA16",
         
         ICBFATypeWLA17 = "ICBFATypeWLA17",
         
         ICBFATypeWLA18 = "ICBFATypeWLA18",
         
         ICBFATypeWLA19 = "ICBFATypeWLA19",
         
         ICBFATypeWLA20 = "ICBFATypeWLA20",
         
         ICBFATypeWLA21 = "ICBFATypeWLA21",
         
         ICBFATypeWLA22 = "ICBFATypeWLA22",
         
         ICBFATypeWLA23 = "ICBFATypeWLA23",
         
         ICBFATypeWLA24 = "ICBFATypeWLA24",
         
         ICBFATypeWLA25 = "ICBFATypeWLA25",
         
         ICBFATypeWLA26 = "ICBFATypeWLA26",
         
         ICBFATypeWLA27 = "ICBFATypeWLA27",
         
         ICBFATypeWLA28 = "ICBFATypeWLA28",
         
         ICBFATypeWLA29 = "ICBFATypeWLA29",
         
         ICBFATypeUnknown = "ICBFATypeUnknown",
         
         ICBFATypeRev = "ICBFATypeRev"
    
}

enum RulerMeasureMode:String,Codable{
    init(type:ICRulerMeasureMode){
        
        switch type{
        case .girth:self = .ICRulerMeasureModeGirth
        default:self = .ICRulerMeasureModeLength
        }
        
    };
    
    case ICRulerMeasureModeLength = "ICRulerMeasureModeLength",
         ICRulerMeasureModeGirth = "ICRulerMeasureModeGirth"
    
}


enum RulerBodyPartsType:String,Codable{
    init(type:ICRulerBodyPartsType){
        switch type{
        case .partsTypeShoulder:self = .ICRulerPartsTypeShoulder
        case .partsTypeBicep:self = .ICRulerPartsTypeBicep
        case .partsTypeChest:self = .ICRulerPartsTypeChest
        case .partsTypeWaist:self = .ICRulerPartsTypeWaist
        case .partsTypeHip:self = .ICRulerPartsTypeHip
        case .partsTypeThigh:self = .ICRulerPartsTypeThigh
        case .partsTypeCalf:self = .ICRulerPartsTypeCalf
        default:self = .ICRulerPartsTypeShoulder
        }
        
    };
    
    case ICRulerPartsTypeShoulder = "ICRulerPartsTypeShoulder",
         ICRulerPartsTypeBicep = "ICRulerPartsTypeBicep",
         ICRulerPartsTypeChest = "ICRulerPartsTypeChest",
         ICRulerPartsTypeWaist = "ICRulerPartsTypeWaist",
         ICRulerPartsTypeHip = "ICRulerPartsTypeHip",
         ICRulerPartsTypeThigh = "ICRulerPartsTypeThigh",
         ICRulerPartsTypeCalf = "ICRulerPartsTypeCalf"
    
}

enum SkipMode:String,Codable{
    
    init(type:UInt){
        switch type{
        case 0:self = .ICSkipModeFreedom
        case 1:self = .ICSkipModeTiming
        case 2:self = .ICSkipModeCount
        case 3:self = .ICSkipModeInterruptTime
        case 4:self = .ICSkipModeInterruptCount
        default:self = .ICSkipModeFreedom
        }
        
    };
    
    case ICSkipModeFreedom="ICSkipModeFreedom",
         ICSkipModeTiming="ICSkipModeTiming",
         ICSkipModeCount="ICSkipModeCount",
         ICSkipModeInterruptTime="ICSkipModeInterruptTime",
         ICSkipModeInterruptCount="ICSkipModeInterruptCount"
}

enum UpgradeStatus:String,Codable{
    
    
    
    init(type:ICUpgradeStatus){
        switch type{
        case .success:self = .ICUpgradeStatusSuccess
        case .upgrading:self = .ICUpgradeStatusUpgrading
        case .fail:self = .ICUpgradeStatusFail
        case .failFileInvalid:self = .ICUpgradeStatusFailFileInvalid
        case .failNotSupport:self = .ICUpgradeStatusFailNotSupport
        default:self = .ICUpgradeStatusFail
        }
        
    };
    /**
     * 升级成功
     */
    case ICUpgradeStatusSuccess = "ICUpgradeStatusSuccess",
         /**
          * 升级中
          */
         ICUpgradeStatusUpgrading = "ICUpgradeStatusUpgrading",
         /**
          * 升级失败
          */
         ICUpgradeStatusFail = "ICUpgradeStatusFail",
         /**
          * 升级失败，文件无效
          */
         ICUpgradeStatusFailFileInvalid = "ICUpgradeStatusFailFileInvalid",
         /**
          * 升级失败，设备不支持升级
          */
         ICUpgradeStatusFailNotSupport = "ICUpgradeStatusFailNotSupport"
}



enum ConfigWifiState:String,Codable{
    init(type:ICConfigWifiState){
        switch type{
        case .success:self = .ICConfigWifiStateSuccess
        case .wifiConnecting:self = .ICConfigWifiStateWifiConnecting
        case .fail:self = .ICConfigWifiStateWifiConnectFail
        case .wifiConnectFail:self = .ICConfigWifiStateWifiConnectFail
        case .serverConnectFail:self = .ICConfigWifiStateServerConnectFail
        case .passwordFail:self = .ICConfigWifiStatePasswordFail
        default:self = .ICConfigWifiStateFail
        }
        
    };
    
    
    case ICConfigWifiStateSuccess = "ICConfigWifiStateSuccess",
         ICConfigWifiStateWifiConnecting = "ICConfigWifiStateWifiConnecting",
         ICConfigWifiStateServerConnecting = "ICConfigWifiStateServerConnecting",
         ICConfigWifiStateWifiConnectFail = "ICConfigWifiStateWifiConnectFail",
         ICConfigWifiStateServerConnectFail = "ICConfigWifiStateServerConnectFail",
         ICConfigWifiStatePasswordFail = "ICConfigWifiStatePasswordFail",
         ICConfigWifiStateFail = "ICConfigWifiStateFail"
    
}



enum SexType:String,Codable {
    init(type:ICSexType){
        switch type{
        case .unknown:self = .ICSexTypeUnknown
        case .male:self = .ICSexTypeMale
        case .femal:self = .ICSexTypeFemal
        default:self = .ICSexTypeMale
            
            
        }
    };
    
    
    
    case ICSexTypeUnknown = "ICSexTypeUnknown",
         ICSexTypeMale = "ICSexTypeMale",
         ICSexTypeFemal = "ICSexTypeFemal"
    
}

enum PeopleType:String,Codable {
    init(type:UInt){
        switch type{
        case 1:self = .ICPeopleTypeSportman
        default:self = .ICPeopleTypeNormal
            
            
        }
    };
    
    
    
    case ICPeopleTypeNormal = "ICPeopleTypeNormal",
         ICPeopleTypeSportman = "ICPeopleTypeSportman"
    
    
}



enum OTAMode:String,Codable{

    init(type:ICOTAMode){
        switch type{
        case .modeAuto:self = .ICOTAModeAuto
        case .mode3:self = .ICOTAMode3
        case .mode2:self = .ICOTAMode2
        case .mode1:self = .ICOTAMode1
        @unknown default:self = .ICOTAModeAuto
          
        }
    };

   
   case  ICOTAModeAuto = "ICOTAModeAuto",
    
     ICOTAMode1 = "ICOTAMode1",
    
     ICOTAMode2 = "ICOTAMode2",
     
     ICOTAMode3 = "ICOTAMode3"
}


enum SettingCallBackCode:String,Codable{
    
    init(type:ICSettingCallBackCode){
        switch type{
        case .success:self = .ICSettingCallBackCodeSuccess
        case .sdkNotInit:self = .ICSettingCallBackCodeSDKNotInit
        case .sdkNotStart:self = .ICSettingCallBackCodeSDKNotStart
        case .deviceNotFound:self = .ICSettingCallBackCodeDeviceNotFound
        case .functionIsNotSupport:self = .ICSettingCallBackCodeFunctionIsNotSupport
        case .deviceDisConnected:self = .ICSettingCallBackCodeDeviceDisConnected
        case .invalidParameter:self = .ICSettingCallBackCodeInvalidParameter
        case .failed:self = .ICSettingCallBackCodeFailed
        @unknown default:self = .ICSettingCallBackCodeInvalidParameter
          
        }
    };
    
   
     case ICSettingCallBackCodeSuccess = "ICSettingCallBackCodeSuccess",
      
     
      ICSettingCallBackCodeSDKNotInit = "ICSettingCallBackCodeSDKNotInit",
      
      
      ICSettingCallBackCodeSDKNotStart = "ICSettingCallBackCodeSDKNotStart",
      
     
      ICSettingCallBackCodeDeviceNotFound = "ICSettingCallBackCodeDeviceNotFound",
      
      ICSettingCallBackCodeFunctionIsNotSupport = "ICSettingCallBackCodeFunctionIsNotSupport",
      
     
      ICSettingCallBackCodeDeviceDisConnected = "ICSettingCallBackCodeDeviceDisConnected",
      
     
      ICSettingCallBackCodeInvalidParameter = "ICSettingCallBackCodeInvalidParameter",

      
      ICSettingCallBackCodeFailed = "ICSettingCallBackCodeFailed"
    
}

enum SkipSoundType:String,Codable{
    
    init(type:ICSkipSoundType){
        switch type{
        case .none:self = .ICSkipSoundTypeNone
        case .female:self = .ICSkipSoundTypeFemale
        case .male:self = .ICSkipSoundTypeMale
        default:self = .ICSkipSoundTypeFemale
          
        }
    };
    
    
     case ICSkipSoundTypeNone = "ICSkipSoundTypeNone",
     
      
      ICSkipSoundTypeFemale = "ICSkipSoundTypeFemale",
      
      ICSkipSoundTypeMale = "ICSkipSoundTypeMale"
}



enum SkipSoundMode:String,Codable {
    
    init(type:ICSkipSoundMode){
        switch type{
        case .none:self = .ICSkipSoundModeNone
        case .time:self = .ICSkipSoundModeTime
        case .count:self = .ICSkipSoundModeCount
        default:self = .ICSkipSoundModeCount
          
        }
    };
    
   case ICSkipSoundModeNone = "ICSkipSoundModeNone",
     
   ICSkipSoundModeTime = "ICSkipSoundModeTime",
  
   ICSkipSoundModeCount = "ICSkipSoundModeCount"
}

enum SkipLightMode:String,Codable{
    init(type:ICSkipLightMode){
        switch type{
        case .none:self = .ICSkipLightModeNone
        case .RPM:self = .ICSkipLightModeRPM
        case .timer:self = .ICSkipLightModeTimer
        case .count:self = .ICSkipLightModeCount
        case .percent:self = .ICSkipLightModePercent
        case .tripRope:self = .ICSkipLightModeTripRope
        case .measuring:self = .ICSkipLightModeMeasuring
        default:self = .ICSkipLightModeNone
          
        }
    };
    
    /*
       * 无
       */
      case  ICSkipLightModeNone = "ICSkipLightModeNone",
      /*
       * 速度模式
       */
      ICSkipLightModeRPM = "ICSkipLightModeRPM",
      /*
       * 计时模式
       */
      ICSkipLightModeTimer = "ICSkipLightModeTimer",
      /*
       * 计次模式
       */
      ICSkipLightModeCount = "ICSkipLightModeCount",
      /*
       * 百分比模式
       */
      ICSkipLightModePercent = "ICSkipLightModePercent",
      /*
       * 绊绳次数模式
       */
      ICSkipLightModeTripRope = "ICSkipLightModeTripRope",
      /*
       * 测量模式模式
       */
      ICSkipLightModeMeasuring = "ICSkipLightModeMeasuring"
}

enum KitchenScaleNutritionFactType:String,Codable{
    
    
    init(type:ICKitchenScaleNutritionFactType){
        switch type{
        case .calorie:self = .ICKitchenScaleNutritionFactTypeCalorie
        case .totalCalorie:self = .ICKitchenScaleNutritionFactTypeTotalCalorie
        case .fat :self = .ICKitchenScaleNutritionFactTypeFat
        case .totalFat:self = .ICKitchenScaleNutritionFactTypeTotalFat
        case .protein:self = .ICKitchenScaleNutritionFactTypeProtein
        case .totalProtein:self = .ICKitchenScaleNutritionFactTypeTotalProtein
        case .carbohydrates:self = .ICKitchenScaleNutritionFactTypeCarbohydrates
        case .totalCarbohydrates:self = .ICKitchenScaleNutritionFactTypeTotalCarbohydrates
        case .fiber:self = .ICKitchenScaleNutritionFactTypeFiber
        case .totalFiber:self = .ICKitchenScaleNutritionFactTypeTotalFiber
        case .cholesterd:self = .ICKitchenScaleNutritionFactTypeCholesterd
        case .totalCholesterd:self = .ICKitchenScaleNutritionFactTypeTotalCholesterd
        case .sodium:self = .ICKitchenScaleNutritionFactTypeSodium
        case .totalSodium:self = .ICKitchenScaleNutritionFactTypeTotalSodium
        case .sugar:self = .ICKitchenScaleNutritionFactTypeSugar
        case .totalSugar:self = .ICKitchenScaleNutritionFactTypeTotalSugar
   
        default:self = .ICKitchenScaleNutritionFactTypeCalorie
          
        }
    };
    
    
    /*
        *  卡路里, 最大不超过4294967295
        */
      case ICKitchenScaleNutritionFactTypeCalorie = "ICKitchenScaleNutritionFactTypeCalorie",
       
       /*
        *  总卡路里, 最大不超过4294967295
        */
       ICKitchenScaleNutritionFactTypeTotalCalorie = "ICKitchenScaleNutritionFactTypeTotalCalorie",
       
       /*
        *  总脂肪
        */
       ICKitchenScaleNutritionFactTypeTotalFat = "ICKitchenScaleNutritionFactTypeTotalFat",
       
       /*
        *  总蛋白质
        */
       ICKitchenScaleNutritionFactTypeTotalProtein = "ICKitchenScaleNutritionFactTypeTotalProtein",
       
       /*
        *  总碳水化合物
        */
       ICKitchenScaleNutritionFactTypeTotalCarbohydrates = "ICKitchenScaleNutritionFactTypeTotalCarbohydrates",
       
       /*
        *  总脂肪纤维
        */
       ICKitchenScaleNutritionFactTypeTotalFiber = "ICKitchenScaleNutritionFactTypeTotalFiber",
       
       /*
        *  总胆固醇
        */
       ICKitchenScaleNutritionFactTypeTotalCholesterd = "ICKitchenScaleNutritionFactTypeTotalCholesterd",
    
       /*
        *  总钠含量
        */
       ICKitchenScaleNutritionFactTypeTotalSodium = "ICKitchenScaleNutritionFactTypeTotalSodium",
       
       /*
        *  总糖含量
        */
       ICKitchenScaleNutritionFactTypeTotalSugar = "ICKitchenScaleNutritionFactTypeTotalSugar",
       
       /*
        * 脂肪
        */
       ICKitchenScaleNutritionFactTypeFat = "ICKitchenScaleNutritionFactTypeFat",
       
       /*
        * 蛋白质
        */
       ICKitchenScaleNutritionFactTypeProtein = "ICKitchenScaleNutritionFactTypeProtein",
       
       /*
        * 碳水化合物
        */
       ICKitchenScaleNutritionFactTypeCarbohydrates = "ICKitchenScaleNutritionFactTypeCarbohydrates",
       
       /*
        * 膳食纤维
        */
       ICKitchenScaleNutritionFactTypeFiber = "ICKitchenScaleNutritionFactTypeFiber",
       
       /*
        * 胆固醇
        */
       ICKitchenScaleNutritionFactTypeCholesterd = "ICKitchenScaleNutritionFactTypeCholesterd",
       
       /*
        * 钠含量
        */
       ICKitchenScaleNutritionFactTypeSodium = "ICKitchenScaleNutritionFactTypeSodium",
       
       /*
        * 糖含量
        */
       ICKitchenScaleNutritionFactTypeSugar = "ICKitchenScaleNutritionFactTypeSugar"
}
