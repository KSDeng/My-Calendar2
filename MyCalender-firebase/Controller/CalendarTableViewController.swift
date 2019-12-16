//
//  CalendarTableViewController.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/14.
//  Copyright © 2019 dks. All rights reserved.
//

import UIKit
import Foundation
import MJRefresh
import Alamofire
import SwiftyJSON
import CoreData

struct CellData {
    var id: String              // 每个cell用起始天转换得到的字符串作为唯一标识
    var type: CalendarCellType
    var content: CalendarCellContent
}

class CalendarTableViewController: UITableViewController {

    @IBOutlet weak var currentYearButton: UIBarButtonItem!
    
    // 节假日请求接口地址
    let holidayRequestURL = "http://timor.tech/api/holiday/year"
    
    // 日期索引格式
    let dateIndexFormat = "yyyy-MM-dd"
    
    // 几种Cell/View的高度
    let weekCellHeight: CGFloat = 40
    let eventViewHeight: CGFloat = 55
    let imageCellHeight: CGFloat = 120
    
    var tableData: [CellData] = []
    
    var pageSize = 10
    var startIndex = 0, endIndex = 0
    
    // 特殊日期(节假日、调休日、今天)，不进行持久化
    var specialDays: [Event] = []
    
    // 用户添加的事务，要进行持久化
    // 把task和CellData分开符合低耦合的原则
    var tasks: [Task] = []
    // Cell的高度
    var heights: [String:CGFloat] = [:]
    
    // 已经获取过节假日信息的年份
    var holidayGotYears = Set<String>()
    
    // 第一次加载
    var ifFirstTime = true
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupRefresh()
        setupInitData()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // loadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }

    // MARK: - Setups
    
