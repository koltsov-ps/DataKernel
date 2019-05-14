import Foundation

public enum DKMigrationError: Error {
    case versionNotFound(filename: String)
    case migrationPathNotFound
    case modelNotFound(name: String?, file: String?)
}
