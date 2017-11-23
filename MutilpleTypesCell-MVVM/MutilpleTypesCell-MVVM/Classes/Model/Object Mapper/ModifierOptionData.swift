

import Foundation
import ObjectMapper


class ModifierOptionData: Mappable {
    
    required init?(map: Map) {
        
    }

    var optionName:String?
    var optionID:Double?
    var nocost:Bool?
    var price:Double?
    var selected:Bool?
    var noCost:Bool?

    
    // Mappable
    func mapping(map: Map) {
        
        optionName     <- map["name"]
        optionID     <- map["modifieroptionid"]
        nocost     <- map["nocost"]
        price     <- map["price"]
        selected     <- map["selected"]
        noCost     <- map["nocost"]
    }
}
