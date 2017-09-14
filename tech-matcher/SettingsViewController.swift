//
//  SettingsViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SettingsViewController: UITableViewController{

    // MARK: UI
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var imageViewCell: UITableViewCell!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    // MARK: Data
    var currentPicture : Data?
    var loggedInUserId : String?
    var datasource : TMDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.setBorder(width: 1, color: UIColor.gray)
        imageView.setRound(cornerRadius: 50)
        
        datasource = TMDatasource(currentUserId: loggedInUserId!)
        populateScreenWithEmptyValues()
        loadSettingsData()
    }
    
    
    
    
}

// MARK: - Table
extension SettingsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == logoutCell {
            logout()
            
        } else if cell == imageViewCell {
            DispatchQueue.main.async {
                self.askGalleryOrCamera()
            }
        }
    }
}

// MARK: Events

extension SettingsViewController {
    

}

// MARK: Actions

extension SettingsViewController {
    
    @IBAction func didClickOnBackButton(_ sender : Any){
        saveSettings()
        self.navigationController?.popViewController(animated: true)
    }
    
    func logout(){
        self.navigationController?.popToRootViewController(animated: true)
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func askGalleryOrCamera(){
        let alert = UIAlertController(title: "Option", message: "Pictures from", preferredStyle: .alert)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.openPicker(camera: true)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
                self.openPicker(camera: false)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func openPicker(camera : Bool){
        let picker = UIImagePickerController()
        picker.sourceType = camera ? .camera : .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func getImageData(image : UIImage) -> Data? {
        return UIImageJPEGRepresentation(image, Constants.JPEGCompression)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func createUserUpdate(imageUrl : String?) -> TMUser{
        
        return TMUser(userId: loggedInUserId!,
                      fullname: nameTextfield!.text!,
                      about: aboutTextView!.text!,
                      image: imageUrl)
    }
    
    func saveSettings(){
        
        if !validateScreen(){
            return
        }
        
        if let currentPicture = self.currentPicture {
            self.datasource?.savePicture(currentPicture, completionBlock: { (imageUrl, error) in
                guard error == nil else {
                    self.showErrorMessage(error!)
                    return
                }
                
                let user = self.createUserUpdate(imageUrl: imageUrl)
                
                self.datasource?.updateUserSettings(user, completionBlock: { (success, errorMessage) in
                    guard errorMessage == nil else {
                        self.showErrorMessage(errorMessage!)
                        return
                    }
                })
                
            })
        } else {
            let user = createUserUpdate(imageUrl : nil)
            
            datasource?.updateUserSettings(user, completionBlock: { (success, errorMessage) in
                guard errorMessage == nil else {
                    self.showErrorMessage(errorMessage!)
                    return
                }
            })
        }
    }
    
    func populateScreenWithEmptyValues(){
        nameTextfield.text = ""
        aboutTextView.text = ""
        imageView.image = #imageLiteral(resourceName: "match-placeholder")
    }
    
    func populateScreenWithUser(_ user : TMUser){
        nameTextfield.text = user.fullname
        aboutTextView.text = user.about
        self.currentPicture = nil
        self.imageView.image = #imageLiteral(resourceName: "match-placeholder")
        
        if let url = user.image {
            self.datasource?.downloadPicture(url: url, completionBlock: { (data, error) in
                
                self.currentPicture = data
                if let data = data {
                    if let pic = UIImage(data: data) {
                        self.imageView.image = pic
                    }
                }
            })
        }
    }
    
    func loadSettingsData(){
        
        showProgressWithMessage(message: "Retrieving user details")
        
        datasource?.loadUserDetails({ (user, error) in
            
            self.dismissProgress()
            
            guard error == nil else {
                self.showErrorMessage(error!)
                self.showErrorMessage("This is your first use of the app, please fill all fields.")
                return
            }
            
            guard let user = user else {
                self.showErrorMessage("Invalid user")
                self.showErrorMessage("This is your first use of the app, please fill all fields.")
                return
            }
            
            self.populateScreenWithUser(user)
        })
    }
    
    func validateScreen() -> Bool {
        
        if nameTextfield!.text!.characters.count <= Constants.MinimumTextFieldCharacters {
            showErrorMessage("Field name is mandatory")
            return false
        }
        
        if aboutTextView!.text!.characters.count <= Constants.MinimumTextFieldCharacters {
            showErrorMessage("Field about is mandatory")
            return false
        }
        
        return true
    }
}


// MARK: - Image Picker

extension SettingsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = resizeImage(image: image, targetSize: CGSize(width: Constants.ImageSize, height: Constants.ImageSize))
        currentPicture = getImageData(image: image)
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

}
