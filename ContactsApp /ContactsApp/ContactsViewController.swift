//
//  ViewController.swift
//  ContactsApp
//
//  Created by Teacher on 21.12.2020.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet private var tableView: UITableView!

    @IBAction private func addTap() {
        guard let storyboard = storyboard else { return }

        let controller: ContactController = storyboard.instantiateViewController(identifier: "ContactController")
        controller.close = {
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    let fetchedResultsController: NSFetchedResultsController<Contact> = NSFetchedResultsController(
        fetchRequest: Contact.fetchRequest(),
        managedObjectContext: AppDelegate.shared.coreDataStack.viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    private let cellIdentifier = "Cell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        let contact = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = contact.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let storyboard = storyboard else { return }

        let controller: ContactController = storyboard.instantiateViewController(identifier: "ContactController")
        controller.close = {
            self.navigationController?.popViewController(animated: true)
        }
        controller.contact = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = fetchedResultsController.object(at: indexPath)
            let context = fetchedResultsController.managedObjectContext
            context.delete(contact)
        }
    }
}

