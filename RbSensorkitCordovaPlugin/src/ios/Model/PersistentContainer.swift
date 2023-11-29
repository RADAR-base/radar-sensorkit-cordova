/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of classes that define the Core Data stack that stores feed entries in the database.
*/

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer {
//    private static let lastRefreshKey = "lastRefresh"
    
    private static let lastFetchKey = "lastFetchKey"

//    private static let lastFetchAccelerometerKey = "lastFetchAccelerometerKey"
//    private static let lastFetcAmbientLighthKey = "lastFetcAmbientLighthKey"
//    private static let lastFetchAmbientPressureKey = "lastFetchAmbientPressureKey"
//    private static let lastFetchDeviceUsageKey = "lastFetchDeviceUsageKey"
//    private static let lastFetchKeyboardMetricsKey = "lastFetchKeyboardMetricsKey"
//    private static let lastFetchMedaiEventsKey = "lastFetchMedaiEventsKey"
//    private static let lastFetchMessageUsageKey = "lastFetchMessageUsageKey"
//    private static let lastFetchOnWristKey = "lastFetchOnWristKey"
//    private static let lastFetchPedometerKey = "lastFetchPedometerKey"
//    private static let lastFetchPhoneUsageKey = "lastFetchPhoneUsageKey"
//    private static let lastFetchRotationRateKey = "lastFetchRotationRateKey"
//    private static let lastFetchTelephonySpeechMetricsKey = "lastFetchTelephonySpeechMetricsKey"
//    private static let lastFetchVisitKey = "lastFetchVisitKey"
//    private static let lastFetchSiriSpeechMetricsKey = "lastFetchSiriSpeechMetricsKey"
//    private static let lastFetchFaceMetricsKey = "lastFetchFaceMetricsKey"
//    private static let lastFetchHeartRateKey = "lastFetchHeartRateKey"
//    private static let lastFetchWristTemperatureKey = "lastFetchWristTemperatureKey"
//    private static let lastFetchOdometerKey = "lastFetchOdometerKey"

    
    static let shared: PersistentContainer = {
//        ValueTransformer.setValueTransformer(ColorTransformer(), forName: NSValueTransformerName(rawValue: String(describing: ColorTransformer.self)))
        
        let container = PersistentContainer(name: "LastUpdate")
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            
            print("\(Date().timeIntervalSince1970) Successfully loaded persistent store at: \(desc.url?.description ?? "nil")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        
        return container
    }()
    
//    var lastRefreshed: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastRefreshKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastRefreshKey)
//        }
//    }
    
    var lastFetched: Date? {
        get {
            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchKey)
        }
    }
    
//    var lastFetchedAccelerometer: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchAccelerometerKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchAccelerometerKey)
//        }
//    }
//    
//    var lastFetchedAmbientLighth: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetcAmbientLighthKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetcAmbientLighthKey)
//        }
//    }
//    
//    var lastFetchedAmbientPressure: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchAmbientPressureKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchAmbientPressureKey)
//        }
//    }
//    
//    var lastFetchedDeviceUsage: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchDeviceUsageKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchDeviceUsageKey)
//        }
//    }
//    
//    var lastFetchedMessageUsage: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchMessageUsageKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchMessageUsageKey)
//        }
//    }
//    
//    var lastFetchedKeyboardMetrics: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchKeyboardMetricsKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchKeyboardMetricsKey)
//        }
//    }
//    
//    var lastFetchedMedaiEvents: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchMedaiEventsKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchMedaiEventsKey)
//        }
//    }
//    
//    var lastFetchedOnWrist: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchOnWristKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchOnWristKey)
//        }
//    }
//    
//    var lastFetchedPedometer: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchPedometerKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchPedometerKey)
//        }
//    }
//    
//    var lastFetchedPhoneUsage: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchPhoneUsageKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchPhoneUsageKey)
//        }
//    }
//    
//    var lastFetchedRotationRate: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchRotationRateKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchRotationRateKey)
//        }
//    }
//    
//    var lastFetchedTelephonySpeechMetrics: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchTelephonySpeechMetricsKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchTelephonySpeechMetricsKey)
//        }
//    }
//    
//    var lastFetchedVisit: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchVisitKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchVisitKey)
//        }
//    }
//    
//    var lastFetchedSiriSpeechMetrics: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchSiriSpeechMetricsKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchSiriSpeechMetricsKey)
//        }
//    }
//    
//    var lastFetchedFaceMetrics: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchFaceMetricsKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchFaceMetricsKey)
//        }
//    }
//    
//    var lastFetchedHeartRate: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchHeartRateKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchHeartRateKey)
//        }
//    }
//    
//    var lastFetchedWristTemperature: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchWristTemperatureKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchWristTemperatureKey)
//        }
//    }
//    
//    var lastFetchedOdometer: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastFetchOdometerKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastFetchOdometerKey)
//        }
//    }
//    
//    override func newBackgroundContext() -> NSManagedObjectContext {
//        let backgroundContext = super.newBackgroundContext()
//        backgroundContext.automaticallyMergesChangesFromParent = true
//        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
//        return backgroundContext
//    }
}

