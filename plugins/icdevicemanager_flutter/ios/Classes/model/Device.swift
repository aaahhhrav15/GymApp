//
//  Device.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class Device:Codable{
    init(data:String){
        macAddr=data
    }
    var macAddr:String?
    
    
    
    func jsonToArray<T: Decodable>(jsonString:String) -> [T]? {
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            return try JSONDecoder().decode([T].self, from: jsonData)
          
        } catch {
            return nil
        }
    }
}
