

import UIKit

let TOASTPOSITIONCENTER = "center"
let TOASTPOSITIONTOP = "top"
let TOASTPOSTIONBOTTOM = "bottom"

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
}
public extension UITableView {
    
    func registerCellClass(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewClass(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        self.register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewNib(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

extension HomeVC : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.characters.count
    }
}

extension NSObject {
    
    func convertToDictionary(text: String) ->  Dictionary<String, Any>? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as?  Dictionary<String, Any>
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertStringAnyObjectToString(dict:Dictionary<String, Any>) ->  Dictionary<String, String>?{
        var targetDict = [String: String]()
        for (key, value) in dict {
            if let value = value as? String { targetDict[key] = value }
        }
            return targetDict
        
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            
            self.updateValue(value, forKey:key)
        }
    }
}

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        if let slide = viewController as? SlideMenuController {
            return topViewController(slide.mainViewController)
        }
        return viewController
    }
}
extension UIViewController {
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }

    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()

    }
    func showLoading(_ text:String){
        ProgressLoader.sharedInstance.showLoader(text)
        
    }
    func hideLoading(){
        
            ProgressLoader.sharedInstance.hideLoader()
        
        
    }
    func isLoaderHidden()->Bool{
        return ProgressLoader.sharedInstance.loaderHidden()
    }
    func showToast(_ backgroundColor:UIColor, textColor:UIColor, message:String,position:String)->UILabel?{
        
        let labelWidthOffSet:CGFloat = 45.0
        let labelDefaultHeight:CGFloat = 50.0
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "Helvetia", size: 15.0)
        label.adjustsFontSizeToFitWidth = true
        
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        var labelSize:CGSize = label.getContentSize(appDelegate.window!.frame.size.width-labelWidthOffSet)
        labelSize.width = appDelegate.window!.frame.size.width - labelWidthOffSet
        if labelSize.height<labelDefaultHeight{
            labelSize.height = labelDefaultHeight
        }
        if position == TOASTPOSITIONCENTER{
            label.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
            label.center.y = appDelegate.window!.center.y
        }
        else if position == TOASTPOSTIONBOTTOM{
            label.frame = CGRect(x: 0, y: self.view.bounds.maxY-75, width: labelSize.width, height: labelSize.height)
            
        }
        else if position == TOASTPOSITIONTOP{
            label.frame = CGRect(x: self.view.bounds.size.width/2, y: self.view.bounds.minY+60, width: labelSize.width, height: labelSize.height)
            
        }
        label.center.x = self.view.center.x
        label.alpha = 1
        
        //appDelegate.window!.addSubview(label)
        return label
    }
}
extension UILabel{
    func getContentSize(_ width:CGFloat)->CGSize{
        
        let labelSize:CGSize = self.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return labelSize
    }
    
}
