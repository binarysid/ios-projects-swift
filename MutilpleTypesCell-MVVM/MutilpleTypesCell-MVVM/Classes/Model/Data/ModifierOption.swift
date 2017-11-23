

import UIKit

// modifier options under each modifier item
class ModifierOption:NSObject {
    
    var productID: String?
    var modifierID: Double?
    var modifierOptionID: Double?
    var optionName: String?
    var cost: Double?
    var selected:Bool?
    var noCost:Bool?

    init(productID:String, modifierID:Double, modifierOptionID:Double, optionName: String, cost: Double,selected:Bool,noCost:Bool){
        self.productID = productID
        self.modifierID = modifierID
        self.modifierOptionID = modifierOptionID
        self.optionName = optionName
        self.cost = cost
        self.selected = selected
        self.noCost = noCost
    }
}
