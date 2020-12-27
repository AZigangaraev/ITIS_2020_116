//
//  ContactSelectorControler.swift
//  ContactsApp
//
//  Created by Teacher on 21.12.2020.
//

import UIKit
import CoreData

class ContactSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var mainContact: Contact?
    var close: (() -> Void)?

    private var allContacts: [Contact] = []
    private var selectedContacts: [Contact] = []

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        loadContacts()
    }

    private func loadContacts() {
        guard let contact = mainContact else { return }

        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@", contact)
        do {
            allContacts = try AppDelegate.shared.coreDataStack.viewContext.fetch(fetchRequest)
            selectedContacts = mainContact?.friends?.allObjects as? [Contact] ?? []
            tableView.reloadData()
        } catch {
            print("Could not fetch contacts: \(error)")
        }
    }

    @objc private func saveTap() {
        guard let contact = mainContact else { return }

        contact.friends = NSSet(array: selectedContacts)
        close?()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allContacts.count
    }

    private let cellIdentifier = "Cell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        let contact = allContacts[indexPath.row]
        if selectedContacts.contains(contact) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = contact.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let contact = allContacts[indexPath.row]
        if let index = selectedContacts.firstIndex(of: contact) {
            selectedContacts.remove(at: index)
        } else {
            selectedContacts.append(contact)
        }
        tableView.reloadRows(at: [ indexPath ], with: .automatic)
    }
}
