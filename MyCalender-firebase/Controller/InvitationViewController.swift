

import UIKit

// MARK: - Protocols

protocol SetInvitationDelegate {
    func setInvitations(inv: [Invitation])
}

class InvitationViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var invitationNameTextField: UITextField!
    
    @IBOutlet weak var contactTextField: UITextField!
    
    // MARK: - Variables
    var delegate: SetInvitationDelegate?
    
    var currentInvitations: [Invitation] = []
    
    var invitationTable: InvitationTableViewController?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        invitationNameTextField.becomeFirstResponder()
        invitationNameTextField.clearButtonMode = .whileEditing
        contactTextField.clearButtonMode = .whileEditing
    }
    
    // MARK: - Actions
    @IBAction func addButtonClicked(_ sender: UIButton) {
        guard let name = invitationNameTextField.text, name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            let alert = UIAlertController(title: "请输入邀请对象称呼", message: "邀请对象称呼不能为空", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let inv = Invitation(name: name, lastEditTime: Date())
        if let contact = contactTextField.text {
            inv.contact = contact
        }
        
        // addDelegate?.addInvitation(inv: inv)
        currentInvitations.append(inv)
        invitationNameTextField.text = ""
        contactTextField.text = ""
        
        if let invitationTable = invitationTable {
            invitationTable.addInvitation(invitation: inv)
        }
        
    }
    
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        delegate?.setInvitations(inv: currentInvitations)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "invitationTableViewSegue" {
            let dest = segue.destination as! InvitationTableViewController
            invitationTable = dest
            invitationTable?.delegate = self
            dest.invitations = currentInvitations
        }
    }
}

extension InvitationViewController: DeleteInvitationDelegate {
    func deleteInvitation(index: Int, inv: Invitation) {
        currentInvitations.remove(at: index)
    }
}
