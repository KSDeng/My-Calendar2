//
//  TaskProcessViewController.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/14.
//  Copyright © 2019 dks. All rights reserved.
//

import UIKit

protocol TaskProcessDelegate {
    func addTask(task: Task)
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
    var displayTask: Task?
    
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
    
    // 处理任务的代理
    var delegate: TaskProcessDelegate?
    
    
    
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVisibleContent()
        
        setDateTimePickers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Setups
    private func setupVisibleContent() {
        switch status {
        case .Add:
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfRows[section]
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
        let task = Task(startDate: stDate, ifAllDay: ifAllDaySwitch.isOn, timeLengthInDays: lengthInDays, title: title)
        // let taskDB = TaskDB(startDate: stDate, ifAllDay: ifAllDaySwitch.isOn, timeLengthInDays: lengthInDays, title: title, insertInto: Utils.context)
        
        if !task.ifAllDay {
            guard let stTime = tmpStartTime, let edDate = tmpEndDate, let edTime = tmpEndTime else {
                fatalError("Time setting incomplete!")
            }
            task.startTime = stTime
            task.endDate = edDate
            task.endTime = edTime
        }
        
        // 颜色
        task.colorPoint = Utils.currentColorPoint
        Utils.currentColorPoint = (Utils.currentColorPoint + 1) % Utils.eventColorArray.count
        
        
        
        delegate?.addTask(task: task)
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func notificationNoneButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func notificationTenMinutesButtonClicked(_ sender: UIButton) {
        
    }
    
    
    @IBAction func notificationHalfAnHourButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func notificationOneHourButtonClicked(_ sender: UIButton) {
        
    }
    
    // MARK: - Objc functions
    @objc func doneButtonAction(){
        
    }
    
    @objc func deleteButtonClicked(){
        
    }
    @objc func editButtonClicked(){

    }
    
    @objc func confirmEditButtonClicked(){

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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
