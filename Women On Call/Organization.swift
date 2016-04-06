import Foundation

class Organization {
    let id: Int
    let name: String
    let zipCode: String
    
    init(id: Int, name: String, zipCode: String) {
        self.id = id
        self.name = name
        self.zipCode = zipCode
    }
}

struct Org {
    let id   : Int
    let city : String
}

extension Org {
    init?(fromJSON json: NSDictionary) {
        guard let
            id   = json["id"] as? Int,
            city = json["city"] as? String
            
            else {
                return nil
        }
        
        self.id = id
        self.city = city
    }
}


