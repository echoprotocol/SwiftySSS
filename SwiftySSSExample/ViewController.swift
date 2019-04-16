//
//  ViewController.swift
//  SSSTest
//
//  Created by Fedorenko Nikita on 4/15/19.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import UIKit
import SwiftySSS

class ViewController: UIViewController {
    
    @IBOutlet weak var numberOfSharesTextField: UITextField!
    @IBOutlet weak var thresholdTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var sharesTextView: UITextView!
    @IBOutlet weak var decodedSecretTextField: UITextField!
    
    let numberSharesData: [String] = (0...20).map { String($0) }
    let thresholdData: [String] = (0...20).map { String($0) }
    let defaultNumberOfShares = "5"
    let defaultNumberOfthreshold = "3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        configNumberOfSharesTextField()
        configthresholdTextField()
    }
    
    private func configNumberOfSharesTextField() {
        let picker = UIPickerView()
        picker.delegate = self
        numberOfSharesTextField.text = defaultNumberOfShares
        numberOfSharesTextField.inputView = picker
    }
    
    private func configthresholdTextField() {
        let picker = UIPickerView()
        picker.delegate = self
        thresholdTextField.text = defaultNumberOfthreshold
        thresholdTextField.inputView = picker
    }
    
    
    @IBAction func actionEncode(_ sender: Any) {
        guard let secret = secretTextField.text, secret.count > 0 else {
            return
        }
        
        guard let threshold = Int(thresholdTextField.text ?? "") else {
            return
        }
        
        guard let numberOfShares = Int(numberOfSharesTextField.text ?? "") else {
            return
        }
        
        let secretData = Data([UInt8](secret.utf8))
        
        do {
            let secret = try Secret(data: secretData, threshold: threshold, shares: numberOfShares)
            let shares = try secret.split()
            var allShares = ""
            shares.forEach { (share) in
                allShares.append("\(share.description)\n")
            }
            sharesTextView.text = allShares
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    @IBAction func actionDecode(_ sender: Any) {
        
        guard let sharesText = sharesTextView.text, sharesText.count > 0 else {
            return
        }
        
        let sharesStrings = sharesText.components(separatedBy: "\n")
        var shares = [Secret.Share]()
        
        sharesStrings.forEach { (stringShare) in
            if let share = try? Secret.Share(string: stringShare) {
                shares.append(share)
            }
        }
        
        do {
            
            let secretData = try Secret.combine(shares: shares)
            let secret = String(data: secretData, encoding: .utf8)
            decodedSecretTextField.text = secret
            
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    @IBAction func actionClear(_ sender: Any) {
        thresholdTextField.text = defaultNumberOfthreshold
        numberOfSharesTextField.text = defaultNumberOfShares
        secretTextField.text = ""
        sharesTextView.text = ""
        decodedSecretTextField.text = ""
        view.endEditing(true)
    }
    
    @IBAction func actionVoidTap(_ sender: Any) {
        view.endEditing(true)
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == numberOfSharesTextField.inputView {
            return numberSharesData.count
        } else if pickerView == thresholdTextField.inputView {
            return thresholdData.count
        } else {
            return 0
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == numberOfSharesTextField.inputView {
            return numberSharesData[row]
        } else if pickerView == thresholdTextField.inputView {
            return thresholdData[row]
        } else {
            return ""
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == numberOfSharesTextField.inputView {
            numberOfSharesTextField.text = numberSharesData[row]
        } else if pickerView == thresholdTextField.inputView {
            thresholdTextField.text = thresholdData[row]
        }
    }
}

