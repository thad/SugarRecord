import Foundation

public class VersionController {
    
    // MARK: - Attributes
    
    fileprivate let provider: VersionProvider
    fileprivate let logger: Logger
    
    
    // MARK: - Init
    
    public init(provider: VersionProvider = VersionProvider(),
                  logger: Logger = Logger()) {
        self.provider = provider
        self.logger = logger
    }
    
    
    // MARK: - public
    
    public func check() {
        let frameworkVersion = self.provider.framework()
        self.provider.github { [weak self] (githubVersion) in
            if frameworkVersion != githubVersion {
                self?.logger.log("There's a new version available, \(githubVersion)")
            }
        }
    }
    
}
