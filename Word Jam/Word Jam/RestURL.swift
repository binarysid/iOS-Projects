
import Foundation

public class RestURL : NSObject{
    
    static let sharedInstance = RestURL()
    private var baseURL = "http://api.wordnik.com/"
    public var WordOfTheDay = "v4/words.json/wordOfTheDay?"
    
    override init(){
        
        WordOfTheDay = baseURL+WordOfTheDay
    }
    
    public func getWordOfTheDay(apiKey:String)->AnyObject{
        
        let param = ["api_key": apiKey]
        return param as AnyObject
    }
   
}