    // 配置上/下拉刷新控件
    private func setupRefresh() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // 设置下拉刷新控件和下拉刷新处理函数
        tableView.mj_header = MJRefreshGifHeader()
        tableView.mj_header.setRefreshingTarget(self, refreshingAction: #selector(downPullRefresh))
        
        // 设置上拉刷新控件和上拉刷新处理函数
        tableView.mj_footer = MJRefreshAutoGifFooter()
        tableView.mj_footer.setRefreshingTarget(self, refreshingAction: #selector(upPullRefresh))
    }
    
    // 配置初始数据
    private func setupInitData() {
        if startIndex == 0 {
            loadRefresh(number: pageSize / 2, direction: false)
        }
        if endIndex == 0 {
            loadRefresh(number: pageSize, direction: true)
        }
        let year = Date().getAsFormat(format: "yyyy")
        if (!holidayGotYears.contains(year)){
            requestHolidayInfo(year: Int(year)!)
            holidayGotYears.insert(year)
        }
        if ifFirstTime {
            // 设置今天
            let today = Event(startDate: Date(), type: .Today, ifAllDay: true, timeLengthInDays: 1, title: "今天", ifSerializable: false)
            specialDays.append(today)
            let index = today.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
            if !heights.keys.contains(index){
                heights[index] = weekCellHeight
            }
            heights[index]! += (eventViewHeight + 1)
            ifFirstTime = false
        }
        
    }
    
    // MARK: - Refresh Handlers
    private func loadRefresh(number: Int, direction: Bool){
        if direction {  // 上拉
            
            for i in (endIndex ..< (endIndex + number)){
                let date = Date().daysOffset(by: 7 * i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monthOfStart = firstDay.getAsFormat(format: "M")
                let monthOfEnd = lastDay.getAsFormat(format: "M")
                // print("from \(firstDay.getAsFormat(format: "yyyy-MM-dd")) to \(lastDay.getAsFormat(format: "yyyy-MM-dd"))")
                
                let id = firstDay.getAsFormat(format: dateIndexFormat)
                
                // 年份发生变化时请求节假日信息
                let year = lastDay.getAsFormat(format: "yyyy")
                if !holidayGotYears.contains(year){
                    requestHolidayInfo(year: Int(year)!)
                    holidayGotYears.insert(year)
                }
                
                if monthOfStart == monthOfEnd {
                    // print("Month the same")
                    
                    tableData.append(CellData(id: id, type: .Week, content: CalendarCellContent.weekDesc("\(monthOfStart)月\(firstDay.getAsFormat(format: "d"))日", "\(lastDay.getAsFormat(format: "d"))日", firstDay, lastDay)))
                    
                    if !heights.keys.contains(id){
                        heights[id] = weekCellHeight
                    }
                    
                    // 月份更换，插入图片
                    if lastDay.getAsFormat(format: "yyyyMMdd") == date.lastDayOfMonth().getAsFormat(format: "yyyyMMdd") {
                        // print("last day of month.")
                        var index = Int(monthOfEnd)! + 1
                        if index == 12 { index = 1 }
                        
                        tableData.append(CellData(id: "\(id)-img", type: .MonthImage, content: CalendarCellContent.monthImage("\(index)月", Utils.monthImageMap[index]!)))
                    }
                    
                }else {
                    tableData.append(CellData(id: id, type: .Week, content: CalendarCellContent.weekDesc("\(monthOfStart)月\(firstDay.getAsFormat(format: "d"))日", "\(monthOfEnd)月\(lastDay.getAsFormat(format: "d"))日", firstDay, lastDay)))
                    
                    if !heights.keys.contains(id) {
                        heights[id] = weekCellHeight
                    }
                    
                    tableData.append(CellData(id: "\(id)-img", type: .MonthImage, content: CalendarCellContent.monthImage("\(monthOfEnd)月", Utils.monthImageMap[Int(monthOfEnd)!]!)))
                }
            }
            
            endIndex += number
            tableView.reloadData()
            tableView.mj_footer.endRefreshing()
        }else {         // 下拉
            for i in ((startIndex - number) ..< startIndex).reversed(){
                let date = Date().daysOffset(by: 7 * i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monthOfStart = firstDay.getAsFormat(format: "M")
                let monthOfEnd = lastDay.getAsFormat(format: "M")
                
                let id = firstDay.getAsFormat(format: dateIndexFormat)
                
                // 年份发生变化时请求节假日信息
                let year = firstDay.getAsFormat(format: "yyyy")
                if !holidayGotYears.contains(year){
                    requestHolidayInfo(year: Int(year)!)
                    holidayGotYears.insert(year)
                }
                
                if monthOfStart == monthOfEnd {
                    tableData.insert(CellData(id: id, type: .Week, content: CalendarCellContent.weekDesc("\(monthOfStart)月\(firstDay.getAsFormat(format: "d"))日", "\(lastDay.getAsFormat(format: "d"))日", firstDay, lastDay)), at: 0)
                    
                    if !heights.keys.contains(id) {
                        heights[id] = weekCellHeight
                    }
                    
                    if firstDay.getAsFormat(format: "yyyyMMdd") == date.firstDayOfMonth().getAsFormat(format: "yyyyMMdd") {
                        tableData.insert(CellData(id: "\(id)-img", type: .MonthImage, content: CalendarCellContent.monthImage("\(monthOfStart)月", Utils.monthImageMap[Int(monthOfStart)!]!)), at: 0)
                    }
                    
                } else {
                    tableData.insert(CellData(id: "\(id)-img", type: .MonthImage, content: CalendarCellContent.monthImage("\(monthOfEnd)月", Utils.monthImageMap[Int(monthOfEnd)!]!)), at: 0)
                    tableData.insert(CellData(id: id, type: .Week, content: CalendarCellContent.weekDesc("\(monthOfStart)月\(firstDay.getAsFormat(format: "d"))日", "\(monthOfEnd)月\(lastDay.getAsFormat(format: "d"))日", firstDay, lastDay)), at: 0)
                    
                    if !heights.keys.contains(id) {
                        heights[id] = weekCellHeight
                    }
                }
                
            }
            startIndex -= number
            tableView.reloadData()
            tableView.mj_header.endRefreshing()
        }
    }
    
    @objc private func downPullRefresh() {
        loadRefresh(number: pageSize, direction: false)
    }
    
    @objc private func upPullRefresh() {
        loadRefresh(number: pageSize, direction: true)
    }
    
    // MARK: - Date Handlers
    private func requestHolidayInfo(year: Int) {
        print("Request holiday info of \(year)")
        let url = "\(holidayRequestURL)/\(year)"
        Alamofire.request(url).responseJSON(completionHandler: { response in
            if let result = response.result.value {
                let data = JSON(result)
                let holidays = data["holiday"]
                // 遍历所有节假日(见SwiftyJSON doc)
                for (_, holiday): (String, JSON) in holidays {
                    let dateString = holiday["date"].stringValue        // 放假/调休日期
                    // print(dateString)
                    let name = holiday["name"].stringValue              // 名称
                    let ifHoliday = holiday["holiday"].boolValue        // 放假还是调休
                    
                    let date = dateString.toDate(format: "yyyy-MM-dd")
                    let specialDay = ifHoliday ? Holiday(date: date, title: name) : Adjust(date: date, title: name)
                    
                    // 加入节假日事件
                    self.specialDays.append(specialDay)
                    
                    let index = date.firstDayOfWeek().getAsFormat(format: self.dateIndexFormat)
                    if !self.heights.keys.contains(index){
                        self.heights[index] = self.weekCellHeight
                    }
                    self.heights[index]! += (self.eventViewHeight + 1)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - Event handlers
    
    
    // MARK: - Core data handlers
    private func loadData() {
        var tasksDB: [TaskDB] = []
        do {
            tasksDB = try Utils.context.fetch(TaskDB.fetchRequest())
            
            for taskDB in tasksDB {
                // print("load task: \(taskDB.title!) \(taskDB.startDate!)")
                let task = Task(startDate: taskDB.startDate!, ifAllDay: taskDB.ifAllDay, timeLengthInDays: Int(taskDB.timeLengthInDays), title: taskDB.title!)
                task.colorPoint = 0
                tasks.append(task)
                if task.timeLengthInDays == 0 {
                    let index = task.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
                    if !heights.keys.contains(index) {
                        heights[index] = weekCellHeight
                    }
                    heights[index]! += (eventViewHeight + 1)
                } else {
                    for i in 0...task.timeLengthInDays {
                        let date = Date(timeInterval: Double(i*24*60*60), since: task.startDate)
                        let index = date.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
                        if !heights.keys.contains(index) {
                            heights[index] = weekCellHeight
                        }
                        heights[index]! += (eventViewHeight + 1)
                    }
                }
                
            }
            
        } catch  {
            print(error)
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        // 根据类型配置基本内容
        switch tableData[indexPath.row].type {
        case .Week:
            let pwCell = tableView.dequeueReusableCell(withIdentifier: "plainWeekCell", for: indexPath) as! PlainWeekCell
            switch tableData[indexPath.row].content {
            case .weekDesc(let start, let end, _, _):
                pwCell.dateRangeLabel.text = "\(start) - \(end)"
            default:
                fatalError("Table data type incompatible!")
            }
            cell = pwCell
        case .MonthImage:
            let miCell = tableView.dequeueReusableCell(withIdentifier: "monthImageCell", for: indexPath) as! MonthImageCell
            switch tableData[indexPath.row].content {
            case .monthImage(let title, let image):
                miCell.monthLabel.text = title
                miCell.monthImage.image = image
            default:
                fatalError("Table data type incompatible!")
            }
            cell = miCell
        }
        
        
        var viewsToAdd: [EventView] = []
        // 添加假期和调休日视图
        for event in specialDays {
            if event.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat) == tableData[indexPath.row].id {
                let eventView = generateOneView(event: event)
                viewsToAdd.append(eventView)
            }
        }
        
        // 添加任务视图
        for task in tasks {
            if task.timeLengthInDays == 0 {
                if task.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat) == tableData[indexPath.row].id {
                    let taskViews = generateTaskViews(task: task)
                    for taskView in taskViews {
                        viewsToAdd.append(taskView)
                    }
                }
            } else {
                for i in 0...task.timeLengthInDays {
                    let date = Date(timeInterval: Double(i * 24 * 60 * 60), since: task.startDate)
                    if date.firstDayOfWeek().getAsFormat(format: dateIndexFormat) == tableData[indexPath.row].id {
                        let taskViews = generateTaskViews(task: task)
                        viewsToAdd.append(taskViews[i])
                    }
                }
            }
            /*
            if task.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat) == tableData[indexPath.row].id {
                let taskViews = generateTaskViews(task: task)
                for taskView in taskViews {
                    if taskView.dateIndex!.toDate(format: dateIndexFormat).firstDayOfWeek().getAsFormat(format: dateIndexFormat) == tableData[indexPath.row].id {
                        viewsToAdd.append(taskView)
                    }
                }
            }
            */
        }

        // 排序后显示视图
        viewsToAdd.sort(by: {$0.event!.startDate < $1.event!.startDate})
        let evWidth = cell.bounds.width - 100
        // let evX = cell.bounds.minX + 10
        let evX: CGFloat = 0
        for (index, view) in viewsToAdd.enumerated() {
            var evY = cell.bounds.minY + weekCellHeight
            evY += (CGFloat(index) * (eventViewHeight + 1))
            view.frame = CGRect(x: evX, y: evY, width: evWidth, height: eventViewHeight)
            cell.addSubview(view)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        switch tableData[indexPath.row].type {
        case .Week:
            let id = tableData[indexPath.row].id
            guard let height = heights[id] else {
                fatalError("Cell height not set, id = \(id)")
            }
            res = height
        case .MonthImage:
            res = imageCellHeight
        }
        return res
    }
    

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
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

    // MARK: - Private utils
    private func showTasks() {
        print("Current tasks: ")
        for task in tasks {
            print("\(task.startDate), \(task.title)")
        }
    }
    
    // 获取任务视图, 仅限任务调用
    private func generateTaskViews(task: Task) -> [EventView] {
        var views: [EventView] = []
        if task.ifAllDay {
            // 全天任务
            let taskView = generateOneView(event: task)
            taskView.processLabel.isHidden = true
            taskView.dateTimeLabel.isHidden = true
            views.append(taskView)
        }else {
            if task.timeLengthInDays == 0 {
                // 起止时间在一天内的任务
                let taskView = generateOneView(event: task)
                taskView.processLabel.isHidden = true
                taskView.dateTimeLabel.text = "\(task.startTime!.getAsFormat(format: "HH:mm")) ~ \(task.endTime!.getAsFormat(format: "HH:mm"))"
                views.append(taskView)
            } else {
                // 跨越两天及两天以上的任务
                for i in 0...task.timeLengthInDays {
                    let taskView = generateOneView(event: task)
                    let date = Date(timeInterval: Double(i * 24 * 60 * 60), since: task.startDate)
                    taskView.dateIndex = date.getAsFormat(format: dateIndexFormat)
                    taskView.dateNumberLabel.text = date.getAsFormat(format: "d")
                    taskView.weekDayLabel.text = Utils.weekDayMap[Calendar.current.component(.weekday, from: date)]
                    
                    taskView.processLabel.isHidden = false
                    taskView.processLabel.text = "第\(i + 1)天/共\(task.timeLengthInDays + 1)天"
                    
                    if i == 0 {         // 第一天
                        taskView.dateTimeLabel.isHidden = false
                        taskView.dateTimeLabel.text = "\(task.startTime!.getAsFormat(format: "HH:mm"))开始"
                    }else if i == task.timeLengthInDays {   // 最后一天
                        taskView.dateTimeLabel.isHidden = false
                        taskView.dateTimeLabel.text = "到\(task.endTime!.getAsFormat(format: "HH:mm"))"
                    } else {
                        taskView.dateTimeLabel.isHidden = true
                    }
                    views.append(taskView)
                }
                
            }
            
        }
        return views
    }
    
    // 获取一个事件视图(节假日和调休日也会调用)
    private func generateOneView(event: Event) -> EventView {
        let eView = EventView()

        // 设置数据
        eView.dateIndex = event.startDate.getAsFormat(format: dateIndexFormat)
        eView.event = event
        
        // 标签自适应
        eView.processLabel.adjustsFontSizeToFitWidth = true
        eView.processLabel.baselineAdjustment = .alignCenters
        eView.dateTimeLabel.adjustsFontSizeToFitWidth = true
        eView.dateTimeLabel.baselineAdjustment = .alignCenters
        eView.eventTitleLabel.adjustsFontSizeToFitWidth = true
        eView.eventTitleLabel.baselineAdjustment = .alignCenters
        
        eView.dateNumberLabel.adjustsFontSizeToFitWidth = true
        eView.dateNumberLabel.baselineAdjustment = .alignCenters
        eView.weekDayLabel.adjustsFontSizeToFitWidth = true
        eView.weekDayLabel.baselineAdjustment = .alignCenters
        
        // 设置标签内容
        eView.eventTitleLabel.text = event.title
        let weekday = Utils.weekDayMap[Calendar.current.component(.weekday, from: event.startDate)]
        eView.weekDayLabel.text = weekday
        let dateNumber = event.startDate.getAsFormat(format: "d")
        eView.dateNumberLabel.text = dateNumber
        
        eView.dateNumberBackView.isHidden = true
        eView.dateNumberLabel.textColor = UIColor.black
        eView.lineView.isHidden = true
        
        // 不同类型事件的个性化设置
        switch event.type {
        case .Task:
            let task = event as! Task
            eView.infoBoardView.backgroundColor = Utils.eventColorArray[task.colorPoint!]
            // 添加手势识别器
            let gesture = UITapGestureRecognizer(target: self, action: #selector(taskViewTouched(sender:)))
            eView.addGestureRecognizer(gesture)
        case .Holiday:
            eView.infoBoardView.backgroundColor = Utils.holidayColor
            eView.dateTimeLabel.isHidden = true
            eView.processLabel.isHidden = true
        case .Adjust:
            eView.infoBoardView.backgroundColor = Utils.adjustDayColor
            eView.dateTimeLabel.isHidden = true
            eView.processLabel.isHidden = true
        case .Today:
            eView.dateNumberBackView.isHidden = false
            eView.infoBoardView.isHidden = true
            
            eView.dateNumberBackView.backgroundColor = UIColor.blue
            eView.dateNumberLabel.textColor = UIColor.white
            eView.weekDayLabel.textColor = UIColor.blue
            
            eView.dateNumberBackView.layer.cornerRadius = eView.dateNumberBackView.frame.size.width / 2
            eView.lineView.isHidden = false
            // 添加手势识别器
            let gesture = UITapGestureRecognizer(target: self, action: #selector(todayViewTouched(sender:)))
            eView.addGestureRecognizer(gesture)
        }
        
        return eView
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddTaskSegue" {
            let dest = (segue.destination) as! TaskProcessViewController
            dest.delegate = self
            dest.status = .Add
        }
    }
    
    
    // MARK: - Actions
    @IBAction func backToToday(_ sender: UIBarButtonItem) {
        tableView.scrollToRow(at: IndexPath(row: -startIndex + 3, section: 0), at: .middle, animated: true)
    }
    
    // 滑动tableView事件
    // https://stackoverflow.com/questions/32268856/how-to-know-that-tableview-started-scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = tableView.indexPathsForVisibleRows![0]
        switch tableData[indexPath.row].type{
        case .Week:
            switch tableData[indexPath.row].content {
            case .weekDesc(_, _, let start, _):
                // 设置bar button item 标题
                self.navigationItem.leftBarButtonItem?.title = start.getAsFormat(format: "yyyy年M月")
                // print(start.getAsFormat(format: "yyyy年M月"))
            default:
                fatalError("Cell data invalid!")
            }
        default:
            break
        }
        
    }
    
    // MARK: - Objc functions
    @objc private func taskViewTouched(sender: UITapGestureRecognizer) {
        let view = sender.view as! EventView
        
        guard let task = view.event as? Task else {
            fatalError("View content invalid!")
        }
        // 从storyboard加载View Controller
        // https://coderwall.com/p/cjuzng/swift-instantiate-a-view-controller-using-its-storyboard-name-in-xcode
        let taskProcessController: TaskProcessViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskProcessViewController") as! TaskProcessViewController
        
        // 传递数据
        taskProcessController.displayTask = task
        
        // 设置状态
        taskProcessController.status = .Show
        taskProcessController.delegate = self
        navigationItem.backBarButtonItem?.title = "返回"
        
        show(taskProcessController, sender: self)
        
    }
    
    @objc private func todayViewTouched(sender: UITapGestureRecognizer) {
        
    }
    
}


// MARK: - Extensions
extension CalendarTableViewController: TaskProcessDelegate {
    func addTask(task: Task) {
        tasks.append(task)
        // showTasks()
        if task.timeLengthInDays == 0 {
            let index = task.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
            if !heights.keys.contains(index) {
                heights[index] = weekCellHeight
            }
            heights[index]! += (eventViewHeight + 1)
        } else {
            for i in 0...task.timeLengthInDays {
                let date = Date(timeInterval: Double(i*24*60*60), since: task.startDate)
                let index = date.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
                if !heights.keys.contains(index) {
                    heights[index] = weekCellHeight
                }
                heights[index]! += (eventViewHeight + 1)
            }
        }
        
        tableView.reloadData()
    }
    
}
