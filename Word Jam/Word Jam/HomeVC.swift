
import UIKit
import AWSCognito
import AWSS3
import AWSSNS


class HomeVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var wordTextField: UITextView!
    
    let identityPoolID = "us-west-2:0c57a6ca-b882-4ca7-ab96-d2cac360a80c"
    let regionType = AWSRegionType.USWest2
    let snsTopic = "arn:aws:sns:us-west-2:327210751071:statup-challenge-push"
    let store = DataStore() // local data storage object
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let placeHolder = "type word of the day"
    // become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Resources.appBackgroundColor
        self.configureAWSService()
        self.configureWordTextField()
        self.becomeFirstResponder() // To get shake gesture
        
    }
    
    private func configureWordTextField(){
        
        self.wordTextField.delegate = self
        self.wordTextField.backgroundColor = Resources.textFieldBackgroundColor
        self.wordTextField.text = self.placeHolder
        self.wordTextField.textColor = UIColor.lightGray
        self.wordTextField.becomeFirstResponder()
        
        //self.wordTextField.selectedTextRange = self.wordTextField.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        //self.wordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
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
            if let label = self.showToast(Resources.bandToastColor, textColor: UIColor.white, message: self.store.getWordDefinition().word, position: TOASTPOSITIONTOP){
                self.setBandLabelAction(label: label)
                self.view.addSubview(label)
                let when = DispatchTime.now() + 5 // 5 seconds delay
                DispatchQueue.main.asyncAfter(deadline: when) {
                    label.removeFromSuperview()
                }
           }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //let wordDef = self.store.getWordDefinition() // get word from local storage

        if textView.text.lowercased().range(of:self.store.getWordDefinition().word ) != nil{ // when user input match with word of the day publish it to AWS SNS topic
            self.publishToSNSTopic(userInput:textView.text!)
        }

    }

    private func configureAWSService(){
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: self.regionType, identityPoolId: self.identityPoolID)
        let configuration = AWSServiceConfiguration(region: self.regionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

    }
    
    private func publishToSNSTopic(userInput:String) {
        let sns = AWSSNS.default()
        let request = AWSSNSPublishInput()
        request?.messageStructure = "json"
        
        do {
            //self.view.endEditing(true)
            //self.showLoading("Sending to AWS")
            
            let jsonData = try JSONSerialization.data(withJSONObject: self.getJsonData(userInput:userInput), options: [])
            request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
            request?.targetArn = self.snsTopic
            
            sns.publish(request!).continueWith { (task) -> AnyObject! in
                print(request?.message ?? "")
                //self.hideLoading()
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
    
    private func getJsonData(userInput:String)->Dictionary<String, String>{
        
        let wordDef = self.store.getWordDefinition() // get word information
        
        
//        if let dictionaryJson = convertToDictionary(text: (wordDef.apiResult)){
//            //print(wordDef.apiResult)
//        // convert [String:Any] to [String:String]
//            dict.update(other: convertStringAnyObjectToString(dict: dictionaryJson)!)
//        }
        let dict = ["default": "The default message","name": self.store.getUserName(),"userMessage":userInput, "source":wordDef.source, "apiResult": wordDef.apiResult]

        return dict
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeHolder
            textView.textColor = UIColor.lightGray
        }
    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        <#code#>
//    }
    
//    func textFieldDidBeginEditing(_ textField: UITextView) {
//        
//    }
//    func textFieldDidEndEditing(_ textField: UITextView) {
//        animateViewMoving(up: true, moveValue: -(textField.frame.origin.y/2-50))
//    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

//    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


