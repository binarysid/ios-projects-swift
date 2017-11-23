
import Foundation
import Alamofire
import AlamofireObjectMapper

enum ModifierViewType: String{
    case FullViewSingleSelectionType = "s1v2"
    case FullViewMultiSelectionType = "s2v2"
    case ComponentViewSingleSelectionType = "s1v1"
    case ComponentViewMultiSelectionType = "s2v1"
}

// interface for different types of cell
protocol ModifierViewModelItem{
    var showTitle : Bool{ get }
    var type : ModifierViewType{ get }
    var sectionTitle:String { get }
    var rowCount:Int { get }
    var modifierOption: Array<ModifierOption> { get }
    var modifierItem: ModifierItem { get }
}

// to present the modifier items this must be impelemented
protocol ModifierPresenterDelegate: class{
    
    func showLoader()
    func hideLoader()
    func refreshData(_ price:Double, quantity:Int,modifiers: Array<Modifier>, showPageTitle:Bool)
    func refreshDataFromLocalDB(_ price:Double,itemTotal:Double, quantity:Int,modifiers: Array<Modifier>)
    func singleItemSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String)
    func itemSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String)
    
}

// implement whenever component view is intertacted
protocol ModifierOptionsDelegate:NSObjectProtocol{
    
    func optionsItemSelected(_ state: Bool,modifierItem: ModifierItem,option: Array<ModifierOption>, type:String)
    
}

class ModifierViewModel : NSObject{
    
    var items = [ModifierViewModelItem]()
    var modifiers: Array<Modifier> = []
    fileprivate var productID:String?
    weak fileprivate var mDelegate: ModifierPresenterDelegate?
    weak fileprivate var optionsDelegate: ModifierOptionsDelegate?
    var radioOptions:Array<DownStateButton> = []
    
    
    init(productID:String) {
        super.init()
        self.productID = productID
        
    }
    
    // assigning the delegate objects
    func attachDelegate(_ delegate:ModifierPresenterDelegate, optionsDelegate:ModifierOptionsDelegate){
        self.mDelegate = delegate
        self.optionsDelegate = optionsDelegate
    }
    
    func updateModifier(_ modifiers: Array<Modifier>) {
        self.modifiers = modifiers
        self.updateObjectFactory()
    }
    
    func loadModifierListFromLocalDB(){
        
    }
    
    func loadModifierList(){
        
        // find the local json file
        guard let jsonPath = Bundle.main.path(forResource: "APIData", ofType: "json") else {
            return
        }
        
        let localFileUrl = URL.init(fileURLWithPath: jsonPath)
        // load data from json file
        let request = Alamofire.request(localFileUrl).responseObject { (response: DataResponse<ModifierListDataMapper>) in
            
            if let error = response.error{
                print(error)
            }
            else{
                
                if let modifierListValue = response.result.value {
                    if let modifierList = modifierListValue.ModifierBasicDataMapper{
                        if let modifierData = modifierList.ModifierInfoDataMapper{
                            
                            if let groupData = modifierData.ModifierGroupInfoDataMapper{
                                //print("object")
                                if groupData.count>0{
                                    
                                    
                                    for (_,data) in groupData.enumerated(){ //
                                        var modifierOption: Array<ModifierOption> = []
                                        if let options = data.modifierOptions{
                                            if options.count>0{
                                                for option in options{ // options
                                                    
                                                    modifierOption.append(ModifierOption(productID: modifierList.ProductID!, modifierID: data.modifierID!, modifierOptionID: option.optionID!, optionName: option.optionName!, cost: option.price!,selected:option.selected!,noCost:option.noCost!))
                                                    
                                                    //print(option.optionName!)
                                                }
                                            }
                                        }
                                        let modifierItem = ModifierItem(productID: modifierList.ProductID!, modifierID: data.modifierID!, modifierName: data.modifierName!, price: modifierList.Price!, itemTotalPrice: 0.0, quantity: 1, notes: "",
                                                                        selectionType:data.selectionType!,
                                                                        viewType:data.viewType!,showTitle:data.showTitle!)
                                        self.modifiers.append(Modifier(modifierItem:modifierItem, option: modifierOption))
                                        
                                        if let modifierCellObj = ModifierFactory.getModifierFactory(data.modifierName!,option: modifierOption, modifierItem:modifierItem, viewType: data.viewType!, selectionType: data.selectionType!, titleShow:data.showTitle!){
                                            
                                            self.items.append(modifierCellObj)
                                        }
                                        
                                    }
                                    
                                    self.mDelegate?.refreshData(modifierData.defaultPrice!, quantity:modifierData.defaultQuantity! ,modifiers: self.modifiers, showPageTitle:modifierData.titleVisible!)
                                    
                                }
                            }
                            //print(modifierData.modifierGroupTitle!)
                        }
                    }
                }
            }
        }
        
//        self.mDelegate?.showLoader!()

        print("\nmyRequest: \(request)")
    }
    
