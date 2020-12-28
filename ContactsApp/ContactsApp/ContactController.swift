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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        view.subviews
            .compactMap { $0 as? UIStackView }
            .flatMap(\.arrangedSubviews)
            .compactMap { $0 as? UIStackView }
            .forEach { $0.spacing = 8 }
    }

    private func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
    }

    private func setup(contact: Contact) {
        nameField.text = contact.name
        phoneField.text = contact.phoneNumber
        childLabel.text = "Child: \(contact.child?.name ?? "No child")"
        parentLabel.text = "Parent: \(contact.parent?.name ?? "No parent")"
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
        let controller = getControllerFromStoryboard() as! ContactSelectorController
        controller.mainContact = getOrCreateContact()
        controller.isSingleSelect = true
        if let child = getOrCreateContact().child {
            controller.setSelectedContacts([child])
        }
        // controller.isFromChild = true
        controller.close = { [weak self] selectedContacts in
            self?.getOrCreateContact().child = selectedContacts.first
            selectedContacts.first?.parent = self?.getOrCreateContact()
            
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func editParentTap() {
        let controller = getControllerFromStoryboard() as! ContactSelectorController
        controller.mainContact = getOrCreateContact()
        controller.isSingleSelect = true
        if let parent = getOrCreateContact().parent {
            controller.setSelectedContacts([parent])
        }
        // controller.isFromParent = true
        controller.close = { [weak self] selectedContacts in
            self?.getOrCreateContact().parent = selectedContacts.first
            selectedContacts.first?.child = self?.getOrCreateContact()
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func deleteChildTap() {
        getOrCreateContact().child?.parent = nil
        getOrCreateContact().child = nil
        setup(contact: getOrCreateContact())
    }

    @IBAction private func deleteParentTap() {
        getOrCreateContact().parent?.child = nil
        getOrCreateContact().parent = nil
        setup(contact: getOrCreateContact())
    }

    @IBAction private func editFriendsTap() {
        guard let storyboard = storyboard else { return }

        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        controller.mainContact = getOrCreateContact()
        controller.setSelectedContacts(getOrCreateContact().friends?.allObjects as? [Contact] ?? [])
        controller.close = { [weak self] selectedContacts in
            self?.getOrCreateContact().friends = NSSet(array: selectedContacts)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getControllerFromStoryboard() -> UIViewController {
        guard let storyboard = storyboard else { return UIViewController()}
        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        return controller
    }
}
