//
//  ViewController.swift
//  Flash Chat
//
//  Created by Sarannya Yu on 31/03/19.
//  Copyright (c) 2019 Sarannya. All rights reserved.
//

import UIKit
import Firebase


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    var keyboardHeight : CGFloat = 0
    var messageArray : [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self

        
        //TODO: Set the tapGesture here:
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        
        //TODO: notifications calculate keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        messageTableView.separatorStyle = .none
        retrieveMessages()
    }
    

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == (Auth.auth().currentUser?.email){
            cell.messageBackground.backgroundColor = UIColor.init(red: 0.6, green: 0.4, blue: 0.7, alpha: 1)
            cell.avatarImageView.backgroundColor = UIColor.init(red: 0.6, green: 0.7, blue: 0.9, alpha: 1)
        }
        else{
            cell.messageBackground.backgroundColor = UIColor.init(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
            cell.avatarImageView.backgroundColor = UIColor.init(red: 0.2, green: 0.6, blue: 0.4, alpha: 1)
        }
        return cell
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
        self.heightConstraint.constant = 288 + self.heightConstraint.constant + 34
           self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: add the listeners for keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            keyboardHeight = keyboardSize.height

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
//        messageTextfield.endEditing(true)
        let myAppDB = Database.database().reference().child("MyAppMessages")
        
        let messages = ["Sender" : Auth.auth().currentUser?.email,
                        "Message" : messageTextfield.text]
        
        myAppDB.childByAutoId().setValue(messages) { (error, reference) in
            
            if error != nil {
                
            }else{
                print("message saved")
                self.messageTextfield.text = ""

            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    
    func retrieveMessages(){
        
        let messageBD = Database.database().reference().child("MyAppMessages")
        
        messageBD.observe(.childAdded) { (snapshot) in
            let thisMessage =  snapshot.value as! Dictionary<String,String>
            print(thisMessage)
            
            let message = Message()
            message.sender = thisMessage["Sender"]!
            message.messageBody = thisMessage["Message"]!
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)

        } catch  {
            print("Error logging out")
        }
    
    }
    


}
