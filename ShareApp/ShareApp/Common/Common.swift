//
//  Common.swift
//  ShareApp
//
//  Created by iOSpro on 13/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

var PhotoUrlList = [String]()

let mFirebaseDB = Database.database().reference()
let mFirebaseStorage = Storage.storage().reference()

let albumID1 = "ABC123"
let albumName1 = "Test Album 1"
let albumPIN1 = "1234"

var photoCount = 0
var selectedIndex = 0

var isDeleting = false
var isReplacing = false
