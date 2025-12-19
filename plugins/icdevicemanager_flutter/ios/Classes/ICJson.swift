//
//  ICJson.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/9.
//
import Foundation

class ICJson{

    static func jsonToBean<T : Decodable>(from jsonString:String) throws -> T {
        let jsonData = Data(jsonString.utf8)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }

    
    func jsonToArray<T: Decodable>(jsonString:String) -> [T]? {
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            return try JSONDecoder().decode([T].self, from: jsonData)
          
        } catch {
            return nil
        }
    }
    
    
    static  func jsonToDeviceArray (jsonString:String) -> [ICDevice] {
        var result = [ICDevice]()
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode([Device].self, from: jsonData)
         
                temp.forEach { (element)  in
                    let icDevice=ICDevice()
                    icDevice.macAddr = element.macAddr
                    result.append(icDevice)
                }

            return result
          
        } catch {
            return result
        }
    }
    
    
    
    
    
    static  func jsonToUserInfoArray (jsonString:String) -> [ICUserInfo] {
        var result = [ICUserInfo]()
        
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode([UserInfo].self, from: jsonData)
                temp.forEach { (element)  in
                    
                    result.append(ICuserConver.getICUserInfo(data: element))
                }

            return result
          
        } catch {
            return result
        }
    }
    
    
    
    static  func jsonToLightSettingArray (jsonString:String) -> [ICSkipLightSettingData] {
        var result = [ICSkipLightSettingData]()
        
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode([SkipLightSettingData].self, from: jsonData)
                temp.forEach { (element)  in
                    result.append(ICuserConver.getICLightSettingData(data: element))
                }

            return result
          
        } catch {
            return result
        }
    }
    
    
    
    
    static  func jsonToICUser(jsonString:String) -> ICUserInfo {
        var result = ICUserInfo()
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode(UserInfo.self, from: jsonData)
            return ICuserConver.getICUserInfo(data: temp)
          
        } catch {
            return result
        }
    }
    
    
    static  func jsonToICWeight(jsonString:String) -> ICWeightData {
        var result = ICWeightData()
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode(WeightData.self, from: jsonData)
            return ICuserConver.getCalcICWeight(data: temp)
          
        } catch {
            return result
        }
    }
    
    
    
    static  func jsonToICSoundSetting(jsonString:String) -> ICSkipSoundSettingData {
        var result = ICSkipSoundSettingData()
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let temp = try JSONDecoder().decode(SkipSoundSettingData.self, from: jsonData)
            return ICuserConver.getICSoundSettingData(data: temp)
          
        } catch {
            return result
        }
    }
    

    static func beanToJson(bean:Codable) -> String?{
        let jsonEncoder = JSONEncoder();
        let jsonData = try! jsonEncoder.encode(bean);
        let json = String(data: jsonData, encoding: String.Encoding.utf8);
        return json;
    }
    
    
    

}




