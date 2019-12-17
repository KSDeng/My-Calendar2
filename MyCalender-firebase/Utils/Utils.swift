//
//  Utils.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/13.
//  Copyright © 2019 dks. All rights reserved.
//

import UIKit
import Foundation

class Utils {
    // MARK: - Functions
    
    
    // MARK: - Constants and Variables
    // weekday与中文描述对应的map
    // https://stackoverflow.com/questions/27990503/nsdatecomponents-returns-wrong-weekday
    public static let weekDayMap = [ 1:"周日", 2:"周一", 3:"周二", 4:"周三", 5:"周四", 6:"周五", 7:"周六" ]
    
    // 节假日颜色
    public static let holidayColor = UIColor(red:0.09, green:0.63, blue:0.52, alpha:1.0)           // 绿
    
    // 调休日颜色
    public static let adjustDayColor = UIColor(red:0.95, green:0.15, blue:0.07, alpha:1.0)        // 红
    // 自定义事件卡片颜色
    public static let eventColorArray = [
        UIColor(red:0.22, green:0.67, blue:0.98, alpha:1.0),            // 蓝
        UIColor(red:0.90, green:0.39, blue:0.39, alpha:1.0),            // 红
        UIColor(red:0.88, green:0.50, blue:0.95, alpha:1.0),            // 紫罗兰
        UIColor(red:0.39, green:0.90, blue:0.90, alpha:1.0)             // 靓
    ]
    
    // 事件卡片颜色指针
    public static var currentColorPoint = 0
    
    // 月份背景图
    public static let monthImageMap = [
        1: UIImage(named: "January")!,
        2: UIImage(named: "February")!,
        3: UIImage(named: "March")!,
        4: UIImage(named: "April")!,
        5: UIImage(named: "May")!,
        6: UIImage(named: "June")!,
        7: UIImage(named: "July")!,
        8: UIImage(named: "August")!,
        9: UIImage(named: "September")!,
        10: UIImage(named: "October")!,
        11: UIImage(named: "November")!,
        12: UIImage(named: "December")!
    ]
    
    // CoreData上下文
    public static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
}

// MARK: - Enums
// 事件种类
// 任务、节假日、节假日调休
// Implicit raw value
// String类型的raw value将默认与case同名
enum EventType: String {
    case Task, Holiday, Adjust, Today
}
// 任务处理界面状态(增加、编辑、展示、默认)
enum ProcessStatus: String {
    case HeadToAdd, BackToAdd, Edit, Show, Default
}

// 日历表格的cell种类
enum CalendarCellType: String {
    case Week
    case MonthImage
}

// 日历表格的内容(Union Value)
enum CalendarCellContent {
    case weekDesc(String, String, Date, Date)       // 开始日期描述、结束日期描述、开始日期、结束日期
    case monthImage(String, UIImage)                // 标题、图片
}

// 自定义通知提前的时间单位
enum CustomizedNotificationRange: String {
    case Minute, Hour, Day, Week
}

enum Month: Int {
    case January = 1, February, March, April, May, June,
    July, August, September, October, November, December
}

// 通知设置的种类
enum NotificationSetting: String {
    case None, TenMinutes, HalfAnHour, AnHour, Custom
}

// MARK: - Extensions
extension Date {
    // https://stackoverflow.com/questions/33605816/first-and-last-day-of-the-current-month-in-swift
    // https://stackoverflow.com/questions/35687411/how-do-i-find-the-beginning-of-the-week-from-an-nsdate
    
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month], from: self)
        guard let date = calendar.date(from: components) else {
            fatalError("First day of month doesn't exist!")
        }
        return date
    }
    
    func lastDayOfMonth() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        guard let date = calendar.date(byAdding: components, to: self.firstDayOfMonth()) else {
            fatalError("Last day of month doesn't exist!")
        }
        return date
    }
    
    func firstDayOfWeek() -> Date {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let date = calendar.date(from: components) else {
            fatalError("First day of week doesn't exist!")
        }
        return date
    }
    
    func lastDayOfWeek() -> Date {
        let calendar = Calendar(identifier: .iso8601)
        var components = DateComponents()
        components.weekOfYear = 1
        components.day = -1
        guard let date = calendar.date(byAdding: components, to: self.firstDayOfWeek()) else {
            fatalError("Last day of week doesn't exist!")
        }
        return date
    }
    
    func daysOffset(by: Int) -> Date {
        return Date(timeInterval: Double(by * 24 * 60 * 60), since: self)
    }
    
    // https://stackoverflow.com/questions/31590316/how-do-i-find-the-number-of-days-in-given-month-and-year-using-swift
    func numOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        guard let count = range?.count else {
            fatalError("Number of month doesn't exist!")
        }
        return count
    }
    
    func getAsFormat(format: String) -> String {
        let f = DateFormatter()
        f.timeZone = .autoupdatingCurrent
        f.dateFormat = format
        return f.string(from: self)
    }
    
    // 获得最近的下一个整点
    func nearestHour() -> Date {
        var components = Calendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = 60 - minute
        if let getDate = Calendar.current.date(byAdding: components, to: self){
            return getDate
        } else{
            print("Neareast hour doesn't exist!")
            return Date()
        }
    }
}

extension String {
    
    // 由字符串得到时间
    func toDate(format: String) -> Date {
        let f = DateFormatter()
        f.dateFormat = format
        guard let date = f.date(from: self) else {
            fatalError("Invalid date!")
        }
        return date
    }
}
