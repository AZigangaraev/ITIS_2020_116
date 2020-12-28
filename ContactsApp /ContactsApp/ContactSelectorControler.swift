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
    var relationshipType: RelationshipType?
    
    enum RelationshipType {
        case child
        case parent
        case friends
    }
    
    private var allContacts: [Contact] = []
    private var selectedContacts: [Contact] = []
    private var selectedContact: Contact? = nil
    
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        loadContacts()
        tableView.reloadData()
    }

    private func loadContacts() {
        guard let contact = mainContact,
              let relationshipType = relationshipType else {
            return
        }

        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@", contact)
        do {
            allContacts = try AppDelegate.shared.coreDataStack.viewContext.fetch(fetchRequest)

        } catch {
            print("Could not fetch contacts: \(error)")
        }
        
        switch relationshipType {
        case .friends:
            selectedContacts = mainContact?.friends?.allObjects as? [Contact] ?? []
        case .parent:
            selectedContact = mainContact?.parent
        case .child:
            selectedContact = mainContact?.child
        }
    }

    @objc private func saveTap() {
        guard let contact = mainContact,
              let relationshipType = relationshipType else { return }
        
        switch relationshipType {
        case .friends:
            contact.friends = NSSet(array: selectedContacts)
        case .child:
            contact.child = selectedContact
        case .parent:
            contact.parent = selectedContact
        }
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
        
        switch relationshipType {
        case .child, .parent:
            cell.accessoryType = selectedContact == contact ? .checkmark : .none
        case .friends:
            cell.accessoryType = selectedContacts.contains(contact) ? .checkmark : .none
        case .none:
            break
        }
        
        cell.textLabel?.text = contact.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = allContacts[indexPath.row]
        
        switch relationshipType {
        case .child, .parent:
            if selectedContact?.isEqual(contact) == true {
                selectedContact = nil
            } else {
                selectedContact = contact
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        case .friends:
            if let index = selectedContacts.firstIndex(of: contact) {
                selectedContacts.remove(at: index)
            } else {
                selectedContacts.append(contact)
            }
            tableView.reloadRows(at: [ indexPath ], with: .automatic)
        case .none:
            break
        }
    }
}
