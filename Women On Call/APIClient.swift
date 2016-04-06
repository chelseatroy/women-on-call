import Foundation

enum Result<T,E:ErrorType> {
    case Success(T)
    case Failure(E)
}

struct SimpleError : ErrorType {
    let message: String
}

struct LoginResponse {
    let apiKey : String
    let skills : [String]
}

//struct NetworkClient {
//    let session: NSURLSession
//    
//    func login(u: String, p: String, callback: AuthenticatedNetworkClient -> Void) {}
//}
//
//struct AuthenticatedNetworkClient {
//    let session: NSURLSession
//    let apiKey: String
//    
//    func getOrgsForCity(city: String, callback: Result<[Org], SimpleError> -> Void) {}
//}

func makeLoginRequest(
    username username: String,
    password: String,
    callback: Result<LoginResponse, SimpleError> -> Void
) {
    let urlString = "http://www.womenoncall.org/api/v1/users/login"
    
    let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    let formEncoded = "login=\(username)&password=\(password)" // TODO: form encode safely
    request.HTTPMethod = "POST"
    request.HTTPBody = formEncoded.dataUsingEncoding(NSUTF8StringEncoding)
    
    makeRequest(request) { result in
        switch result {
        case let .Success(jsonDictionary):
            let maybeUserJSON = jsonDictionary["api_user"] as? NSDictionary
            let maybeAPIKey = maybeUserJSON?["api_key"] as? String
            let maybeVolunteerProfile = maybeUserJSON?["volunteer_profile"] as? NSDictionary
            let maybeSkills = maybeVolunteerProfile?["skills"] as? [String]
            
            guard let apiKey = maybeAPIKey, skills = maybeSkills else {
                callback(.Failure(SimpleError(message: "couldn't get skills + API key")))
                return
            }
            
            callback(.Success(LoginResponse(apiKey: apiKey, skills: skills)))
        case let .Failure(e):
            callback(.Failure(e))
        }
    }
}


func getOrganizations(
    apiKey: String,
    callback: Result<[Organization], SimpleError> -> Void
) {
    let organizationURL = NSURL(string: "http://www.womenoncall.org/api/v1/organizations?api_key=\(apiKey)")! // TODO: maybe fix
    let request = NSMutableURLRequest(URL: organizationURL)
    
    makeRequest(request) { result in
        switch result {
        case let .Success(jsonDictionary):
            let orgs : [Organization]
            if let items = jsonDictionary["organizations"] as? NSArray {
                orgs = items.flatMap{$0 as? NSDictionary}.flatMap(Organization.init)
            } else {
                orgs = []
            }
            callback(.Success(orgs))
        case let .Failure(e):
            callback(.Failure(e))
        }
    }
}

func getOrganizations(
    apiKey: String,
    inCity city: String,
    callback: Result<[Organization], SimpleError> -> Void
) {
    getOrganizations(apiKey) { result in
        switch result {
        case let .Success(orgs):
            let filteredOrgs = orgs.filter { $0.city == city }
            callback(.Success(filteredOrgs))
        case let .Failure(e):
            callback(.Failure(e))
        }
    }
}

func getPostings(
    apiKey: String,
    forOrgs orgs: [Organization],
    withSkills skills: [String],
    callback: Result<[VolunteerPosting], SimpleError> -> Void
) {
    let postingsURL = NSURL(string: "http://www.womenoncall.org/api/v1/postings?api_key=\(apiKey)")!
    let postingsRequest = NSURLRequest(URL: postingsURL)
    makeRequest(postingsRequest) { result in
        switch result {
        case let .Success(jsonDictionary):
            if let postingsJSON = jsonDictionary["postings"] as? [NSDictionary] {
                let postings = postingsJSON
                    .flatMap(VolunteerPosting.init)
                    .filter { posting in orgs.map{$0.id}.contains(posting.orgID) }
                    .filter { posting in skills.contains(posting.skill) }
                callback(.Success(postings))
            }
            break
        case let .Failure(e):
            callback(.Failure(e))
        }
    }
}

// struct NetworkResponse {
//  NSHTTPURLResponse, NSData
// ]
// NSURLRequest -> Eventual<Result<(NSHTTPURLResponse, NSData), NetworkError>>

private func makeRequest(request: NSURLRequest, callback: Result<NSDictionary, SimpleError> -> Void) {
    let task = NSURLSession
    .sharedSession()
    .dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
        guard maybeError == nil else {
            callback(.Failure(SimpleError(message: "network error")))
            return
        }
        
        guard let data = maybeData, httpResponse = maybeResponse as? NSHTTPURLResponse else {
            callback(.Failure(SimpleError(message: "something weird happened, no data fo real?")))
            return
        }
        
        // TODO: check response status code
        print(httpResponse.statusCode)
        
        let maybeJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        let maybeDictionary = maybeJSON as? NSDictionary
        
        guard let jsonDictionary = maybeDictionary else {
            callback(.Failure(SimpleError(message: "un-readable json")))
            return
        }
        
        guard jsonDictionary["error"] == nil else {
            callback(.Failure(SimpleError(message: jsonDictionary["error"]?.description ?? "empty error key ?!?!?")))
            return
        }
        
        callback(.Success(jsonDictionary))
    }
    task.resume()
}