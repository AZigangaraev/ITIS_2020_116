//
//  ContactController.swift
//  ContactsApp
//
//  Created by Teacher on 21.12.2020.
//

import UIKit

class ContactController: UIViewController {
    var contact: Contact?
    var close: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let contact = contact {
            setup(contact: contact)
        }
    }

    private func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
    }

    private func setup(contact: Contact) {
        nameField.text = contact.name
        phoneField.text = contact.phoneNumber
        childLabel.text = "Child: \(contact.child?.name ?? "None")"
        parentLabel.text = "Parent: \(contact.parent?.name ?? "None")"
        friendsLabel.text = "Friends: \(contact.friends?.count ?? 0)"
    }

    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var phoneField: UITextField!
    @IBOutlet private var childLabel: UILabel!
    @IBOutlet private var parentLabel: UILabel!
    @IBOutlet private var friendsLabel: UILabel!

    private func getOrCreateContact() -> Contact {
        if let contact = contact {
            return contact
        } else {
            let contact = Contact(entity: Contact.entity(), insertInto: AppDelegate.shared.coreDataStack.viewContext)
            self.contact = contact
            return contact
        }
    }

    @objc private func saveTap() {
        let contact = getOrCreateContact()
        contact.name = nameField.text
        contact.phoneNumber = phoneField.text
        AppDelegate.shared.coreDataStack.saveViewContext()
        close?()
    }

    @IBAction private func editChildTap() {
    }

    @IBAction private func editParentTap() {
    }

    @IBAction private func deleteChildTap() {
    }

    @IBAction private func deleteParentTap() {
    }

    @IBAction private func editFriendsTap() {
        guard let storyboard = storyboard else { return }

        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        controller.mainContact = getOrCreateContact()
        controller.close = {
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}
