//
//  ViewController.swift
//  SocketTest
//
//  Created by fsociety.1 on 12/25/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit
import SocketIO
import MessageKit
import MessageInputBar

struct Member {
    let name: String
    let image: UIImage?
}

struct Message {
    let member: Member
    let text: String
    let messageId: String
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

class ChatVC: MessagesViewController {
    var username = ""
    
    var messages: [Message] = []
    var member: Member!
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost")!, config: [.log(false)])
    var socket:SocketIOClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        self.view.addGestureRecognizer(tap)
        self.socket = manager.defaultSocket;
        addHandlers()
        self.socket.connect()
        
        member = Member(name: username, image: UIImage(named: "me"))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    @objc func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        view.endEditing(true)
    }
 
    
    func addHandlers() {
        self.socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        self.socket.on("chat message") {data, ack in
            if let value = data.first as? [[String: Any]] {
                self.messages.removeAll()
                for i in value {
                    if let name = i["username"] as? String, let message = i["message"] as? String {
                        var otherMember = Member(name: name, image: UIImage(named: "otherUser"))
                        if name == self.username {
                            otherMember = Member(name: name, image: UIImage(named: "me"))
                        }
                        let newMessage = Message(
                            member: otherMember,
                            text: message,
                            messageId: UUID().uuidString)
                        
                        self.messages.append(newMessage)
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom(animated: false)
                    }
                }
            }
        }

    }
}


extension ChatVC: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}



extension ChatVC: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension ChatVC: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let image = message.member.image
        avatarView.image = image
    }
}

extension ChatVC: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        self.socket.emit("chat message", with: [["username": username, "message": text]])
        inputBar.inputTextView.text = ""
    }
}
