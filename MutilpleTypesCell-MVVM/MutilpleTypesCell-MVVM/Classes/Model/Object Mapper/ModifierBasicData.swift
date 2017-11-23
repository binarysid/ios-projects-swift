

import Foundation
import ObjectMapper

class ModifierBasicData: Mappable {

    var ModifierInfoDataMapper: ModifierDataMapper?
    
    var ProductID:String?
    var ProcuctCategory:String?
    var ProductName:String?
    var UnitName:String?
    var Path:String?
    var MPath: String?
    var Details:String?
    var Price:Double?
    var ModifyerTitle:String?
    var ResturantID: Int?

    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        
        ModifierInfoDataMapper     <- map["modifierdata"]
        ProductName     <- map["ProductName"]
        ProductID     <- map["ProductID"]
        Price     <- map["Price"]
        Details     <- map["Details"]
        Path     <- map["SPath"]
        MPath     <- map["MPath"]
        ResturantID     <- map["ResturantID"]
        ModifyerTitle     <- map["ModifyerTitle"]
        UnitName     <- map["UnitName"]
        ProcuctCategory     <- map["ProcuctCategory"]
        
        
        if Details == nil{
            Details = ""
        }


    }
    
   
}


