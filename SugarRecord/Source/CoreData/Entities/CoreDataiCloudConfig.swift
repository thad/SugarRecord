import Foundation

public struct CoreDataiCloudConfig {
    
    // MARK: - Attributes
    
    public let ubiquitousContentName: String
    public let ubiquitousContentURL: String
    public let ubiquitousContainerIdentifier: String
    public let ubiquitousPeerTokenOption: String?
    public let removeUbiquitousMetadataOption: Bool?
    public let rebuildFromUbiquitousContentOption: Bool?
    
    
    // MARK: - Init
    
    public init(ubiquitousContentName: String,
        ubiquitousContentURL: String,
        ubiquitousContainerIdentifier: String,
        ubiquitousPeerTokenOption: String? = nil,
        removeUbiquitousMetadataOption: Bool? = nil,
        rebuildFromUbiquitousContentOption: Bool? = nil) {
            self.ubiquitousContentName = ubiquitousContentName
            self.ubiquitousContentURL = ubiquitousContentURL
            self.ubiquitousPeerTokenOption = ubiquitousPeerTokenOption
            self.removeUbiquitousMetadataOption = removeUbiquitousMetadataOption
            self.ubiquitousContainerIdentifier = ubiquitousContainerIdentifier
            self.rebuildFromUbiquitousContentOption = rebuildFromUbiquitousContentOption
    }
}
