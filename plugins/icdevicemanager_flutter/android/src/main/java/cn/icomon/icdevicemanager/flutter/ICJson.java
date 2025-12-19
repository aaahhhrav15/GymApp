package cn.icomon.icdevicemanager.flutter;

import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ICJson {

    public static <T> T toJavaObject(String strJson, Class clazz) {
        if (TextUtils.isEmpty(strJson)) {
            return null;
        }
        T object = null;
        try {
            object = (T) JSON.parseObject(strJson, clazz);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return object;
    }

    public static <T> List<T> toJavaList(String strJson, Class clazz) {
        if (TextUtils.isEmpty(strJson)) {
            return new ArrayList<>();
        }
        List<T> list = new ArrayList<>();
        try {
            list = JSON.parseArray(strJson, clazz);
        } catch (Exception e) {
            Log.e("toJavaList", "toJavaList "+e.toString());
        }
        return list;
    }


    public static <T> String beanToJson(T info) {
        return JSON.toJSONString(info);
    }


    public static <T> T typeToObject(String strJson, Type type) {
        if (TextUtils.isEmpty(strJson)) {
            return null;
        }
        T object = null;
        try {
            object = JSON.parseObject(strJson, type);
        } catch (Exception e) {

        }
        return object;
    }

    public static <T> HashMap<String, T> toJavaMap(String strJson) {
        if (TextUtils.isEmpty(strJson)) {
            return new HashMap<>();
        }

        HashMap<String, T> hashMap = null;
        try {
            hashMap = JSON.parseObject(strJson, new TypeReference<HashMap<String, T>>() {
            });
        } catch (Exception e) {

        }

        if (hashMap == null)
            hashMap = new HashMap<>();
        return hashMap;
    }

    public static <T> HashMap<Integer, T> toJavaMapInteger(String strJson) {
        if (TextUtils.isEmpty(strJson)) {
            return new HashMap<>();
        }

        HashMap<Integer, T> hashMap = null;
        try {
            hashMap = JSON.parseObject(strJson, new TypeReference<HashMap<Integer, T>>() {
            });
        } catch (Exception e) {

        }

        if (hashMap == null)
            hashMap = new HashMap<>();
        return hashMap;
    }

}
