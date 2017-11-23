

import Foundation
import UIKit

class CircularButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
    }

}
