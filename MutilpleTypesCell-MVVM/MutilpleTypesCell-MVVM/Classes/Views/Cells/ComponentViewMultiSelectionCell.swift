
import UIKit

class ComponentViewMultiSelectionCell: UITableViewCell {

    @IBOutlet weak var modifierName: UILabel!

    @IBOutlet weak var price: UILabel!

    var item: ModifierViewModelItem? {
        didSet {
            if let item = item as? ComponentViewMultipleSelection{
                modifierName.text = item.name
            }
            
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier:String {
        return "ComponentViewMultiSelectionCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
