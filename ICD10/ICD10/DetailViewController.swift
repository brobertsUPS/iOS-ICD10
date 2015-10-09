/*
//  DetailViewController.swift
//  A class to represent the medical codes (ICD10 and ICD9) and a description of the condition
//
//  Created by Brandon S Roberts on 5/28/15.
//  Copyright (c) 2015 Brandon S Roberts. All rights reserved.
*/

import UIKit

class DetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dbManager:DatabaseManager!

    var billViewController:BillViewController?     //A bill that is passed along to hold all of the codes for the final bill
    
    @IBOutlet weak var detailDescriptionLabel: UILabel! //Labels for the codes (update these when the view is loaded)
    @IBOutlet weak var ICD10Code: UILabel! 
    @IBOutlet weak var ICD9Code: UILabel!
    @IBOutlet weak var conditionDescription: UILabel!
    @IBOutlet weak var useInBillButton: UIButton!

    
    var ICD10Text:String!                               //Variables to update the labels with (set these before the view is loaded)
    var ICD9Text:String!
    var conditionDescriptionText:String!
    var titleName:String!
    var ICD10ID:Int?
    
    var extensionCodes:[(ExtensionCode:String, ExtensionDescription:String)] = []
    var visitCodeToAddICDTo:String!
    
    @IBOutlet weak var extensionPicker: UIPickerView?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.resignFirstResponder()
        dbManager = DatabaseManager()
        if ICD10Text != "" && ICD10Text != nil{
            extensionCodes = getExtensionCodes()
        }
        
        self.extensionPicker!.delegate = self
        self.extensionPicker!.dataSource = self
        
        if extensionCodes.isEmpty {
            self.extensionPicker!.removeFromSuperview()
            self.extensionPicker = nil
        }
        
        if billViewController == nil {
            
            var arr = self.view.subviews
            for var i=0; i<arr.count; i++ {
                if arr[i].isKindOfClass(UIButton) {
                    let button:UIButton = arr[i] as! UIButton
                    button.removeFromSuperview()
                }
            }
        }
        
        ICD10Code.text = self.ICD10Text
        ICD9Code.text = self.ICD9Text
        conditionDescription.text = self.conditionDescriptionText
        
        self.navigationItem.title = titleName
        self.navigationItem.leftItemsSupplementBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getExtensionCodes() -> [(ExtensionCode:String,ExtensionDescription:String)]{
        
        var extensions:[(ExtensionCode:String,ExtensionDescription:String)] = []
        dbManager.checkDatabaseFileAndOpen()
        let extensionQuery = "SELECT Extension_code, Extension_description FROM Extension WHERE ICD10_ID=\(ICD10ID!)"
        
        var statement:COpaquePointer = nil
        var prepareResult = sqlite3_prepare_v2(dbManager.db, extensionQuery, -1, &statement, nil)
        
        if sqlite3_prepare_v2(dbManager.db, extensionQuery, -1, &statement, nil) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {
                let extensionCode = sqlite3_column_text(statement, 0)
                let extensionCodeString = String.fromCString(UnsafePointer<CChar>(extensionCode))
                
                let extensionDescription = sqlite3_column_text(statement, 1)
                let extensionDescriptionString = String.fromCString(UnsafePointer<CChar>(extensionDescription))
                
                let tuple = (ExtensionCode:extensionCodeString!, ExtensionDescription:extensionDescriptionString!)
                
                extensions.append(tuple)
            }
        }
        
        sqlite3_finalize(statement)
        dbManager.closeDB()
        return extensions
    }
    
    //MARK: - Navigation
    
    @IBAction func addCodeToBill(sender: UIButton) {
        self.performSegueWithIdentifier("verifyBill", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "verifyBill" {
            
            let controller = segue.destinationViewController as! BillViewController
            
            controller.textFieldText.append(self.billViewController!.patientTextField!.text!)
            controller.textFieldText.append(self.billViewController!.patientDOBTextField!.text!)
            controller.textFieldText.append(self.billViewController!.doctorTextField!.text!)
            controller.textFieldText.append(self.billViewController!.siteTextField!.text!)
            controller.textFieldText.append(self.billViewController!.roomTextField!.text!)
            
            controller.codesForBill = self.billViewController!.codesForBill                     //update the codes with what we had before
            var codesForBill = self.billViewController!.codesForBill                            //get the codes so we can update them
            
           
            
            if let icdCodes  = codesForBill[visitCodeToAddICDTo] {
                
                var theICDCodes:[(icd10:String, icd9:String, icd10id:Int, extensionCode:String)] = icdCodes
                
                
                if extensionPicker != nil {
                    
                    let extensionRow = extensionPicker!.selectedRowInComponent(0)
                    var (extensionCode, extensionDescription) = extensionCodes[extensionRow]
                    let tuple = (icd10: ICD10Text!, icd9: ICD9Text!, icd10id: ICD10ID!, extensionCode:extensionCode)
                    theICDCodes.append(tuple)
                    
                } else {
                    let tuple = (icd10: ICD10Text!, icd9: ICD9Text!, icd10id: ICD10ID!, extensionCode:"")
                    theICDCodes.append(tuple)
                }
                
                controller.codesForBill[visitCodeToAddICDTo] = theICDCodes                             //put the new icdCodes on at the right position
            }

            controller.administeringDoctor = self.billViewController?.administeringDoctor
            controller.icd10On = self.billViewController?.icd10On
            controller.visitCodePriority = self.billViewController!.visitCodePriority
            controller.appointmentID = self.billViewController!.appointmentID
            controller.modifierCodes = self.billViewController!.modifierCodes
        }
    }
    
    //MARK: Picker Data source methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return extensionCodes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var (extensionCode, extensionDescription) = extensionCodes[row]
        return extensionCode + " " + extensionDescription
    }
}