    fileprivate func updateObjectFactory(){ // modifier object updated when an item is selected by user. update includes only selected state
        
        if self.modifiers.count>0{
            
            self.items = []
            for (index,data) in self.modifiers.enumerated(){
                var modifierOption: Array<ModifierOption> = []
                for option in self.modifiers[index].option!{
                
                    modifierOption.append(ModifierOption(productID: self.productID!, modifierID: data.modifierItem!.modifierID!, modifierOptionID: option.modifierOptionID!, optionName: option.optionName!, cost: option.cost!,selected:option.selected!,noCost:option.noCost!))
                }
                let modifierItem = ModifierItem(productID:  self.productID!, modifierID: data.modifierItem!.modifierID!, modifierName: data.modifierItem!.modifierName!, price: data.modifierItem!.price!, itemTotalPrice: 0.0, quantity: 1, notes: "",
                selectionType:data.modifierItem!.selectionType!,
                viewType:data.modifierItem!.viewType!,showTitle:data.modifierItem!.showTitle!)
                if let modifierCellObj = ModifierFactory.getModifierFactory(modifierItem.modifierName!,option: modifierOption, modifierItem:modifierItem, viewType: modifierItem.viewType!, selectionType: modifierItem.selectionType!, titleShow:modifierItem.showTitle!){
                
                    self.items.append(modifierCellObj)
                }

            }
        }
    }

}


extension ModifierViewModel: UITableViewDataSource, UITableViewDelegate, CellSelectionDelegate,CellSingleSelectionDelegate{
    
    func didSelectSingleCellItem(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String) {
        
        self.mDelegate?.singleItemSelected(state, modifierItem:modifierItem, option: option, type:type)
    }
    
    func didSelectCellItem(_ state: Bool,modifierItem: ModifierItem, option: ModifierOption, type:String) {
        
        self.mDelegate?.itemSelected(state, modifierItem:modifierItem, option: option, type:type)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.section]
        switch item.type{ // check selected cell type
            
        case .FullViewSingleSelectionType:
            let cell : FullViewSingleSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewSingleSelectionCell.identifier, for: indexPath) as! FullViewSingleSelectionCell
            cell.selectedOption.isSelected = !cell.selectedOption.isSelected
            self.mDelegate?.singleItemSelected(cell.selectedOption.isSelected, modifierItem:item.modifierItem, option: item.modifierOption[indexPath.row], type:item.type.rawValue)
            
        case .FullViewMultiSelectionType:
            let cell : FullViewMultiSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewMultiSelectionCell.identifier, for: indexPath) as! FullViewMultiSelectionCell
            cell.selectedOption.modifierItem = item.modifierItem
            cell.selectedOption.option = item.modifierOption[indexPath.row]
            cell.selectedOption.viewType = item.type.rawValue
            cell.selectedOption.isSelected = !item.modifierOption[indexPath.row].selected!
            //cell.selectedOption.onSelectChange()
            self.mDelegate?.itemSelected(cell.selectedOption.isSelected, modifierItem:item.modifierItem, option: item.modifierOption[indexPath.row], type:item.type.rawValue)
            
        case .ComponentViewMultiSelectionType:
            self.optionsDelegate?.optionsItemSelected(true, modifierItem: item.modifierItem, option: item.modifierOption, type: item.type.rawValue)
        
       case .ComponentViewSingleSelectionType:
            self.optionsDelegate?.optionsItemSelected(true, modifierItem: item.modifierItem, option: item.modifierOption, type: item.type.rawValue)
