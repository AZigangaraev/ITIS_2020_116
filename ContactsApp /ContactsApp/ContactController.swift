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
        guard let storyboard = storyboard else { return }

        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        controller.mainContact = getOrCreateContact()
        controller.relationshipType = .child
        controller.close = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func editParentTap() {
        guard let storyboard = storyboard else { return }

        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        controller.mainContact = getOrCreateContact()
        controller.relationshipType = .parent
        controller.close = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func deleteChildTap() {
        let contact = getOrCreateContact()
        contact.child = nil
        setup(contact: contact)
    }

    @IBAction private func deleteParentTap() {
        let contact = getOrCreateContact()
        contact.parent = nil
        setup(contact: contact)
    }

    @IBAction private func editFriendsTap() {
        guard let storyboard = storyboard else { return }

        let controller: ContactSelectorController = storyboard.instantiateViewController(identifier: "ContactSelectorController")
        controller.mainContact = getOrCreateContact()
        controller.relationshipType = .friends
        controller.close = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}
