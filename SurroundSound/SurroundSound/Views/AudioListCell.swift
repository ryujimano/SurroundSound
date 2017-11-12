//
//  AudioListCell.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import FontAwesomeKit

class AudioListCell: UITableViewCell {
    @IBOutlet weak var audioImageView: UIImageView! {
        didSet {
            audioImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView! {
        didSet {
            checkImageView.image = FAKFontAwesome.checkIcon(withSize: 20.0).image(with: checkImageView.bounds.size)
        }
    }

    func setUp(audioImage: UIImage?, songTitle: String?, artist: String?, selected: Bool) {
        if let image = audioImage {
            audioImageView.image = image
        } else {
            audioImageView.image = FAKFontAwesome.musicIcon(withSize: 40.0).image(with: audioImageView.bounds.size)
        }
        songTitleLabel.text = songTitle
        artistLabel.text = artist
        checkImageView.isHidden = !selected
    }
}
