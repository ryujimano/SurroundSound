//
//  AudioListNavigationController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import MediaPlayer

protocol AudioListNavigationControllerDelegate: class {
    func sendSongs(songs: [MPMediaItem], songIndeces: Set<Int>)
}

class AudioListNavigationController: UINavigationController {
    weak var navDelegate: AudioListNavigationControllerDelegate?
    var songIndeces: Set<Int> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let destination = self.topViewController as? AudioListController {
            destination.delegate = self
            destination.selectedIndeces = songIndeces
        }
    }
}

extension AudioListNavigationController: AudioListControllerDelegate {
    func sendSongs(songs: [MPMediaItem], songIndeces: Set<Int>) {
        if let delegate = navDelegate {
            delegate.sendSongs(songs: songs, songIndeces: songIndeces)
        }
    }
}
