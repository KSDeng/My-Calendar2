//
//  InvitationViewController.swift
//  MyCalendar
//
//  Created by DKS_mac on 2019/12/5.
//  Copyright © 2019 dks. All rights reserved.
//

// https://stackoverflow.com/questions/20523874/uitableviewcontroller-inside-a-uiviewcontroller
// https://stackoverflow.com/questions/34348275/pass-data-between-viewcontroller-and-containerviewcontroller

// MARK: TODOs
// 1. 从通讯录读取联系人信息
// 2. 联系人包含称呼、联系方式
// 3. 每个联系人添加一张图

import UIKit

// MARK: - Protocols
protocol AddInvitationDelegate {
    func addInvitation(inv: Invitation)
}
protocol DeleteInvitationSecondDelegate {
    func deleteInvitation(index: Int, inv: Invitation)
}
class InvitationViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var invitationPhoneNumberTextField: UITextField!
    
    // MARK: - Variables
    var addDelegate: AddInvitationDelegate?
    var deleteDelegate: DeleteInvitationSecondDelegate?
    
    var currentInvitations: [Invitation] = []
    
    var invitationTable: InvitationTableViewController?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        invitationPhoneNumberTextField.becomeFirstResponder()
        invitationPhoneNumberTextField.clearButtonMode = .whileEditing
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func addButtonClicked(_ sender: UIButton) {
        if let phone = invitationPhoneNumberTextField.text {
            /*
            let inv = Invitation(phoneNumber: phone, editTime: Date())
            addDelegate?.addInvitation(inv: inv)
            if let invitationTable = invitationTable {
                invitationTable.addInvitation(invitation: inv)
                invitationPhoneNumberTextField.text = ""
            }
 */
        }
        
    }
    
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
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
            for inv in currentInvitations {
                invitationTable?.addInvitation(invitation: inv)
            }
        }
    }
}

extension InvitationViewController: DeleteInvitationDelegate {
    func deleteInvitation(index: Int, inv: Invitation) {
        deleteDelegate?.deleteInvitation(index: index, inv: inv)
    }
}
