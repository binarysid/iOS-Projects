
import UIKit
import ObjectMapper

class WordMapper: Mappable {
    
    var id: Int?
    var word: String?
    var definition: [DefinitionMapper]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        word <- map["word"]
        definition <- map["definitions"]
        
    }
}
