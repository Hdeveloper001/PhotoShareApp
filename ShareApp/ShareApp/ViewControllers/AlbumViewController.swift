//
//  AlbumViewController.swift
//  ShareApp
//
//  Created by iOSpro on 13/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TB_Album: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TB_Album.delegate = self
        TB_Album.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Tableview
    
    func numberOfSections(in tb_album: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tb_album: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tb_album: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tb_album: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tb_album.dequeueReusableCell(withIdentifier: "AlbumTBViewCell") as! AlbumTBViewCell
        
        return cell
        
    }
    
    func tableView(_ tb_album: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddPhotoViewController") as! AddPhotoViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }

}
