package cn.icomon.icdevicemanager.flutter;



import java.lang.reflect.Field;
import java.util.Map;

import cn.icomon.icdevicemanager.model.data.ICSkipData;
import cn.icomon.icdevicemanager.model.other.ICConstant;

public class ICDataConvert {


    public static ISkipData getSkipData(ICSkipData from) {
        ISkipData iSkipData = new ISkipData();
        iSkipData.isStabilized = from.isStabilized;
        iSkipData.nodeId = from.nodeId;
        iSkipData.battery = from.battery;
        iSkipData.nodeInfo = from.nodeInfo;
        iSkipData.time = from.time;
        iSkipData.mode = from.mode.name();
        iSkipData.setting = from.setting;
        iSkipData.elapsed_time = from.elapsed_time;
        iSkipData.actual_time = from.actual_time;
        iSkipData.skip_count = from.skip_count;
        iSkipData.avg_freq = from.avg_freq;
        iSkipData.fastest_freq = from.fastest_freq;
        iSkipData.freq_count = from.freq_count;
        iSkipData.most_jump = from.most_jump;
        iSkipData.calories_burned = from.calories_burned;
        iSkipData.fat_burn_efficiency = from.fat_burn_efficiency;
        iSkipData.freqs = ICJson.beanToJson(from.freqs);
        return iSkipData;
    }




    public static ICConstant.ICWeightUnit getSDKScaleUnit(Object enumName) {

        if (enumName == null) return ICConstant.ICWeightUnit.ICWeightUnitKg;
        if (ICConstant.ICWeightUnit.ICWeightUnitJin.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICWeightUnit.ICWeightUnitJin;
        } else if (ICConstant.ICWeightUnit.ICWeightUnitLb.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICWeightUnit.ICWeightUnitLb;
        } else if (ICConstant.ICWeightUnit.ICWeightUnitSt.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICWeightUnit.ICWeightUnitSt;
        } else {
            return ICConstant.ICWeightUnit.ICWeightUnitKg;
        }


    }


    public static ICConstant.ICOTAMode getSDKOTAMode(Object enumName) {
        if (enumName == null) return ICConstant.ICOTAMode.ICOTAModeAuto;
        if (ICConstant.ICOTAMode.ICOTAMode1.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICOTAMode.ICOTAMode1;
        } else if (ICConstant.ICOTAMode.ICOTAMode2.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICOTAMode.ICOTAMode2;
        } else if (ICConstant.ICOTAMode.ICOTAMode3.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICOTAMode.ICOTAMode3;
        } else {
            return ICConstant.ICOTAMode.ICOTAModeAuto;
        }


    }


    public static ICConstant.ICKitchenScaleUnit getSDKKitchenUnitUnit(Object enumName) {
        if (enumName == null) return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitG;
        if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMl.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMl;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitLb.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitLb;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitOz.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitOz;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMg.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMg;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMlMilk.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitMlMilk;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitFlOzWater.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitFlOzWater;
        } else if (ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitFlOzMilk.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitFlOzMilk;
        } else {
            return ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitG;
        }


    }


    public static ICConstant.ICRulerUnit getRulerUnit(Object enumName) {

        if (enumName == null) return ICConstant.ICRulerUnit.ICRulerUnitCM;
        if (ICConstant.ICRulerUnit.ICRulerUnitFtInch.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerUnit.ICRulerUnitFtInch;
        } else if (ICConstant.ICRulerUnit.ICRulerUnitInch.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerUnit.ICRulerUnitInch;
        } else {
            return ICConstant.ICRulerUnit.ICRulerUnitCM;
        }


    }

    public static ICConstant.ICRulerMeasureMode getRulerMode(Object enumName) {
        if (enumName == null) return ICConstant.ICRulerMeasureMode.ICRulerMeasureModeLength;
        if (ICConstant.ICRulerMeasureMode.ICRulerMeasureModeGirth.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerMeasureMode.ICRulerMeasureModeGirth;
        } else {
            return ICConstant.ICRulerMeasureMode.ICRulerMeasureModeLength;
        }

    }

    public static ICConstant.ICRulerBodyPartsType getSDKRulerPart(Object enumName) {
        if (enumName == null) return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeShoulder;
        if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeBicep.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeBicep;
        } else if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeChest.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeChest;
        } else if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeWaist.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeWaist;
        } else if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeHip.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeHip;
        } else if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeThigh.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeThigh;
        } else if (ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeCalf.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeCalf;
        } else {
            return ICConstant.ICRulerBodyPartsType.ICRulerPartsTypeShoulder;
        }

    }


    public static ICConstant.ICKitchenScaleNutritionFactType getSDKNutritionFactType(Object enumName) {
        if (enumName == null)
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCalorie;
        if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCalorie.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCalorie;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalFat.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalFat;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalProtein.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalProtein;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCarbohydrates.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCarbohydrates;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalFiber.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalFiber;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCholesterd.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalCholesterd;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalSodium.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalSodium;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalSugar.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeTotalSugar;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeFat.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeFat;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeProtein.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeProtein;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCarbohydrates.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCarbohydrates;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeFiber.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeFiber;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCholesterd.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCholesterd;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeSodium.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeSodium;
        } else if (ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeSugar.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeSugar;
        } else {
            return ICConstant.ICKitchenScaleNutritionFactType.ICKitchenScaleNutritionFactTypeCalorie;
        }

    }


    public static ICConstant.ICSkipMode getSkipMode(Object enumName) {
        if (enumName == null) return ICConstant.ICSkipMode.ICSkipModeFreedom;
        if (ICConstant.ICSkipMode.ICSkipModeFreedom.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICSkipMode.ICSkipModeFreedom;
        } else if (ICConstant.ICSkipMode.ICSkipModeCount.name().equalsIgnoreCase(enumName.toString())) {
            return ICConstant.ICSkipMode.ICSkipModeCount;
        } else {
            return ICConstant.ICSkipMode.ICSkipModeTiming;
        }

    }


    public static void setMap(Map<String, Object> map, Object obj) {
        if (obj != null) {
            Field[] fields = obj.getClass().getDeclaredFields();
            for (Field field : fields) {
                if (!field.isAccessible()) {
                    field.setAccessible(true);
                }
                Object value = getDeclaredFieldValue(field, obj);
                map.put(field.getName(), value);

            }
        }

    }

    /**
     * 获取对象属性的值
     *
     * @param field
     * @return
     */
    public static Object getDeclaredFieldValue(Field field, Object obj) {
        try {
            return field.get(obj);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return null;
        }

    }
}