extension PersistentContainer {
    // Fills the Core Data store with initial fake data
    // If onlyIfNeeded is true, only does so if the store is empty
    func loadInitialData(onlyIfNeeded: Bool = true) {
        let context = newBackgroundContext()
        context.perform {
            do {
//                let allEntriesRequest: NSFetchRequest<NSFetchRequestResult> = FeedEntry.fetchRequest()
//                if !onlyIfNeeded {
//                    // Delete all data currently in the store
//                    let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: allEntriesRequest)
//                    deleteAllRequest.resultType = .resultTypeObjectIDs
//                    let result = try context.execute(deleteAllRequest) as? NSBatchDeleteResult
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: result?.result as Any],
//                                                        into: [self.viewContext])
//                }
//                if try !onlyIfNeeded || context.count(for: allEntriesRequest) == 0 {
//                    let now = Date()
//                    let start = now - (7 * 24 * 60 * 60)
//                    let end = now - (60 * 60)
//                    
//                    _ = generateFakeEntries(from: start, to: end).map { FeedEntry(context: context, serverEntry: $0) }
//                    try context.save()
                let initDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: -48, to: Date(), options: [])!

                self.lastFetched = initDate
//                self.lastFetchedAccelerometer = daysAgo
//                self.lastFetchedAmbientLighth = daysAgo
//                self.lastFetchedAmbientPressure = daysAgo
//                self.lastFetchedDeviceUsage = daysAgo
//                self.lastFetchedMessageUsage = daysAgo
//                self.lastFetchedFaceMetrics = daysAgo
//                self.lastFetchedHeartRate = daysAgo
//                self.lastFetchedKeyboardMetrics = daysAgo
//                self.lastFetchedMedaiEvents = daysAgo
//                self.lastFetchedOdometer = daysAgo
//                self.lastFetchedOnWrist = daysAgo
//                self.lastFetchedPedometer = daysAgo
//                self.lastFetchedPhoneUsage = daysAgo
//                self.lastFetchedRotationRate = daysAgo
//                self.lastFetchedSiriSpeechMetrics = daysAgo
//                self.lastFetchedTelephonySpeechMetrics = daysAgo
//                self.lastFetchedVisit = daysAgo
//                self.lastFetchedWristTemperature = daysAgo
//                self.lastRefreshed = nil
//                }
            } catch {
                print("\(Date().timeIntervalSince1970) Could not load initial data due to \(error)")
            }
        }
    }
}


// A platform-agnostic model object representing a color, suitable for persisting with Core Data
//public class Color: NSObject, NSSecureCoding {
//    public let red: Double
//    public let green: Double
//    public let blue: Double
//    
//    public init(red: Double, green: Double, blue: Double) {
//        self.red = red
//        self.green = green
//        self.blue = blue
//        super.init()
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        self.red = aDecoder.decodeDouble(forKey: "red")
//        self.green = aDecoder.decodeDouble(forKey: "green")
//        self.blue = aDecoder.decodeDouble(forKey: "blue")
//    }
//    
//    public func encode(with aCoder: NSCoder) {
//        aCoder.encode(red, forKey: "red")
//        aCoder.encode(green, forKey: "green")
//        aCoder.encode(blue, forKey: "blue")
//    }
//    
//    public static var supportsSecureCoding: Bool {
//        return true
//    }
//}
//
//public class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
//    public override class func transformedValueClass() -> AnyClass {
//        return Color.self
//    }
//}

