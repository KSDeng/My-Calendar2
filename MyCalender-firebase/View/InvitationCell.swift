
import UIKit

// MARK: TODOs
// 称呼和电话号码分开

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var messageAction : ((String) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func messageButtonClicked(_ sender: UIButton) {
        if let phoneNumber = phoneNumberLabel.text, let action = messageAction {
            action(phoneNumber)
        }else {
            print("Message not sent.")
        }
    }
    
    
    
    
    
}