//        default:
//            break
            
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items[section].rowCount
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section]
        
        switch item.type{ // check which type of cell is the current cell
            
        case .FullViewSingleSelectionType:
            let cell : FullViewSingleSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewSingleSelectionCell.identifier, for: indexPath) as! FullViewSingleSelectionCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.cellDelegate = self
            cell.item = item
            cell.modifierName.text = item.modifierOption[indexPath.row].optionName!
            if !item.modifierOption[indexPath.row].noCost!{
                cell.price.text = "+" + Resources.currency + String(item.modifierOption[indexPath.row].cost!)
            }
            else{
                cell.price.text = ""
            }
            cell.selectedOption.modifierItem = item.modifierItem
            cell.selectedOption.option = item.modifierOption[indexPath.row]
            cell.selectedOption.viewType = item.type.rawValue
            cell.selectedOption.isSelected = item.modifierOption[indexPath.row].selected!
            self.radioOptions.append(cell.selectedOption)
            if indexPath.row == item.modifierOption.count-1{
               
                    for (_,radioOption) in self.radioOptions.enumerated(){
                        radioOption.alternateButton = self.radioOptions.filter{ $0 != radioOption}
                    }
                
            }
            return cell
            
        case .FullViewMultiSelectionType:
            let cell : FullViewMultiSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewMultiSelectionCell.identifier, for: indexPath) as! FullViewMultiSelectionCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.cellDelegate = self
            cell.item = item
            if item.modifierOption.count>0{
            cell.modifierName.text = item.modifierOption[indexPath.row].optionName!
            if !item.modifierOption[indexPath.row].noCost!{
                cell.price.text = "+" + Resources.currency + String(item.modifierOption[indexPath.row].cost!)
            }
            else{
                cell.price.text = ""
            }
            cell.selectedOption.customTag = item.modifierOption[indexPath.row].modifierOptionID!
            cell.selectedOption.modifierItem = item.modifierItem
            cell.selectedOption.option = item.modifierOption[indexPath.row]
            cell.selectedOption.viewType = item.type.rawValue
            //print("cell for row: \(item.modifierOption[indexPath.row].selected!)")
            cell.selectedOption.isSelected = item.modifierOption[indexPath.row].selected!
            }
            return cell
            
        case .ComponentViewMultiSelectionType:
            let cell : ComponentViewMultiSelectionCell = tableView.dequeueReusableCell(withIdentifier: ComponentViewMultiSelectionCell.identifier, for: indexPath) as! ComponentViewMultiSelectionCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.item = item
            cell.modifierName.text = item.modifierItem.modifierName!
            cell.price.text = ""

            return cell

        case .ComponentViewSingleSelectionType:
            let cell : ComponentViewMultiSelectionCell = tableView.dequeueReusableCell(withIdentifier: ComponentViewMultiSelectionCell.identifier, for: indexPath) as! ComponentViewMultiSelectionCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.item = item
            cell.modifierName.text = item.modifierItem.modifierName!
            cell.price.text = ""

            
            return cell
            
//        default:
//            break
        
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if items[section].showTitle {
            let title = CustomLabel()
            title.font = UIFont.systemFont(ofSize: 13)
            title.text = items[section].sectionTitle
            title.textColor = UIColor.white
            title.backgroundColor = UIColor.gray
            title.numberOfLines = 0
            title.lineBreakMode = NSLineBreakMode.byWordWrapping
            title.sizeToFit()

            let tcLabelSize:CGSize = title.sizeThatFits(CGSize(width: tableView.frame.size.width, height: CGFloat.greatestFiniteMagnitude));           return (tcLabelSize.height + 8)
        }
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if items[section].showTitle{
            return items[section].sectionTitle
        }
        return  ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        let headerView = UIView(frame: CGRect(x: 20, y: 0, width: tableView.frame.width, height: 50))
        //headerView.backgroundColor = UIColor.whiteColor()
        
        let title = CustomLabel()
        if items[section].showTitle{
            title.font = UIFont.systemFont(ofSize: 13)
            title.text = items[section].sectionTitle
            title.textColor = UIColor.white
            title.backgroundColor = UIColor.gray
            title.numberOfLines = 0
            title.lineBreakMode = NSLineBreakMode.byWordWrapping
            title.sizeToFit()

        
        }
        return title
    }
    
}

class ModifierFactory{ // returns the desired factory cell object based on viewType  & selecttionType
    
