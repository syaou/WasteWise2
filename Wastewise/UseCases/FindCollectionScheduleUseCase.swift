import Foundation

/// Problems a resident may encounter when looking up a household's collection information.
/// Correct incomplete or unmatched addresses, contact City of Parramatta when no zone covers
/// the address, or check the connection and retry when collection data is unavailable.
enum FindCollectionScheduleError: LocalizedError, Equatable {
    case addressNotFound
    case incompleteAddress
    case unsupportedAddress
    case dataUnavailable

    var errorDescription: String? {
        switch self {
        case .addressNotFound: return "Address not found. Check your saved address and try again."
        case .incompleteAddress: return "Enter a street, suburb and four digit postcode."
        case .unsupportedAddress: return "No collection area found. Check your address or contact council."
        case .dataUnavailable: return "Couldn’t load collections. Check your connection and try again."
        }
    }
}

/// Validates a residential address and retrieves usable collection information through the repository.
/// Rejects unsupported addresses and results with neither dates nor a complete day/area pair.
/// The live ArcGIS path supplies collection zone information rather than calculated calendar dates.
struct FindCollectionScheduleUseCase {
    let repository: any WasteWiseRepository

    func execute(address: ResidentialAddress) async throws -> CollectionSchedule {
        guard address.isComplete else { throw FindCollectionScheduleError.incompleteAddress }
        let schedule: CollectionSchedule?
        do { schedule = try await repository.collectionSchedule(for: address) }
        catch is CancellationError { throw CancellationError() }
        catch let error as FindCollectionScheduleError { throw error }
        catch { throw FindCollectionScheduleError.dataUnavailable }
        guard let schedule else { throw FindCollectionScheduleError.unsupportedAddress }
        guard !schedule.collections.isEmpty || (schedule.collectionDay?.isEmpty == false && schedule.recyclingArea?.isEmpty == false) else { throw FindCollectionScheduleError.dataUnavailable }
        return schedule
    }
}
