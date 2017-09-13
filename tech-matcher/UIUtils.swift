//
//  UIUtils.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {

    func showMessage(_ message : String, title: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel , handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func showErrorMessage(_ message : String){
        showMessage(message, title: "Error")
    }
    
    func showErrorNotImplemented(){
        showErrorMessage("Not implemented")
    }
    
    func showProgressWithMessage(message : String){
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismissProgress(){
        SVProgressHUD.dismiss()
    }
}
