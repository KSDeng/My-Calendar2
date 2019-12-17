

import UIKit

// https://medium.com/better-programming/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
// https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift

// 添加在每个单元格的事件视图
class EventView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var infoBoardView: UIView!
    
    @IBOutlet weak var weekDayLabel: UILabel!
    
    @IBOutlet weak var dateNumberBackView: UIView!
    
    @IBOutlet weak var dateNumberLabel: UILabel!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var processLabel: UILabel!
    
    var event: Event?       // 非Task(不持久化)使用
    var task: TaskDB?       // Task(持久化)使用
    var dateIndex: String?
    
    // 序列号(用于排序), 开始时间 + 类型 + 加入列表的时间
    // 类型(0: 今天, 1: 节假日, 2: 调休日, 3: 各种事务，包括全天事务、非全天事务或跨越多天事务的每一天)
    // 开始时间： startDate(yyyyMMdd) + startTime(HHmm)，0、1、2、3类型的startTime设为0000，跨越多天事务的中间天和最后一天的startTime也设为0000
    // 加入列表的时间：Date()(yyyyMMddHHmmss)
    // 序列号较小的排前面
    var sequenceNumber: String?
    
    // for using custom view in code
    init() {
        super.init(frame: CGRect.zero)
        fromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
    }
    
    // for using custom view in IB
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fromNib()
    }

}

// load UIView from nib file programmatically
extension UIView {
    @discardableResult   // 1
    func fromNib<T : UIView>() -> T? {   // 2
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        self.addSubview(contentView)     // 4
        // contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return contentView   // 7
    }
}



