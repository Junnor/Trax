//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Junor on 4/3/16.
//  Copyright © 2016 Junor. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    var waypointToEdit: EditabelWaypoint? { didSet { updateUI() } }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
    }
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startObservingTextFields()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingTextFields()
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserser: NSObjectProtocol?

    private func startObservingTextFields() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue) { (notification) in
            if let waypoint = self.waypointToEdit {
                waypoint.name = self.nameTextField?.text
            }
        }
        itfObserser = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue)
            { (notification) in
            if let waypoint = self.waypointToEdit {
                waypoint.info = self.infoTextField?.text
            }
        }
    }
    
    private func stopObservingTextFields() {
        if let observer = ntfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserser {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
