

import Foundation
import ObjectMapper


class ModifierGroupDataMapper: Mappable {


    var modifierName:String?
    var modifierID:Double?
    var selectionType:String?
    var viewType:String?
    var viewTypeName:String?
    var showTitle:Bool?
    var modifierOptions:[ModifierOptionData]?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        
        modifierName     <- map["modifiername"]
        modifierID     <- map["modifier_id"]
        selectionType     <- map["selectiontype"]
        viewType     <- map["viewtype"]
        viewTypeName     <- map["viewtype_name"]
        showTitle     <- map["titleshow"]
        modifierOptions     <- map["modifieroption"]
    }
}
