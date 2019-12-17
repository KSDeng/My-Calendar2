//
//  TaskProcessViewController.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/14.
//  Copyright © 2019 dks. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol TaskProcessDelegate {
    func addTask(task: TaskDB)
    func deleteTask(task: TaskDB)
    func editTask(task: TaskDB)
}


class TaskProcessViewController: UITableViewController {
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var ifAllDaySwitch: UISwitch!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startTimeButton: UIButton!
    
    @IBOutlet weak var startDateTimePicker: UIDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var endDateTimePicker: UIDatePicker!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var invitationLabel: UILabel!
    
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var notificationCurrentSettingLabel: UILabel!
    
    @IBOutlet weak var notificationNoneButton: UIButton!
    
    @IBOutlet weak var notificationTenMinutesButton: UIButton!
    
    @IBOutlet weak var notificationHalfAnHourButton: UIButton!
    
    @IBOutlet weak var notificationOneHourButton: UIButton!
    
    @IBOutlet weak var notificationCustomButton: UIButton!
    
    
    // MARK: - Constants
    // 本地通知管理器
    let notificationManager = LocalNotificationManager()
    
    // 日期索引格式
    let dateIndexFormat = "yyyy-MM-dd"
    
    // MARK: - Variables
    // 每个section的行数
    var numberOfRows = [1,3,1,1,1,1]
    
    // 是否展示时间选择器
    var ifShowStPicker = false
    var ifShowEdPicker = false
    // 缓存时间中的值
    var tmpStartDate: Date?
    var tmpStartTime: Date?
    var tmpEndDate: Date?
    var tmpEndTime: Date?
    
    // 当前状态
    var status = ProcessStatus.Default
    
    // 当前展示的Task
    var displayTask: TaskDB?
    
    // 当前设置的开始时间和结束时间(用于进行时间合理性检查)
    var cachedST: Date? {
        willSet {
            if let st = newValue, let et = cachedET, !ifAllDaySwitch.isOn {
                ifTimeSettingValid = !(st > et)
                startDateLabel.textColor = st > et ? UIColor.red : UIColor.black
                startTimeButton.setTitleColor(st > et ? UIColor.red : UIColor.black, for: .normal)
                endDateLabel.textColor = st > et ? UIColor.red : UIColor.black
                endTimeButton.setTitleColor(st > et ? UIColor.red : UIColor.black, for: .normal)
            }
        }
    }
    var cachedET: Date? {
        willSet {
            if let st = cachedST, let et = newValue, !ifAllDaySwitch.isOn {
                ifTimeSettingValid = !(st > et)
                startDateLabel.textColor = st > et ? UIColor.red : UIColor.black
                startTimeButton.setTitleColor(st > et ? UIColor.red : UIColor.black, for: .normal)
                endDateLabel.textColor = st > et ? UIColor.red : UIColor.black
                endTimeButton.setTitleColor(st > et ? UIColor.red : UIColor.black, for: .normal)
            }
        }
    }
    // 时间设置是否合法
    var ifTimeSettingValid = true
    
    // 添加地点时的缓存
    var tmpLocation: MKPlacemark?
    
    // 是否展示更多通知选项
    var ifShowCustomNotificationSettings = false {
        willSet {
            notificationNoneButton.isHidden = !newValue
            notificationTenMinutesButton.isHidden = !newValue
            notificationHalfAnHourButton.isHidden = !newValue
            notificationOneHourButton.isHidden = !newValue
            notificationCustomButton.isHidden = !newValue
        }
    }
    
    // 缓存当前通知
    var tmpNotification: Notification?
    // 时间单位和数量
    var tmpNotificationRange: CustomizedNotificationRange?
    var tmpNotificationNumber: Int?
    // 状态
    var notificationSettingStatus = NotificationSetting.None
    // 自定义notification通知时间秒数记录
    var customNotificationSecondsFromNow: Int?
    
    // 缓存邀请对象
    var tmpInvitations: [Invitation] = []
    
    // 处理任务的代理
    var delegate: TaskProcessDelegate?
    
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupVisibleContent()
        
