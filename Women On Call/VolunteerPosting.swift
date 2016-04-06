import Foundation

struct VolunteerPosting {
    let orgID: Int
    let title: String
    let description: String
    let contact: String
    let skill: String
}

extension VolunteerPosting {
    init?(fromJSON json: NSDictionary) {
        guard let
            orgID       = json["organization_id"] as? Int,
            title       = json["title"] as? String,
            description = json["custom_project_description"] as? String,
            contact     = json["contact"] as? String,
            skill       = json["skill"] as? String
            else { return nil }
        
        self.orgID = orgID
        self.title = title
        self.description = description
        self.contact = contact
        self.skill = skill
    }
}


