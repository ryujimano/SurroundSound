//
//  AudioPlayerNavigationController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import MediaPlayer
class AudioPlayerNavigationController: UINavigationController {
    var song: MPMediaItem?
    var songs: [MPMediaItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let destination = self.topViewController as? AudioPlayerController, let song = self.song, let songs = self.songs else {
            dismiss(animated: true, completion: nil)
            return
        }
        destination.song = song
        destination.songs = songs
    }

}
