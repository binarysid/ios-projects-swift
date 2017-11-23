

import Foundation
import ObjectMapper

class ModifierListDataMapper: Mappable {

    var ModifierBasicDataMapper: ModifierBasicData?

    required init?(map: Map) {
        
    }

    // Mappable
    func mapping(map: Map) {
        
        ModifierBasicDataMapper     <- map["data"]
        
    }
}
