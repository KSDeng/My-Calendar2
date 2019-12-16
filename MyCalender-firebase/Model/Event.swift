
import Foundation

class Event {
    var startDate: Date
    var type: EventType
    var ifAllDay: Bool
    var timeLengthInDays: Int
    var title: String
    var ifSerializable: Bool
    
    init(startDate: Date, type: EventType, ifAllDay: Bool, timeLengthInDays: Int, title: String, ifSerializable: Bool) {
        self.startDate = startDate
        self.type = type
        self.ifAllDay = ifAllDay
        self.timeLengthInDays = timeLengthInDays
        self.title = title
        self.ifSerializable = ifSerializable
    }
}

class Task: Event {
    
    var startTime: Date?
    var endDate: Date?
    var endTime: Date?
    var colorPoint: Int?
    var note: String?
    var location: Location?
    var invatations: [Invitation]?
    var notifications: [Notification]?
    
    init(startDate: Date, ifAllDay: Bool, timeLengthInDays: Int, title: String) {
        super.init(startDate: startDate, type: .Task, ifAllDay: ifAllDay, timeLengthInDays: timeLengthInDays, title: title, ifSerializable: true)
    }
}

class Holiday: Event {
    
    var notification: Notification?
    
    init(date: Date, title: String) {
        // https://stackoverflow.com/questions/24021093/error-in-swift-class-property-not-initialized-at-super-init-call
        // self.notification = notification
        super.init(startDate: date, type: .Holiday, ifAllDay: true, timeLengthInDays: 1, title: title, ifSerializable: false)
    }
    
}

class Adjust: Event {
    
    var notification: Notification?
    
    init(date: Date, title: String) {
        // self.notification = notification
        super.init(startDate: date, type: .Adjust, ifAllDay: true, timeLengthInDays: 1, title: title, ifSerializable: false)
        
    }
}
