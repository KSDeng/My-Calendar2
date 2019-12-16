//
//  CustomizeNotificationController.swift
//  MyCalendar
//
//  Created by DKS_mac on 2019/12/9.
//  Copyright © 2019 dks. All rights reserved.
//

// References:
// 1. https://www.journaldev.com/22743/custom-ios-uipickerview
// 2. https://stackoverflow.com/questions/27642164/how-to-use-two-uipickerviews-in-one-view-controller

import UIKit

enum NotiRangeStatus: Int {
    case Minute = 0, Hour, Day, Week
}

protocol CustomNotificationDelegate {
    func setNotificationPara(secondsFromNow: Int, sentence: String, range: String, number: Int)
}

class CustomizeNotificationController: UIViewController {

    
    @IBOutlet weak var currentSettingLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBOutlet weak var rangePicker: UIPickerView!
    
    var numberRange: [[Int]] = [
        Array(0...60),              // 分钟设置范围
        Array(0...24),              // 小时设置范围
        Array(0...28),              // 天设置范围
        Array(0...4)                // 周设置范围
    ]
    // 时间选择器数据源
    var numberPickerDataSource: [Int] = Array(1...60)
    // 时间范围数据源
    var rangePickerDataSource = ["分钟","小时","天","周"]
    
    // 每个时间范围单位转换成秒
    var units = [60, 60*60, 24*60*60, 7*24*60*60]
    
    // 当前状态(表示时间范围)
    var currentStatus = NotiRangeStatus.Minute {
        willSet {
            numberPickerDataSource = numberRange[newValue.rawValue]
            numberPicker.reloadAllComponents()            // 更换数据源后重新加载picker
        }
    }
    
    var delegate: CustomNotificationDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPickers()
    }
    

    private func setupPickers(){
        numberPicker.delegate = self
        numberPicker.delegate?.pickerView?(numberPicker, didSelectRow: 0, inComponent: 0)
        
        numberPickerDataSource = numberRange[currentStatus.rawValue]
        rangePicker.delegate = self
        rangePicker.delegate?.pickerView?(rangePicker, didSelectRow: 0, inComponent: 0)
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func finishButtonClicked(_ sender: UIButton) {
        let number = numberPickerDataSource[numberPicker.selectedRow(inComponent: 0)]
        let seconds = units[currentStatus.rawValue] * number
        let range = rangePickerDataSource[currentStatus.rawValue]
        
        delegate?.setNotificationPara(secondsFromNow: seconds, sentence: currentSettingLabel.text!, range: range, number: number)
        print("Set notification \(seconds) seconds from task start time. Range = \(range), number = \(number)")
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CustomizeNotificationController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return numberPickerDataSource.count
        } else if pickerView.tag == 1 {
            return rangePickerDataSource.count
        } else {
            fatalError("Unknown picker!")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return "\(numberPickerDataSource[row])"
        } else if pickerView.tag == 1 {
            return rangePickerDataSource[row]
        } else {
            fatalError("Unknown picker!")
        }
        
    }
    // 每一列的宽度(component为1列)
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    // 一列中每一行的高度
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    // 选中某一行时进行的动作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var numberSelectedIndex = numberPicker.selectedRow(inComponent: 0)
        if pickerView.tag == 0 {
            
        } else if pickerView.tag == 1 {
            let getStatus = NotiRangeStatus(rawValue: row)
            guard let status = getStatus else {
                fatalError("Unknown status!")
            }
            currentStatus = status
            
            if numberSelectedIndex >= numberPickerDataSource.count - 1 {
                numberSelectedIndex = numberPickerDataSource.count - 1
            }
            
        } else {
            fatalError("Unknown picker!")
        }
        
        let currentNumber = numberPickerDataSource[numberSelectedIndex]
        let currentRange = rangePickerDataSource[rangePicker.selectedRow(inComponent: 0)]
        currentSettingLabel.text = "提前\(currentNumber)\(currentRange)提醒"
    }
    
    
}
