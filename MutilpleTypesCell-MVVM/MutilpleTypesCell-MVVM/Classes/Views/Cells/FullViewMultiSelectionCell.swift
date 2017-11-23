
import UIKit

protocol CellSelectionDelegate: NSObjectProtocol{
    func didSelectCellItem(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String)
}

class FullViewMultiSelectionCell: UITableViewCell, CheckboxDelegate {

    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var selectedOption: Checkbox!
    @IBOutlet weak var modifierName: UILabel!
    weak var cellDelegate: CellSelectionDelegate?
    
    var item: ModifierViewModelItem? {
        didSet {
            if let item = item as? FullViewMultipleSelection{
                modifierName.text = item.name
            }
            
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier:String {
        return "FullViewMultiSelectionCell"
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.selectedOption.mDelegate = self
    }
    
    func didSelectCheckbox(_ state: Bool, modifierItem: ModifierItem,option: ModifierOption, type:String) {
        
        self.cellDelegate?.didSelectCellItem(state, modifierItem: modifierItem, option: option, type:type)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        //print("\n\(selected)")
        
    }

}
