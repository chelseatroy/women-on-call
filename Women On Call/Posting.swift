class Posting {
    let orgId: Int?
    let title: String?
    let description: String?
    let contact: String?
    let skill: String?
    
    init(orgId: Int, title: String, description: String, contact: String, skill: String) {
        self.orgId = orgId
        self.title = title
        self.description = description
        self.contact = contact
        self.skill = skill
    }
}
