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

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var discoveryEnabledSwitch: UISwitch!
    @IBOutlet weak var maximumDistanceSlider: UISlider!
    @IBOutlet weak var teachOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var learnFromOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var configureTopicsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var maximumDistanceLabel: UILabel!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var imageViewCell: UITableViewCell!
    
    var currentPicture : Data?
    
    var loggedInUserId : String?
    var datasource : FinderDatasource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.setBorder(width: 1, color: UIColor.gray)
        imageView.setRound(cornerRadius: 40)
        
        datasource = FinderDatasource(currentUserId: loggedInUserId!)
        populateScreenWithEmptyValues()
        loadSettingsData()
    }
    
    
    func populateScreenWithEmptyValues(){
        nameTextfield.text = ""
        aboutTextView.text = ""
        discoveryEnabledSwitch.isOn = true
        maximumDistanceSlider.value = 15
        teachOtherPeopleCell.accessoryType = .none
        learnFromOtherPeopleCell.accessoryType = .checkmark
        didChangeMaximumDistance(maximumDistanceSlider)
    }
    
    func populateScreenWithUser(_ user : TMUser){
        nameTextfield.text = user.fullname
        aboutTextView.text = user.about
        discoveryEnabledSwitch.isOn = user.discoveryEnabled
        maximumDistanceSlider.value = Float(user.maximumDistance)
        if user.mode == .Teach {
            teachOtherPeopleCell.accessoryType = .checkmark
            learnFromOtherPeopleCell.accessoryType = .none
        } else {
            teachOtherPeopleCell.accessoryType = .none
            learnFromOtherPeopleCell.accessoryType = .checkmark
        }
        didChangeMaximumDistance(maximumDistanceSlider)
        
        self.currentPicture = nil
        self.imageView.image = #imageLiteral(resourceName: "match-placeholder")
        
        if let url = user.image {
            datasource?.downloadPicture(url: url, completionBlock: { (data, error) in
                
                self.currentPicture = data
                if data != nil {
                    self.imageView.image = UIImage(data: data!)
                }
            })
        }
        
        
    }
    
    func loadSettingsData(){
        
        datasource?.loadUserDetails({ (user, error) in
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    func validateScreen() -> Bool {
    
        if nameTextfield!.text!.characters.count <= 3 {
            showErrorMessage("Field name is mandatory")
            return false
        }
        
        if aboutTextView!.text!.characters.count <= 3 {
            showErrorMessage("Field about is mandatory")
            return false
        }
        
        return true
    }
    
    func createUserUpdate(imageUrl : String?) -> TMUser{
        
        let mode = teachOtherPeopleCell.accessoryType == .checkmark ? TMUser.Mode.Teach : TMUser.Mode.Learn
        
        return TMUser(uid: loggedInUserId!,
                      fullname: nameTextfield!.text!,
                      about: aboutTextView!.text!,
                      mode: mode,
                      maximumDistance: Int(maximumDistanceSlider.value),
                      discoveryEnabled: discoveryEnabledSwitch.isOn,
                      latitude: nil, longitude: nil, image: imageUrl)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == teachOtherPeopleCell {
            teachOtherPeopleCell.accessoryType = .checkmark
            learnFromOtherPeopleCell.accessoryType = .none
        } else if cell == learnFromOtherPeopleCell {
            teachOtherPeopleCell.accessoryType = .none
            learnFromOtherPeopleCell.accessoryType = .checkmark
        }
        else if cell == configureTopicsCell {
            showErrorNotImplemented()
        } else if cell == logoutCell {
            self.navigationController?.popToRootViewController(animated: true)
        } else if cell == imageViewCell {
            askGalleryOrCamera()
        }
    }
    
    @IBAction func didChangeMaximumDistance(_ sender: Any) {
        maximumDistanceLabel.text =  "\(Int(maximumDistanceSlider.value)) km"
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
        return UIImageJPEGRepresentation(image, 0.8)
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
    
}

extension SettingsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = resizeImage(image: image, targetSize: CGSize(width: 600, height: 600))
        currentPicture = getImageData(image: image)
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

}
