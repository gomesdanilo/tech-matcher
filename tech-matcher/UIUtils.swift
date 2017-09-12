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

    func showErrorMessage(_ message : String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel , handler: nil))
        present(alert, animated: true, completion: nil)
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
