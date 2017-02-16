import Foundation

public class VersionProvider: NSObject {
    
    // MARK: - Constants
    
    public static let apiReleasesUrl: String = "https://api.github.com/repos/carambalabs/sugarrecord/releases"

    
    // MARK: - public
    
    public func framework() -> String! {
        if let version = Bundle(for: VersionProvider.classForCoder()).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return nil
    }
    
    public func github(_ completion: @escaping (String) -> Void) {
        let request: URLRequest = URLRequest(url: URL(string: VersionProvider.apiReleasesUrl)!)
        URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                let json: AnyObject? = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
                if let array = json as? [[String: AnyObject]], let lastVersion = array.first, let versionTag: String = lastVersion["tag_name"] as? String {
                    completion(versionTag)
                }
            }
        }).resume()
    }
    
}
