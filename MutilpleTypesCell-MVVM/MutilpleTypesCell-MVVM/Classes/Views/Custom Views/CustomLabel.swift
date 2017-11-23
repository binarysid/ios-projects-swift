
import UIKit

class CustomLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let newRect = rect.offsetBy(dx: 10, dy: 0) // move text 10 points to the right
        super.drawText(in: newRect)
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
