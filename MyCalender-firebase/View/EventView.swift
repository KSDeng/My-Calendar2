

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
    
    var event: Event?
    var dateIndex: String?
    
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



