//
//  EditPatientViewController.swift
//  ICD10
//
//  Created by Brandon S Roberts on 6/10/15.
//  Copyright (c) 2015 Brandon S Roberts. All rights reserved.
//

import UIKit

class EditPatientViewController: UIViewController {
    
    var database:COpaquePointer = nil
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var firstName:String = ""
    var lastName:String = ""
    var dob:String = ""
    var email:String = ""
    var id:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        var dbManager = DatabaseManager()
        database = dbManager.checkDatabaseFileAndOpen()
        
        firstNameField.text = firstName
        lastNameField.text = lastName
        dobField.text = dob
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savePatientInfo(sender: UIButton) {
        //save all info to the database
        let query = "UPDATE Patient SET date_of_birth= '\(dobField.text)', f_name='\(firstNameField.text)', l_name='\(lastNameField.text)' WHERE pID='\(id)';"
        var statement:COpaquePointer = nil
        println("Selected")
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
            //popup saying it worked
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /**
    *   Registers clicking return and resigns the keyboard
    **/
    @IBAction func textFieldDoneEditing(sender:UITextField){
        sender.resignFirstResponder()
    }
    
    /**
    *   Registers clicking the background and resigns any responder that could possibly be up
    **/
    @IBAction func backgroundTap(sender: UIControl){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}