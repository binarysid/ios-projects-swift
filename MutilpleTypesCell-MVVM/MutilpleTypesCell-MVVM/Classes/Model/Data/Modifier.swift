

import UIKit

class Modifier{
    
    var modifierItem: ModifierItem?
    var option: Array<ModifierOption>?
    
    init(modifierItem: ModifierItem,option: Array<ModifierOption>)
    {
        self.modifierItem = modifierItem
        self.option = option
    }
}
