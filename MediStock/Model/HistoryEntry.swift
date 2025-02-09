import Foundation
import FirebaseFirestoreSwift



struct HistoryEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var medicineId: String
    var userId: String
    var user: String
    var action: String
    var details: String
    var timestamp: Date

    init(id: String? = nil, medicineId: String, userId: String, user: String, action: String, details: String, timestamp: Date = Date()) {
        self.id = id
        self.medicineId = medicineId
        self.userId = userId
        self.user = user
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }
}
