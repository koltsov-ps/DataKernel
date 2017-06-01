import Foundation

public enum DKMigrationError: Error {
    case failedToGetVersionFromFilename(filename: String)
    case failedToCreateModel(file: String?)
    case failedToBuildMigrationPath
}
