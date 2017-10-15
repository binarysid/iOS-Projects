

import Foundation

import UIKit
import QuartzCore

class ProgressLoader: UIView {
    
    // MARK - Variables
    // MARK - Init
    var loaderFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var loaderTextLabel = UILabel()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let sharedInstance = ProgressLoader(frame: CGRect.zero)
    
    override init(frame : CGRect) {
        
        super.init(frame: frame)
        
        loaderFrame.frame = CGRect(x: 0, y: 0, width: appDelegate.window!.frame.size.width/1.5, height: 60)
        loaderFrame.center = appDelegate.window!.center
        loaderFrame.layer.cornerRadius = 15
        loaderFrame.backgroundColor = UIColor(white: 1, alpha: 1.0)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: 10, y: 0, width: loaderFrame.frame.size.height/2, height: loaderFrame.frame.size.height)
        //activityIndicator.startAnimating()
        loaderTextLabel = UILabel(frame: CGRect(x: activityIndicator.frame.maxX+8 , y: 0, width:  ((loaderFrame.frame.size.width-activityIndicator.frame.size.width)-8) , height: loaderFrame.frame.size.height))
        //loaderTextLabel.text = "Loading"
        loaderTextLabel.textColor = UIColor.black
        loaderFrame.addSubview(activityIndicator)
        
        loaderFrame.addSubview(loaderTextLabel)
        //self.frame = loaderFrame.bounds
        //self.addSubview(loaderFrame)
    }
    func showLoader(_ mssg:String){
        self.loaderTextLabel.text = mssg
        self.activityIndicator.startAnimating()
        appDelegate.window!.addSubview(loaderFrame)
        
    }
    func hideLoader(){
        if self.activityIndicator.isAnimating{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loaderFrame.removeFromSuperview()
            }
            
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loaderHidden()->Bool{
        return self.loaderFrame.isHidden
    }
    // MARK - Func
    
}
