//
//  AddPhotoViewController.swift
//  ShareApp
//
//  Created by iOSpro on 13/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class AddPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var lb_AlbumTitle: UILabel!
    @IBOutlet weak var lb_AlbumID: UILabel!
    @IBOutlet weak var lb_AlbumPIN: UILabel!
    
    @IBOutlet weak var cv_photos: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cv_photos.delegate = self
        cv_photos.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        PhotoUrlList = [String]()
        SVProgressHUD.show()
        mFirebaseDB.child(albumID1).observeSingleEvent(of: .value, with: { (favourites) in
            SVProgressHUD.dismiss()
            if let result = favourites.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let url = (child.value as? [String:AnyObject])?["url"] as! String
                    PhotoUrlList.append(url)
                }
                photoCount = PhotoUrlList.count
                self.cv_photos.reloadData()
            } else {
                print("no results")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_backClicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func imporFromPhotoLibrary(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: false, completion: nil)
        
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (String(describing: info[UIImagePickerControllerMediaType]) == "Optional(public.movie)") {
            
        }else{
            
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            picker.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
            var data = NSData()
            data = UIImageJPEGRepresentation(image!, 0.8)! as NSData
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            mFirebaseStorage.child(albumID1).child(UUID().uuidString).putData(data as Data, metadata: metaData){(metaData,error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    //store downloadURL at database
                    let dict = ["url" : downloadURL] as [String : Any]
                    if isReplacing{
                        mFirebaseDB.child(albumID1).child("photo" + String(selectedIndex)).setValue(dict)
                        PhotoUrlList[selectedIndex] = downloadURL
                    }
                    else{
                        mFirebaseDB.child(albumID1).child("photo" + String(photoCount)).setValue(dict)
                        if (PhotoUrlList.count == 10){
                            
                        }
                        else{
                            PhotoUrlList.append(downloadURL);
                            photoCount += 1
                        }
                    }
                    
                    self.cv_photos.reloadData()
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
//MARK: - UICollectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoCollectionViewCell = cv_photos.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if (indexPath.row != 0){
            cell.img_photoAdd.sd_setImage(with: URL(string: ""))
        }
        else{
            cell.img_photoAdd.image = UIImage(named: "btn_add")
        }
        if (indexPath.row < PhotoUrlList.count){
            cell.img_photoCell.sd_setImage(with: URL(string: PhotoUrlList[indexPath.row]))
        }
        else{
            cell.img_photoCell.image = UIImage(named: "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width / 2 - 15, height: (UIScreen.main.bounds.width / 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        selectedIndex = indexPath.row
        if (indexPath.row == 0){
            isReplacing = false
            sharePhoto()
        }
        else{
            askReplace()
        }
        
    }
    
    func askReplace(){
        let bounds = UIScreen.main.bounds
        
        let testFrame : CGRect = CGRect(x:bounds.width / 2 , y: bounds.height , width:120, height:100)
        let testView : UIView = UIView(frame: testFrame)
        testView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.view.addSubview(testView)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.popoverPresentationController?.sourceView = testView
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            isReplacing = false
            PhotoUrlList.remove(at: selectedIndex)
            photoCount -= 1
            if (photoCount == selectedIndex){
                mFirebaseDB.child(albumID1).child("photo" + String(photoCount)).removeValue()
                self.cv_photos.reloadData()
            }
            else{
                SVProgressHUD.show()
                for index in selectedIndex ..< photoCount{
                    let dict = ["url" : PhotoUrlList[index]] as [String : Any]
                    mFirebaseDB.child(albumID1).child("photo" + String(index)).setValue(dict){ (error, ref) -> Void in
                        if (index == photoCount - 1){
                            SVProgressHUD.dismiss()
                            mFirebaseDB.child(albumID1).child("photo" + String(photoCount)).removeValue()
                            self.cv_photos.reloadData()
                        }
                    }
                }
            }
        }
        
        let replaceAction = UIAlertAction(title: "Replace", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            isReplacing = true
            self.sharePhoto()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(replaceAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sharePhoto(){
        let bounds = UIScreen.main.bounds
        
        let testFrame : CGRect = CGRect(x:bounds.width / 2 , y: bounds.height , width:120, height:100)
        let testView : UIView = UIView(frame: testFrame)
        testView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.view.addSubview(testView)
        
        let attributedString = NSAttributedString(string: "Share", attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 22), //your font here
            NSAttributedStringKey.foregroundColor : UIColor.black
            ])
        
        let alertController = UIAlertController(title: "Share", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.popoverPresentationController?.sourceView = testView
        alertController.setValue(attributedString, forKey: "attributedTitle")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let cameraAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            print("Photo Library")
            self.imporFromPhotoLibrary()
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
