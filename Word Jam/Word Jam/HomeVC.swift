
import UIKit
import AWSCognito
import AWSS3
import AWSSNS


class HomeVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var wordTextField: UITextField!
    
    let identityPoolID = "us-west-2:0c57a6ca-b882-4ca7-ab96-d2cac360a80c"
    let regionType = AWSRegionType.USWest2
    let snsTopic = "arn:aws:sns:us-west-2:327210751071:statup-challenge-push"
    let store = DataStore() // local data storage object
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWordTextField()
        self.view.backgroundColor = Resources.appBackgroundColor
        self.becomeFirstResponder() // To get shake gesture
        self.configureAWSService()
    }
    
    private func configureWordTextField(){
        self.wordTextField.backgroundColor = Resources.textFieldBackgroundColor
        self.wordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }
    
    private func setBandLabelAction(label:UILabel){
        label.isUserInteractionEnabled = true
        let bandTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeVC.bandTapped(_:)))
        bandTapGesture.delegate = self as UIGestureRecognizerDelegate
        label.addGestureRecognizer(bandTapGesture)
    }
    
    func bandTapped(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: self.store.getWordDefinition().word, message: "\(self.store.getWordDefinition().meaning)", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
      
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //print("shake shake")
            if let label = self.showToast(UIColor(red: 98/255.0, green: 78/255.0, blue: 161/255.0, alpha: 1.0), textColor: UIColor.white, message: self.store.getWordDefinition().word, position: TOASTPOSITIONTOP){
                self.setBandLabelAction(label: label)
                self.view.addSubview(label)
                let when = DispatchTime.now() + 5 // 5 seconds delay
                DispatchQueue.main.asyncAfter(deadline: when) {
                    label.removeFromSuperview()
                }
           }
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        let wordDef = self.store.getWordDefinition() // get word from local storage
        if textField.text == wordDef.word{ // when user input match with word of the day publish it to AWS SNS topic
            self.publishToSNSTopic()
        }
    }
    
    private func configureAWSService(){
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: self.regionType, identityPoolId: self.identityPoolID)
        let configuration = AWSServiceConfiguration(region: self.regionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

    }
    
    private func publishToSNSTopic() {
        let sns = AWSSNS.default()
        let request = AWSSNSPublishInput()
        request?.messageStructure = "json"
        
        do {
            self.view.endEditing(true)
            self.showLoading("Sending to AWS")
            let jsonData = try JSONSerialization.data(withJSONObject: self.getJsonData(), options: [])
            request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
            request?.targetArn = self.snsTopic
            sns.publish(request!).continueWith { (task) -> AnyObject! in
                self.hideLoading()
                if task.error != nil {
                    print("error \(String(describing: task.error)), result:; \(String(describing: task.result))")
                }
                else {
                   
                    if task.isCompleted{
                        print("complete");
                    }
                    else if task.isCancelled{
                        print("cancelled");
                    }
                    else if task.isFaulted{
                        print("faulted");
                    }
                    
                }
                
                return nil
            }
        }catch {
            print("JSON serialization failed:  \(error)")
        }
        
    }
    private func getJsonData()->Dictionary<String, String>{
        
        let wordDef = self.store.getWordDefinition() // get word information
        var dict = ["default": "The default message","name": self.store.getUserName(),"source":wordDef.source]
        
        if let dictionaryJson = convertToDictionary(text: (wordDef.apiResult)){
        // convert [String:Any] to [String:String]
            dict.update(other: convertStringAnyObjectToString(dict: dictionaryJson)!)
        }
        

        return dict
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: textField.frame.origin.y/2-50)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        animateViewMoving(up: true, moveValue: -(textField.frame.origin.y/2-50))
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


