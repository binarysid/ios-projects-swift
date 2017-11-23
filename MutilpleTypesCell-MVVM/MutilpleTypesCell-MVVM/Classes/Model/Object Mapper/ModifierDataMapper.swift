
import Foundation
import ObjectMapper


class ModifierDataMapper: Mappable {

    var modifierGroupTitle: String?
    var titleVisible:Bool?
    var ModifierGroupInfoDataMapper: [ModifierGroupDataMapper]?
    var defaultPrice:Double?
    var defaultQuantity:Int?
    
    required init?(map: Map) {
        
    }

    // Mappable
    func mapping(map: Map) {
        
        ModifierGroupInfoDataMapper     <- map["modifiers"]
        modifierGroupTitle     <- map["modifygrouptitle"]
        titleVisible     <- map["modifygrouptitle_visible"]
        defaultPrice     <- map["default_price"]
        defaultQuantity     <- map["default_quantity"]
    }
}
