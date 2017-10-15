

import UIKit

typealias WordTuple = (word: String, meaning: String, partsOfSpeech: String, apiResult:String,source:String)
typealias WordDictionary = [String: String]

class DataStore: NSObject {

    let tupleStoreKey = "tupleKey"
    let wordKey = "wordKey"
    let meaningKey = "meaningKey"
    let partsOfSpeechKey = "partsOfSpeechKey"
    let apiResultKey = "apiResultKey"
    let sourceKey = "sourceKey"
    let userNameKey = "userNameKey"
    let userDefault = UserDefaults.standard
    
    private func serializeTuple(tuple: WordTuple) -> WordDictionary {
        return [
            wordKey : tuple.word,
            meaningKey : tuple.meaning,
            partsOfSpeechKey : tuple.partsOfSpeech,
            apiResultKey: tuple.apiResult,
            sourceKey: tuple.source
        ]
    }
    
    private func deserializeDictionary(dictionary: WordDictionary) -> WordTuple {
        return WordTuple(
            dictionary[wordKey] as String! ?? "",
            dictionary[meaningKey] as String! ?? "",
            dictionary[partsOfSpeechKey] as String! ?? "",
            dictionary[apiResultKey] as String! ?? "",
            dictionary[sourceKey] as String! ?? ""
        )
    }
    func setWordDefinition(word:String, meaning:String, partsOfSpeech:String, apiResult:String,source:String){//save to local storage
        let wordLevels: WordTuple = (word: word, meaning: meaning,partsOfSpeech:partsOfSpeech, apiResult:apiResult,source:source)
        
        // Writing to local storage
        let wordDictionary = self.serializeTuple(tuple: wordLevels)
        userDefault.set(wordDictionary, forKey: self.tupleStoreKey)


    }
    func getWordDefinition() -> WordTuple{ // reading from local storage
        let wordDic = userDefault.dictionary(forKey: self.tupleStoreKey) as! WordDictionary
        return self.deserializeDictionary(dictionary: wordDic)
    }
    func setUserName(name:String){
        userDefault.set(name, forKey: self.userNameKey)
    }
    func getUserName()->String{
        if let name = userDefault.object(forKey: self.userNameKey) as? String{
            return name
        }
        return ""
    }
}