    static func getModifierFactory(_ name:String,option:Array<ModifierOption>, modifierItem:ModifierItem, viewType:String, selectionType:String, titleShow:Bool)->ModifierViewModelItem?{
        
        let typeValue =  selectionType + viewType
        
        switch typeValue {
        case ModifierViewType.FullViewMultiSelectionType.rawValue:
            
            return FullViewMultipleSelection(name:name,option: option, modifierItem:modifierItem,titleShow:titleShow)
            
        case ModifierViewType.ComponentViewMultiSelectionType.rawValue:
            
            return ComponentViewMultipleSelection(name:name,option: option, modifierItem:modifierItem,titleShow:false)
            
        case ModifierViewType.ComponentViewSingleSelectionType.rawValue:
            
            return ComponentViewSingleSelection(name:name,option: option, modifierItem:modifierItem,titleShow:false)
            
        case ModifierViewType.FullViewSingleSelectionType.rawValue:
            
            return FullViewSingleSelection(name:name,option: option, modifierItem:modifierItem,titleShow:titleShow)
            
        default:
            break
        }
        return nil
    }
}

class FullViewSingleSelection: ModifierViewModelItem{ // dynamic cell item
    
    var name:String?
    var option: Array<ModifierOption>?
    var modifiersItem: ModifierItem?
    var titleShow:Bool?
    
    var showTitle: Bool{
        return self.titleShow!
    }
    var type: ModifierViewType{
        return .FullViewSingleSelectionType
    }
    var sectionTitle:String{
        if let titleVisible = titleShow{
            if titleVisible{
                return name!
            }
        }
        return ""
    }
    var rowCount:Int{
        return option!.count
    }
    var modifierOption:Array<ModifierOption>{
        return option!
    }
    var modifierItem:ModifierItem{
        return modifiersItem!
    }
    init(name:String,option: Array<ModifierOption>, modifierItem:ModifierItem, titleShow:Bool){
        
        self.titleShow = titleShow
        self.option = option
        self.name = name
        self.modifiersItem = modifierItem
    }
}
class FullViewMultipleSelection: ModifierViewModelItem{
    
    var name:String?
    var option: Array<ModifierOption>?
    var modifiersItem: ModifierItem?
    var titleShow:Bool?
    
    var showTitle: Bool{
        return self.titleShow!
    }

    var type: ModifierViewType{
        return .FullViewMultiSelectionType
    }
    var sectionTitle:String{
        if let titleVisible = titleShow{
            if titleVisible{
                return name!
            }
        }
        return ""
    }
    var rowCount:Int{
        return option!.count
    }
    var modifierOption:Array<ModifierOption>{
        return option!
    }
    var modifierItem:ModifierItem{
        return modifiersItem!
    }
    init(name:String,option: Array<ModifierOption>, modifierItem:ModifierItem, titleShow:Bool){
        
        self.titleShow = titleShow
        self.option = option
        self.name = name
        self.modifiersItem = modifierItem
    }
}
class ComponentViewMultipleSelection: ModifierViewModelItem{
    
    var name:String?
    var option: Array<ModifierOption>?
    var modifiersItem: ModifierItem?
    var titleShow:Bool?
    
    var showTitle: Bool{
        return self.titleShow!
    }

    var type: ModifierViewType{
        return .ComponentViewMultiSelectionType
    }
    var sectionTitle:String{
        if let titleVisible = titleShow{
            if titleVisible{
                return name!
            }
        }
        return ""
    }
    var rowCount:Int{
        return 1
    }
    var modifierOption:Array<ModifierOption>{
        return option!
    }
    var modifierItem:ModifierItem{
        return modifiersItem!
    }
    init(name:String,option: Array<ModifierOption>, modifierItem:ModifierItem, titleShow:Bool){
        
        self.titleShow = titleShow
        self.option = option
        self.name = name
        self.modifiersItem = modifierItem
    }
}
class ComponentViewSingleSelection: ModifierViewModelItem{
    var name:String?
    var option: Array<ModifierOption>?
    var modifiersItem: ModifierItem?
    var titleShow:Bool?
    
    var showTitle: Bool{
        return self.titleShow!
    }

    var type: ModifierViewType{
        return .ComponentViewSingleSelectionType
    }
    var sectionTitle:String{
        if let titleVisible = titleShow{
            if titleVisible{
                return name!
            }
        }
        return ""
    }
    var rowCount:Int{
        return 1
    }
    var modifierOption:Array<ModifierOption>{
        return option!
    }
    var modifierItem:ModifierItem{
        return modifiersItem!
    }
    init(name:String,option: Array<ModifierOption>, modifierItem:ModifierItem, titleShow:Bool){
        
        self.titleShow = titleShow
        self.option = option
        self.name = name
        self.modifiersItem = modifierItem
    }
}
