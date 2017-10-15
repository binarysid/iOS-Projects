
import UIKit
import ObjectMapper

class DefinitionMapper: Mappable {
    
    var meaning: String?
    var partsOfSpeech:String?
    var source: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        meaning <- map["text"]
        partsOfSpeech <- map["partOfSpeech"]
        source <- map["source"]
     }
}
