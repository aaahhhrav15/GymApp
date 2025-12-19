//
//  ICuserConver.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class ICuserConver{
    
    static func getICBfaType(type:BFAType) -> ICBFAType {
        switch type{
        case .ICBFATypeWLA01: return ICBFAType.init(rawValue: 0)
        case .ICBFATypeWLA02: return ICBFAType.init(rawValue: 1)
        case .ICBFATypeWLA03: return ICBFAType.init(rawValue: 2)
        case .ICBFATypeWLA04: return ICBFAType.init(rawValue: 3)
        case .ICBFATypeWLA05: return ICBFAType.init(rawValue: 4)
        case .ICBFATypeWLA06: return ICBFAType.init(rawValue: 5)
        case .ICBFATypeWLA07: return ICBFAType.init(rawValue: 6)
        case .ICBFATypeWLA08: return ICBFAType.init(rawValue: 7)
        case .ICBFATypeWLA09: return ICBFAType.init(rawValue: 8)
        case .ICBFATypeWLA10: return ICBFAType.init(rawValue: 9)
        case .ICBFATypeWLA11: return ICBFAType.init(rawValue: 10)
        case .ICBFATypeWLA12: return ICBFAType.init(rawValue: 11)
        case .ICBFATypeWLA13: return ICBFAType.init(rawValue: 12)
        case .ICBFATypeWLA14: return ICBFAType.init(rawValue: 13)
        case .ICBFATypeWLA15: return ICBFAType.init(rawValue: 14)
        case .ICBFATypeWLA16: return ICBFAType.init(rawValue: 15)
        case .ICBFATypeWLA17: return ICBFAType.init(rawValue: 16)
        case .ICBFATypeWLA18: return ICBFAType.init(rawValue: 17)
        case .ICBFATypeWLA19: return ICBFAType.init(rawValue: 18)
        case .ICBFATypeWLA20: return ICBFAType.init(rawValue: 19)
        case .ICBFATypeWLA21: return ICBFAType.init(rawValue: 20)
        case .ICBFATypeWLA22: return ICBFAType.init(rawValue: 21)
        case .ICBFATypeWLA23: return ICBFAType.init(rawValue: 22)
        case .ICBFATypeWLA24: return ICBFAType.init(rawValue: 23)
        case .ICBFATypeWLA25: return ICBFAType.init(rawValue: 24)
        case .ICBFATypeWLA26: return ICBFAType.init(rawValue: 25)
        case .ICBFATypeWLA27: return ICBFAType.init(rawValue: 26)
        case .ICBFATypeWLA28: return ICBFAType.init(rawValue: 27)
        case .ICBFATypeWLA29: return ICBFAType.init(rawValue: 28)
        case .ICBFATypeUnknown: return ICBFAType.init(rawValue: 100)
        case .ICBFATypeRev: return ICBFAType.init(rawValue: 101)
            
            
        }
        
    }
    
    
    
    static func getICPPType(type:PeopleType) -> ICPeopleType {
        switch type{
        case.ICPeopleTypeNormal: return ICPeopleType.init(rawValue:0)
        case.ICPeopleTypeSportman :return ICPeopleType.init(rawValue: 1)
            
        }
    }
    
    static func getICSexType(type:SexType) -> ICSexType {
        switch type{
        case.ICSexTypeFemal: return ICSexType.femal
        case.ICSexTypeMale :return ICSexType.male
        case.ICSexTypeUnknown :return ICSexType.unknown
            
        }
    }
    
    static func getICWeightUnit(type:ScaleUnit) -> ICWeightUnit {
        switch type{
        case.ICWeightUnitKg: return ICWeightUnit.kg
        case.ICWeightUnitLb :return ICWeightUnit.lb
        case.ICWeightUnitSt :return ICWeightUnit.st
        case.ICWeightUnitJin :return ICWeightUnit.jin
            
        }
    }
    
    
    static func getICRulerUnit(type:RulerUnit) -> ICRulerUnit {
        switch type{
        case.ICRulerUnitCM: return ICRulerUnit.CM
        case.ICRulerUnitInch :return ICRulerUnit.inch
        case.ICRulerUnitFtInch :return ICRulerUnit.ftInch
            
        }
    }
    
    static func getICKitchenUnit(type:KitchenScaleUnit) -> ICKitchenScaleUnit {
        switch type{
        case.ICKitchenScaleUnitG: return ICKitchenScaleUnit.G
        case.ICKitchenScaleUnitMg :return ICKitchenScaleUnit.mg
        case.ICKitchenScaleUnitMl :return ICKitchenScaleUnit.ml
        case.ICKitchenScaleUnitMlMilk :return ICKitchenScaleUnit.mlMilk
        case.ICKitchenScaleUnitOz :return ICKitchenScaleUnit.oz
        case.ICKitchenScaleUnitFlOzMilk :return ICKitchenScaleUnit.flOzMilk
        case.ICKitchenScaleUnitFlOzWater :return ICKitchenScaleUnit.flOzWater
        case.ICKitchenScaleUnitLb :return ICKitchenScaleUnit.lb
            
            
        }
    }
    
    
    static func getRulerMode(type:RulerMeasureMode) -> ICRulerMeasureMode {
        switch type{
        case.ICRulerMeasureModeLength: return ICRulerMeasureMode.length
        case.ICRulerMeasureModeGirth :return ICRulerMeasureMode.girth
            
            
        }
    }
    
    
    
    static func getRulerPart(type:RulerBodyPartsType) -> ICRulerBodyPartsType {
        switch type{
        case.ICRulerPartsTypeBicep: return ICRulerBodyPartsType.partsTypeBicep
        case.ICRulerPartsTypeChest :return ICRulerBodyPartsType.partsTypeChest
        case.ICRulerPartsTypeShoulder :return ICRulerBodyPartsType.partsTypeShoulder
        case.ICRulerPartsTypeHip :return ICRulerBodyPartsType.partsTypeHip
        case.ICRulerPartsTypeWaist :return ICRulerBodyPartsType.partsTypeWaist
        case.ICRulerPartsTypeThigh :return ICRulerBodyPartsType.partsTypeThigh
        case.ICRulerPartsTypeCalf :return ICRulerBodyPartsType.partsTypeCalf
            
            
            
        }
    }
    
    
    
    
    static func getICUserInfo(data:UserInfo) -> ICUserInfo{
        
        let user = ICUserInfo()
        user.userId=data.userId
        user.userIndex=data.userIndex
        user.nickName=data.nickName
        user.height=data.height
        user.weight=data.weight
        user.targetWeight=data.targetWeight
        user.age=data.age
        user.weightDirection=data.weightDirection
        user.bfaType = ICuserConver.getICBfaType(type: data.bfaType)
        user.peopleType = ICuserConver.getICPPType(type: data.peopleType)
        user.sex = ICuserConver.getICSexType(type: data.sex)
        
        user.weightUnit = ICuserConver.getICWeightUnit(type: data.weightUnit)
        user.rulerUnit = ICuserConver.getICRulerUnit(type: data.rulerUnit)
        user.rulerMode = ICuserConver.getRulerMode(type: data.rulerMode)
        user.kitchenUnit = ICuserConver.getICKitchenUnit(type: data.kitchenUnit)
        user.enableMeasureImpendence = data.enableMeasureImpendence
        user.enableMeasureHr = data.enableMeasureHr
        user.enableMeasureBalance = data.enableMeasureBalance
        user.enableMeasureGravity = data.enableMeasureGravity
        
        return user
    }
    
    
    
    static func getCalcICWeight(data:WeightData) -> ICWeightData{
        let weight = ICWeightData()
        weight.weight_kg=data.weight_kg
        weight.bfa_type = getICBfaType(type: data.bfa_type)
        weight.imp = data.imp
        weight.impendences = []
        data.impendences?.forEach({  (element) in
            weight.impendences.append(NSNumber(value: element))
        })
        
        return weight
        
    }
    
    
    static func getICSoundSettingData(data:SkipSoundSettingData) -> ICSkipSoundSettingData{
        let setting = ICSkipSoundSettingData()
        setting.soundOn=data.soundOn
        setting.soundVolume=data.soundVolume
        setting.fullScoreOn=data.fullScoreOn
        setting.fullScoreBPM=data.fullScoreBPM
        setting.modeParam=data.modeParam
        setting.isAutoStop=data.isAutoStop
        setting.soundType =  getSkipSoundType(type:  data.soundType)
        setting.soundMode = getSkipSoundMode(mode:  data.soundMode)
        
        return setting
    }
    
    
    static func getICLightSettingData(data:SkipLightSettingData) -> ICSkipLightSettingData{
        let setting = ICSkipLightSettingData()
        setting.r = data.r
        setting.b = data.b
        setting.g = data.g
        setting.modeValue = data.rpm
        
        
        return setting
    }
    
    
    static func  getSDKOTAMode(mode:OTAMode) -> ICOTAMode{
        switch mode{
        case.ICOTAMode1:return ICOTAMode.mode1
        case.ICOTAMode2:return ICOTAMode.mode2
        case.ICOTAMode3:return ICOTAMode.mode3
        case.ICOTAModeAuto:return ICOTAMode.modeAuto
        }
        
    }
    
    
    static func  getSkipMode(mode:SkipMode) -> ICSkipMode{
        switch mode{
        case.ICSkipModeFreedom:return ICSkipMode.init(rawValue: 0)
        case.ICSkipModeTiming:return ICSkipMode.init(rawValue: 1)
        case.ICSkipModeCount:return ICSkipMode.init(rawValue: 2)
        case.ICSkipModeInterruptTime:return ICSkipMode.init(rawValue: 3)
        case.ICSkipModeInterruptCount:return ICSkipMode.init(rawValue: 4)
        default:return ICSkipMode.init(rawValue: 0)
        }
        
    }
    
    
    
    static func  getSkipSoundType(type:SkipSoundType) -> ICSkipSoundType{
        switch type{
        case.ICSkipSoundTypeNone:return ICSkipSoundType.none
        case.ICSkipSoundTypeMale:return ICSkipSoundType.male
        case.ICSkipSoundTypeFemale:return ICSkipSoundType.female
        default:return ICSkipSoundType.female
            
            
        }
        
    }
    
    
    static func  getSkipSoundMode(mode:SkipSoundMode) -> ICSkipSoundMode{
        switch mode{
        case.ICSkipSoundModeNone:return ICSkipSoundMode.none
        case.ICSkipSoundModeTime:return ICSkipSoundMode.time
        case.ICSkipSoundModeCount:return ICSkipSoundMode.count
        default:return ICSkipSoundMode.count
            
        }
        
    }
    static func  getSkipLightMode(mode:SkipLightMode) -> ICSkipLightMode{
        switch mode{
        case.ICSkipLightModeNone:return ICSkipLightMode.none
        case.ICSkipLightModeTimer:return ICSkipLightMode.timer
        case.ICSkipLightModeCount:return ICSkipLightMode.count
        case.ICSkipLightModePercent:return ICSkipLightMode.percent
        case.ICSkipLightModeTripRope:return ICSkipLightMode.tripRope
        case.ICSkipLightModeRPM:return ICSkipLightMode.RPM
        case.ICSkipLightModeMeasuring:return ICSkipLightMode.measuring
        default:return ICSkipLightMode.none
            
        }
        
    }
    static func getICNutritionFactType(type:KitchenScaleNutritionFactType) -> ICKitchenScaleNutritionFactType{
        switch type{
        case .ICKitchenScaleNutritionFactTypeCalorie:
            return ICKitchenScaleNutritionFactType.calorie
        case .ICKitchenScaleNutritionFactTypeTotalCalorie:
            return ICKitchenScaleNutritionFactType.totalCalorie
        case .ICKitchenScaleNutritionFactTypeFat:
            return   ICKitchenScaleNutritionFactType.fat
          
        case .ICKitchenScaleNutritionFactTypeTotalFat:
            return ICKitchenScaleNutritionFactType.totalFat
        case .ICKitchenScaleNutritionFactTypeProtein:
            return ICKitchenScaleNutritionFactType.protein
        case .ICKitchenScaleNutritionFactTypeTotalProtein:
            return ICKitchenScaleNutritionFactType.totalProtein
        case .ICKitchenScaleNutritionFactTypeCarbohydrates:
            return ICKitchenScaleNutritionFactType.carbohydrates
        case .ICKitchenScaleNutritionFactTypeTotalCarbohydrates:
            return ICKitchenScaleNutritionFactType.totalCarbohydrates
        case .ICKitchenScaleNutritionFactTypeFiber:
            return  ICKitchenScaleNutritionFactType.fiber
           
        case .ICKitchenScaleNutritionFactTypeTotalFiber:
            return ICKitchenScaleNutritionFactType.totalFiber
        case .ICKitchenScaleNutritionFactTypeCholesterd:
            return ICKitchenScaleNutritionFactType.cholesterd
        case .ICKitchenScaleNutritionFactTypeTotalCholesterd:
            return ICKitchenScaleNutritionFactType.totalCholesterd
        case .ICKitchenScaleNutritionFactTypeSodium:
            return  ICKitchenScaleNutritionFactType.sodium
        case .ICKitchenScaleNutritionFactTypeTotalSodium:
            return ICKitchenScaleNutritionFactType.totalSodium
        case .ICKitchenScaleNutritionFactTypeSugar:
            return ICKitchenScaleNutritionFactType.sugar
        case .ICKitchenScaleNutritionFactTypeTotalSugar:
            return ICKitchenScaleNutritionFactType.totalSugar
        }
    }
    
    
}
