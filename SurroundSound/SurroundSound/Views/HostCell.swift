//
//  HostCell.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/12/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import FontAwesomeKit

class HostCell: UITableViewCell {
    @IBOutlet weak var hostImageView: UIImageView! {
        didSet {
            hostImageView.image = FAKFontAwesome.usersIcon(withSize: 30.0).image(with: hostImageView.bounds.size)
        }
    }

    @IBOutlet weak var hostNameLabel: UILabel!

    func setUp(with name: String) {
        hostNameLabel.text = name
    }
}
