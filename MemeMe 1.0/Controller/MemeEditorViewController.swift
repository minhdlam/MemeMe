//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Duc Lam on 3/20/22.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - IBActions
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(activityViewController, animated: true)
        activityViewController.completionWithItemsHandler = { (activity, completed, items, errors) in
            if completed {
                self.save()
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {

    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        selectImageFromOrPhtoo(sourceType: .camera)
    }
    
    @IBAction func albumButtonPressed(_ sender: Any) {
        selectImageFromOrPhtoo(sourceType: .photoLibrary)
    }
    
    // MARK: - Selector Methods
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextfield.isEditing {
            view.frame.origin.y = -getKeyBoardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // MARK: - Helper Methods
    
    func configureUI() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        
        setupTextField(textField: topTextField, text: "TOP")
        setupTextField(textField: bottomTextfield, text: "BOTTOM")
    }
    
    func setupTextField(textField: UITextField, text: String) {
        textField.defaultTextAttributes = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4.0
        ]
        
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.textAlignment = .center
        textField.text = text
        textField.delegate = self
    }
    
    func getKeyBoardHeight(_ notification: Notification) -> CGFloat {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
        return keyboardSize.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func generateMemedImage() -> UIImage {
        shouldHideViews(temporary: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        guard let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        
        shouldHideViews(temporary: false)
        
        return memedImage
    }
    
    func shouldHideViews(temporary: Bool ) {
        navBar.isHidden = temporary
        toolBar.isHidden = temporary
    }
    
    func save() {
        if let topText = self.topTextField.text,
           let bottomText = self.bottomTextfield.text,
           let selectedImage = self.selectedImage
        {
            let _ = Meme(topText: topText, bottomText: bottomText, originalImage: selectedImage, memedImage: generateMemedImage())
        }
    }
    
    func selectImageFromOrPhtoo(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerController Delegate Methods

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationBarDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            memeImageView.image = image
            shareButton.isEnabled = true
            dismiss(animated: true)
        }
    }
}

// MARK: - UITextField Delegate Methods

extension MemeEditorViewController: UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
