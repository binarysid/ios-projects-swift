
import UIKit

protocol CellSingleSelectionDelegate: NSObjectProtocol{
    func didSelectSingleCellItem(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String)
}

class FullViewSingleSelectionCell: UITableViewCell, DownStateButtonControllerDelegate {

    @IBOutlet weak var selectedOption: DownStateButton!
    @IBOutlet weak var modifierName: UILabel!
    weak var cellDelegate: CellSingleSelectionDelegate?
    
    @IBOutlet weak var price: UILabel!
    
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
        return "FullViewSingleSelectionCell"
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.selectedOption.delegate = self
    }
    
    func selectedButton(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String) {
        
        self.cellDelegate?.didSelectSingleCellItem(state, modifierItem: modifierItem, option: option, type:type)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print("\n\(selected)")
        
    }

}
