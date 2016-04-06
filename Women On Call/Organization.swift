import Foundation

struct Organization {
    let id   : Int
    let city : String
}

extension Organization {
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