        setDateTimePickers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 拖动时即隐藏键盘
        tableView.keyboardDismissMode = .onDrag
        
        setupTextFields()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Setups
    private func setupVisibleContent() {
        ifShowCustomNotificationSettings = false
        
        switch status {
        case .HeadToAdd:
            setupHeadToAdd()
        case .BackToAdd:
            setupBackToAdd()
        case .Show:
            setupShow()
        case .Edit:
            setupEdit()
        default:
            print("Status default.")
        }
    }
    
    // 设置DateTimePicker的初始状态
    private func setDateTimePickers() {
        startDateTimePicker.isHidden = true
        startDateTimePicker.datePickerMode = .date
        startDateTimePicker.locale = Locale(identifier: "zh")       // 日期格式设置为'年月日'
        
        endDateTimePicker.isHidden = true
        endDateTimePicker.datePickerMode = .date
        endDateTimePicker.locale = Locale(identifier: "zh")
        
    }
    
    // 输入栏添加完成按钮
    private func setupTextFields() {
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(inputDoneButtonAction))
        
        toolBar.setItems([flexSpace, doneBtn], animated: false)
        toolBar.sizeToFit()
        
        self.titleTextField.inputAccessoryView = toolBar
        self.noteTextField.inputAccessoryView = toolBar
    }
    
    private func setupHeadToAdd() {
        let defaultStart = Date().nearestHour()
        let defaultEnd = Date.init(timeInterval: 60*60, since: Date()).nearestHour()
        
        let defaultStartWeekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: defaultStart)]!
        let defaultEndWeekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: defaultEnd)]!
        // 设置时间缓存
        tmpStartDate = defaultStart
        tmpStartTime = defaultStart
        tmpEndDate = defaultEnd
        tmpEndTime = defaultEnd
        // 开启时间合法性检查
        cachedST = defaultStart
        cachedET = defaultEnd
        
        // 设置初始时间标签
        startDateLabel.text = "\(defaultStart.getAsFormat(format: "yyyy年M月d日")) \(defaultStartWeekday)"
        startTimeButton.setTitle(defaultStart.getAsFormat(format: "HH:mm"), for: .normal)
        endDateLabel.text = "\(defaultEnd.getAsFormat(format: "yyyy年M月d日")) \(defaultEndWeekday)"
        endTimeButton.setTitle(defaultEnd.getAsFormat(format: "HH:mm"), for: .normal)
    }
    
    private func setupBackToAdd() {
        // print("setupBackToAdd")
        
        if tmpInvitations.count > 0 {
            
            if tmpInvitations.count == 1 {
                invitationLabel.text = "\(tmpInvitations[0].name)"
            } else {
                invitationLabel.text = "\(tmpInvitations[0].name)等\(tmpInvitations.count)位"
            }
            invitationLabel.textColor = UIColor.black
        } else {
            if status == .Show {
                invitationLabel.text = "未添加邀请对象"
                invitationLabel.textColor = UIColor.black
            } else if status == .BackToAdd || status == .HeadToAdd {
                invitationLabel.text = "添加邀请对象"
                invitationLabel.textColor = UIColor.lightGray
            }
        }
        
    }
    
    private func setupShow() {
        guard let task = displayTask else {
            fatalError("Display task not set!")
        }
        navigationItem.title = "事务详情"
        
        titleTextField.isUserInteractionEnabled = false
        ifAllDaySwitch.isUserInteractionEnabled = false
        startDateLabel.isUserInteractionEnabled = false
        startTimeButton.isUserInteractionEnabled = false
        endDateLabel.isUserInteractionEnabled = false
        endTimeButton.isUserInteractionEnabled = false
        invitationLabel.isUserInteractionEnabled = false
        noteTextField.isUserInteractionEnabled = false
        
        // 主题
        titleTextField.text = task.title
        // 时间
        setDateTimeLabels(startDate: task.startDate, startTime: task.startTime, endDate: task.endDate, endTime: task.endTime)
        cachedST = getTimeCombined(date: task.startDate, time: task.startTime!)
        cachedET = getTimeCombined(date: task.endDate, time: task.endTime!)
        tmpStartDate = task.startDate
        tmpStartTime = task.startTime!
        tmpEndDate = task.endDate!
        tmpEndTime = task.endTime!
        
        // 地点
        if let loc = task.location {
            locationLabel.text = loc.title
            locationLabel.textColor = UIColor.black
        } else {
            locationLabel.text = "未添加地点"
            locationLabel.textColor = UIColor.black
        }
        
        // 全天开关
        ifAllDaySwitch.isOn = task.ifAllDay
        if ifAllDaySwitch.isOn {
            startTimeButton.isHidden = true
            endTimeButton.isHidden = true
        }
        // 通知
        if let noti = task.notification {
            var range: String?
            switch CustomizedNotificationRange(rawValue: noti.rangeRawValue)!  {
            case .Minute: range = "分钟"
            case .Hour: range = "小时"
            case .Day: range = "天"
            case .Week: range = "周"
            }
            notificationCurrentSettingLabel.text = "提前\(noti.number)\(range!)通知"
        } else {
            notificationCurrentSettingLabel.text = "未设置通知"
            notificationSettingStatus = .None
        }
        
        
        // 备注
        if let note = task.note {
            noteTextField.text = note
            noteTextField.textColor = UIColor.black
        } else {
            noteTextField.text = "未添加备注"
        }
        
        // 邀请
        // https://stackoverflow.com/questions/36954095/iterate-nsset-and-cast-to-type-in-one-step
        // 将持久化的邀请还原
        for case let inv as InvitationDB in task.invitations! {
            let invitation = Invitation(name: inv.name, lastEditTime: inv.lastEditTime)
            if let contact = inv.contact {
                invitation.contact = contact
            }
            tmpInvitations.append(invitation)
            tmpInvitations.sort(by: {$0.lastEditTime < $1.lastEditTime})
        }
        
        if tmpInvitations.count > 0 {
            
            if tmpInvitations.count == 1 {
                invitationLabel.text = "\(tmpInvitations[0].name)"
            } else {
                invitationLabel.text = "\(tmpInvitations[0].name)等\(tmpInvitations.count)位"
            }
            invitationLabel.textColor = UIColor.black
        } else {
            invitationLabel.text = "未添加邀请对象"
            invitationLabel.textColor = UIColor.black
        }
        
        // navigationItem 某一侧添加多个BarButtonItem
        // https://stackoverflow.com/questions/30341263/how-to-add-multiple-uibarbuttonitems-on-right-side-of-navigation-bar
        let deleteButton = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(deleteButtonClicked))
        // 设置bar button item 字体颜色
        // https://stackoverflow.com/questions/664930/uibarbuttonitem-with-color
        deleteButton.tintColor = UIColor.red
        let editButton = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editButtonClicked))
        
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }
    
    private func setupEdit() {
        guard let task = displayTask else {
            fatalError("Edit task nil!")
        }
        
        tmpStartDate = task.startDate
        tmpStartTime = task.startTime!
        tmpEndDate = task.endDate!
        tmpEndTime = task.endTime!
        cachedST = getTimeCombined(date: tmpStartDate, time: tmpStartTime)
        cachedET = getTimeCombined(date: tmpEndDate, time: tmpEndTime)
        
        // 标题
        titleTextField.text = task.title
        // 全天开关
        ifAllDaySwitch.isOn = task.ifAllDay
        startTimeButton.isHidden = ifAllDaySwitch.isOn
        endTimeButton.isHidden = ifAllDaySwitch.isOn
        
        // 时间
        setDateTimeLabels(startDate: task.startDate, startTime: task.startTime, endDate: task.endDate, endTime: task.endTime)
        
        // 地点
        if let loc = task.location {
            locationLabel.text = loc.title
            locationLabel.textColor = UIColor.black
        }
        
        // 备注
        noteTextField.text = task.note
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfRows[section]
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // 若是展示事务内容则将cell设置为不可选择
        // https://stackoverflow.com/questions/812426/uitableview-setting-some-cells-as-unselectable
        if status == .Show {
            // 此时地点和邀请栏可以交互
            // https://stackoverflow.com/questions/2267993/uitableview-how-to-disable-selection-for-some-rows-but-not-others
            return (indexPath.section == 2) ? indexPath : nil
        }
        
        // 打开全天开关之后结束时间不可交互
        if ifAllDaySwitch.isOn {
            return (indexPath.section == 1 && indexPath.row == 2) ? nil : indexPath
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier
        switch identifier {
        case "locationCell": self.view.endEditing(true)
        case "invitationCell": self.view.endEditing(true)
        case "startTimeCell":
            self.view.endEditing(true)
            if (!ifShowStPicker) {
                startDateTimePicker.datePickerMode = .date
                startDateTimePicker.locale = Locale(identifier: "zh")
                ifShowStPicker = true
            } else if (ifShowStPicker && startDateTimePicker.datePickerMode == .time){
                startDateTimePicker.datePickerMode = .date
                startDateTimePicker.locale = Locale(identifier: "zh")
            } else if (ifShowStPicker && startDateTimePicker.datePickerMode == .date){
                ifShowStPicker = false
            }
            guard let tmpSD = tmpStartDate else {
                fatalError("tmpStartDate doesn't exist!")
            }
            startDateTimePicker.date = tmpSD
            startDateTimePicker.isHidden = !ifShowStPicker
        case "endTimeCell":
            self.view.endEditing(true)
            if (!ifShowEdPicker) {
                endDateTimePicker.datePickerMode = .date
                endDateTimePicker.locale = Locale(identifier: "zh")
                ifShowEdPicker = true
            } else if (ifShowEdPicker && endDateTimePicker.datePickerMode == .time){
                endDateTimePicker.datePickerMode = .date
                endDateTimePicker.locale = Locale(identifier: "zh")
            } else if (ifShowEdPicker && endDateTimePicker.datePickerMode == .date){
                ifShowEdPicker = false
            }
            guard let tmpED = tmpEndDate else {
                fatalError("tmpEndDate doesn't exist!")
            }
            endDateTimePicker.date = tmpED
            endDateTimePicker.isHidden = !ifShowEdPicker
        case "notificationCell":
            self.view.endEditing(true)
            ifShowCustomNotificationSettings = !ifShowCustomNotificationSettings
            
        default:
            print("Clicked cell not handled.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var res: CGFloat = 44
        
        // 时间设置栏
        if indexPath.section == 1 {
            if indexPath.row == 1 && ifShowStPicker {
                res = 214
            }
            if indexPath.row == 2 {
                if ifAllDaySwitch.isOn {
                    res = 0
                } else if ifShowEdPicker {
                    res = 214
                }
            }
        }
        
        // 通知设置栏
        if indexPath.section == 4 {
            if ifShowCustomNotificationSettings {
                res = 220
            }
        }
        
        return res
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Actions
    @IBAction func startDateTimePickerChanged(_ sender: UIDatePicker) {
        // print(sender.date)
        let date = sender.date
        let weekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: date)]!
        
        if startDateTimePicker.datePickerMode == .date {
            tmpStartDate = date
            startDateLabel.text = "\(date.getAsFormat(format: "yyyy年M月d日")) \(weekday)"
        } else if startDateTimePicker.datePickerMode == .time {
            tmpStartTime = date
            startTimeButton.setTitle(date.getAsFormat(format: "HH:mm"), for: .normal)
        }
        
        cachedST = getTimeCombined(date: tmpStartDate, time: tmpStartTime)
        // print("cachedST: \(Utils.getDateAsFormat(date: cachedST!, format: "yyyy/M/d HH:mm"))")
        // print("cachedET: \(Utils.getDateAsFormat(date: cachedET!, format: "yyyy/M/d HH:mm"))")
    }
    
    @IBAction func endDateTimePickerChanged(_ sender: UIDatePicker) {
        //print(sender.date)
        let date = sender.date
        let weekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: date)]!
        
        if endDateTimePicker.datePickerMode == .date {
            tmpEndDate = date
            endDateLabel.text = "\(date.getAsFormat(format: "yyyy年M月d日")) \(weekday)"
        } else if endDateTimePicker.datePickerMode == .time {
            tmpEndTime = date
            endTimeButton.setTitle(date.getAsFormat(format: "HH:mm"), for: .normal)
        }
        
        cachedET = getTimeCombined(date: tmpEndDate, time: tmpEndTime)
        // print("cachedST: \(Utils.getDateAsFormat(date: cachedST!, format: "yyyy/M/d HH:mm"))")
        // print("cachedET: \(Utils.getDateAsFormat(date: cachedET!, format: "yyyy/M/d HH:mm"))")
    }
    
    @IBAction func allDaySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            ifTimeSettingValid = true
            startDateLabel.textColor = UIColor.black
            startTimeButton.setTitleColor(UIColor.black, for: .normal)
            endDateLabel.textColor = UIColor.black
            endTimeButton.setTitleColor(UIColor.black, for: .normal)
            
            startTimeButton.isHidden = true
            endTimeButton.isHidden = true
            endDateLabel.isUserInteractionEnabled = false
            
            tmpStartTime = "\(Date().getAsFormat(format: "yyyyMMdd"))0000".toDate(format: "yyyyMMddHHmm")
            tmpEndDate = Date()
            tmpEndTime = "\(Date().getAsFormat(format: "yyyyMMdd"))2359".toDate(format: "yyyyMMddHHmm")
            
        } else {
            startTimeButton.isHidden = false
            endTimeButton.isHidden = false
            endDateLabel.isUserInteractionEnabled = true
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func startTimeButtonClicked(_ sender: UIButton) {
        if (!ifShowStPicker) {
            startDateTimePicker.datePickerMode = .time
            startDateTimePicker.locale = Locale(identifier: "en_GB")        // 时间设置为24小时制
            ifShowStPicker = true
        } else if (ifShowStPicker && startDateTimePicker.datePickerMode == .date) {
            startDateTimePicker.datePickerMode = .time
            startDateTimePicker.locale = Locale(identifier: "en_GB")
        } else if (ifShowStPicker && startDateTimePicker.datePickerMode == .time) {
            ifShowStPicker = false
        }
        guard let tmpST = tmpStartTime else {
            fatalError("tmpStartTime does not exist!")
        }
        // 展开之后显示当前缓存的时间
        startDateTimePicker.date = tmpST
        startDateTimePicker.isHidden = !ifShowStPicker
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func endTimeButtonClicked(_ sender: UIButton) {
        if (!ifShowEdPicker) {
               endDateTimePicker.datePickerMode = .time
               endDateTimePicker.locale = Locale(identifier: "en_GB")
               ifShowEdPicker = true
           } else if (ifShowEdPicker && endDateTimePicker.datePickerMode == .date){
               endDateTimePicker.datePickerMode = .time
               endDateTimePicker.locale = Locale(identifier: "en_GB")
           } else if (ifShowEdPicker && endDateTimePicker.datePickerMode == .time){
               ifShowEdPicker = false
           }
           guard let tmpET = tmpEndTime else {
               fatalError("tmpEndTime does not exist!")
           }
           endDateTimePicker.date = tmpET
           endDateTimePicker.isHidden = !ifShowEdPicker
        
           tableView.beginUpdates()
           tableView.endUpdates()
    }
    
    // 添加事件完成
    @IBAction func saveEventAction(_ sender: Any) {
        // 时间合理性检查
        // https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
        // MARK: TODO 提醒的UI可以更优雅
        if !ifTimeSettingValid {
            let alert = UIAlertController(title: "时间设置错误", message: "开始时间不能晚于结束时间!", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        // 主题
        let title = titleTextField.text!.isEmpty ? "(无主题)" : titleTextField.text!
        // 时间
        guard let stDate = tmpStartDate else {
            fatalError("Start date not set!")
        }
        let lengthInDays = ifAllDaySwitch.isOn ? 0 : numOfDaysBetween(start: stDate, end: tmpEndDate!)
        
        // 创建NSManagedObject
        let task = TaskDB(startDate: stDate, ifAllDay: ifAllDaySwitch.isOn, timeLengthInDays: lengthInDays, title: title, colorPoint: Int(Utils.currentColorPoint), insertInto: Utils.context)
        Utils.currentColorPoint = (Utils.currentColorPoint + 1) % Utils.eventColorArray.count
        
        task.startTime = tmpStartTime
        task.endDate = tmpEndDate
        task.endTime = tmpEndTime

        
        // 地点
        if let loc = tmpLocation {
            // 创建地点(同时持久化)
            let location = LocationDB(title: loc.name!, latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, insertInto: Utils.context)
            location.detail = loc.title
            location.task = task
            task.location = location
        }
        
        // 通知
        if notificationSettingStatus != .None {
            let noti = generateNotification()!
            notificationManager.addNotification(notification: noti)
            // 持久化
            let notificationDB = NotificationDB(id: noti.id, datetime: noti.datetime, title: noti.title, body: noti.body, number: noti.number, range: noti.range, insertInto: Utils.context)
            notificationDB.task = task
            task.notification = notificationDB
        }
        
        // 邀请
        for inv in tmpInvitations {
            // 创建并持久化
            let invDB = InvitationDB(name: inv.name, lastEditTime: inv.lastEditTime, insertInto: Utils.context)
            if let contact = inv.contact {
                invDB.contact = contact
            }
            invDB.task = task
            task.invitations = task.invitations?.adding(invDB) as NSSet?
        }
        
        // 备注
        task.note = noteTextField.text
        
        delegate?.addTask(task: task)
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func notificationNoneButtonClicked(_ sender: UIButton) {
        notificationSettingStatus = .None
        ifShowCustomNotificationSettings = false
        notificationCurrentSettingLabel.text = "不通知"
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func notificationTenMinutesButtonClicked(_ sender: UIButton) {
        notificationSettingStatus = .TenMinutes
        ifShowCustomNotificationSettings = false
        notificationCurrentSettingLabel.text = "提前10分钟通知"
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func notificationHalfAnHourButtonClicked(_ sender: UIButton) {
        notificationSettingStatus = .HalfAnHour
        ifShowCustomNotificationSettings = false
        notificationCurrentSettingLabel.text = "提前30分钟通知"
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func notificationOneHourButtonClicked(_ sender: UIButton) {
        notificationSettingStatus = .AnHour
        ifShowCustomNotificationSettings = false
        notificationCurrentSettingLabel.text = "提前1小时通知"
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Objc functions
    @objc func inputDoneButtonAction(){
        self.view.endEditing(true)
    }
    
    @objc func deleteButtonClicked(){
        guard let task = displayTask else {
            fatalError("Display task not set!")
        }
        
        if task.notification != nil {
            notificationManager.deleteNotification(id: task.notification!.id)
        }
        
        delegate?.deleteTask(task: task)
        navigationController?.popViewController(animated: true)
    }
    @objc func editButtonClicked(){

        navigationItem.title = "编辑事务"
        titleTextField.isUserInteractionEnabled = true
        ifAllDaySwitch.isUserInteractionEnabled = true
        startDateLabel.isUserInteractionEnabled = true
        startTimeButton.isUserInteractionEnabled = true
        endDateLabel.isUserInteractionEnabled = true
        endTimeButton.isUserInteractionEnabled = true
        
        locationLabel.isUserInteractionEnabled = true
        invitationLabel.isUserInteractionEnabled = true
        noteTextField.isUserInteractionEnabled = true
        
        status = .Edit
        let editConfirmButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(confirmEditButtonClicked))
        navigationItem.rightBarButtonItems = [editConfirmButton]
        
        // 设置这两个变量相当于开启时间检查
        cachedST = getTimeCombined(date: tmpStartDate, time: tmpStartTime)
        cachedET = getTimeCombined(date: tmpEndDate, time: tmpEndTime)
        
        guard let task = displayTask else {
            fatalError("Display task nil!")
        }
        
        if task.location == nil{
            locationLabel.text = "添加地点"
        }
    }
    
    @objc func confirmEditButtonClicked(){
        // 检查时间合法性
        if !ifTimeSettingValid {
            let alert = UIAlertController(title: "时间设置错误", message: "开始时间不能晚于结束时间!", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let task = displayTask else {
            fatalError("Edit task nil!")
        }
        
            
            // 主题
            let title = titleTextField.text!.isEmpty ? "(无主题)" : titleTextField.text!
            // 时间
            guard let stDate = tmpStartDate else {
                fatalError("Start date not set!")
            }
            let lengthInDays = ifAllDaySwitch.isOn ? 0 : numOfDaysBetween(start: stDate, end: tmpEndDate!)
            
            // 创建NSManagedObject
            let newTask = TaskDB(startDate: stDate, ifAllDay: ifAllDaySwitch.isOn, timeLengthInDays: lengthInDays, title: title, colorPoint: Int(Utils.currentColorPoint), insertInto: Utils.context)
            newTask.colorPoint = task.colorPoint
            
            if task.notification != nil {
                notificationManager.deleteNotification(id: task.notification!.id)
            }
            delegate?.deleteTask(task: task)
            
            newTask.startTime = tmpStartTime
            newTask.endDate = tmpEndDate
            newTask.endTime = tmpEndTime
            
            // 地点
            if let loc = tmpLocation {
                // 创建地点(同时持久化)
                let location = LocationDB(title: loc.name!, latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, insertInto: Utils.context)
                location.detail = loc.title
                location.task = newTask
                newTask.location = location
            }
            
            // 通知
            if notificationSettingStatus != .None {
                let noti = generateNotification()!
                notificationManager.addNotification(notification: noti)
                // 持久化
                let notificationDB = NotificationDB(id: noti.id, datetime: noti.datetime, title: noti.title, body: noti.body, number: noti.number, range: noti.range, insertInto: Utils.context)
                notificationDB.task = newTask
                newTask.notification = notificationDB
            }
            
            // 邀请
            for inv in tmpInvitations {
                // 创建并持久化
                let invDB = InvitationDB(name: inv.name, lastEditTime: inv.lastEditTime, insertInto: Utils.context)
                if let contact = inv.contact {
                    invDB.contact = contact
                }
                invDB.task = newTask
                newTask.invitations = task.invitations?.adding(invDB) as NSSet?
            }
        
            // 备注
            newTask.note = noteTextField.text
            
            delegate?.addTask(task: newTask)
            
            navigationController?.popViewController(animated: true)
            

    }
    
    // MARK: - Private utils
    private func getTimeCombined(date: Date?, time: Date?) -> Date {
        guard let tmpD = date, let tmpT = time else {
            fatalError("date or time does not exist!")
        }
        let dateString = tmpD.getAsFormat(format: "yyyyMMdd")
        let timeString = tmpT.getAsFormat(format: "HHmm")
        let f = DateFormatter()
        f.dateFormat = "yyyyMMddHHmm"
        let getT = f.date(from: "\(dateString)\(timeString)")
        guard let T = getT else {
            fatalError("Current time invalid!")
        }
        return T
    }
    
    // 两个日期之间的天数
    // https://iostutorialjunction.com/2019/09/get-number-of-days-between-two-dates-swift.html
    private func numOfDaysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    // 获取一个Notification
    private func generateNotification() -> Notification? {
        guard let stDate = tmpStartDate, let stTime = tmpStartTime else {
            fatalError("Notification start time invalid!")
        }
        let startTime = getTimeCombined(date: stDate, time: stTime)
        let id = UUID()
        let title = titleTextField.text ?? "无主题"
        var datetime = Date()
        var body = ""
        var range: CustomizedNotificationRange?
        var number = 0
        
        switch notificationSettingStatus {
        case .TenMinutes:
            number = 10
            range = .Minute
            datetime = Date(timeInterval: -10*60, since: startTime)
        case .HalfAnHour:
            number = 30
            range = .Minute
            datetime = Date(timeInterval: -30*60, since: startTime)
        case .AnHour:
            number = 60
            range = .Minute
            datetime = Date(timeInterval: -60*60, since: startTime)
        case .Custom:
            guard let seconds = customNotificationSecondsFromNow else {
                fatalError("Try to use custom notification but parameters incomplete!")
            }
            datetime = Date(timeInterval: Double(-seconds), since: startTime)
        default:
            fatalError("Current notification setting not handled.")
        }
        
        body = "⏰\(startTime.getAsFormat(format: "HH:mm"))"
        
        var noti: Notification? = nil
        if notificationSettingStatus != .Custom {
            noti = Notification(id: id, datetime: datetime, title: title, body: body, number: number, range: range!)
        }else {
            guard let nr = tmpNotificationRange, let nn = tmpNotificationNumber else {
                fatalError("Custom notification parameters incomplete!")
            }
            noti = Notification(id: id, datetime: datetime, title: title, body: body, number: nn, range: nr)
        }
        
        return noti
    }
    
    // 设置初始时间显示
    private func setDateTimeLabels(startDate: Date, startTime: Date?, endDate: Date?, endTime: Date?) {
        let weekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: startDate)]!
        startDateLabel.text = "\(startDate.getAsFormat(format: "yyyy年M月d日")) \(weekday)"
        
        if let stTime = startTime {

            startTimeButton.setTitle(stTime.getAsFormat(format: "HH:mm"), for: .normal)
            
            if let edDate = endDate, let edTime = endTime {
                let eWeekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: edDate)]!
                endDateLabel.text = "\(edDate.getAsFormat(format: "yyyy年M月d日")) \(eWeekday)"
                endTimeButton.setTitle(edTime.getAsFormat(format: "HH:mm"), for: .normal)
            }
            
        }else {
            startTimeButton.isHidden = true
            endTimeButton.isHidden = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "customizeNotificationSegue" {
            notificationSettingStatus = .Custom
            let dest = (segue.destination) as! CustomizeNotificationController
            dest.delegate = self
            status = .BackToAdd
        } else if segue.identifier == "showMapSegue" {
            let dest = (segue.destination) as! MapViewController
            
            if status == .HeadToAdd {
                dest.state = .add
            } else if status == .Show {
                dest.state = .show
                guard let task = displayTask else {
                    fatalError("Display task nil!")
                }
                dest.showTitle = task.location?.title
                dest.showLongitude = task.location?.longitude
                dest.showLatitude = task.location?.latitude
            }else if status == .Edit {
                dest.state = .edit
                guard let task = displayTask else {
                    fatalError("Display task nil!")
                }
                dest.showTitle = task.location?.title
                dest.showLongitude = task.location?.longitude
                dest.showLatitude = task.location?.latitude
            }
            
            dest.delegate = self
            status = .BackToAdd
        } else if segue.identifier == "addInvitationSegue" {
            let dest = (segue.destination) as! InvitationViewController
            dest.delegate = self
            dest.currentInvitations = tmpInvitations
            
            status = .BackToAdd
        }
    }
    

}

// MARK: - Extensions
// 设置地点
extension TaskProcessViewController: SetLocationHandle {
    func setLocation(location: MKPlacemark) {
        tmpLocation = location
        self.locationLabel.text = location.name
        self.locationLabel.textColor = UIColor.black
    }
    
    func editLocationDone(location: MKPlacemark) {
        tmpLocation = location
        self.locationLabel.text = location.name
        self.locationLabel.textColor = UIColor.black
    }
    
}


// 自定义通知时间
extension TaskProcessViewController: CustomNotificationDelegate {
    func setNotificationPara(secondsFromNow: Int, sentence: String, range: CustomizedNotificationRange, number: Int) {
        self.customNotificationSecondsFromNow = secondsFromNow
        self.notificationCurrentSettingLabel.text = sentence
        self.tmpNotificationRange = range
        self.tmpNotificationNumber = number
    }
}



extension TaskProcessViewController: SetInvitationDelegate {
    func setInvitations(inv: [Invitation]) {
        self.tmpInvitations = inv
        print("Number of tmpInvitations: \(tmpInvitations.count)")
    }
}
