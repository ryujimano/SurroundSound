//
//  AudioListController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import MediaPlayer
import DZNEmptyDataSet
import FontAwesomeKit

protocol AudioListControllerDelegate: class {
    func sendSongs(songs: [MPMediaItem], songIndeces: Set<Int>)
}

class AudioListController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(cellType: AudioListCell.self)

            tableView.tableFooterView = UIView()
        }
    }

    var items: [MPMediaItem] = []
    var selectedIndeces: Set<Int> = []

    weak var delegate: AudioListControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpList()
    }

    func setUpList() {
        if MPMediaLibrary.authorizationStatus() != .authorized {
            MPMediaLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.getSongs()
                }
            }
        } else {
            self.getSongs()
        }
    }

    func getSongs() {
        let mediaQuery = MPMediaQuery.songs()
        guard let items = mediaQuery.items else {
            return
        }

        self.items = items
        self.tableView.reloadData()
    }

    @IBAction func didTapDoneButton(_ sender: Any) {
        if let delegate = delegate {
            delegate.sendSongs(songs: selectedIndeces.map { self.items[$0] }, songIndeces: selectedIndeces)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AudioListController: DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "There are no songs in your library."
        let attributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return FAKFontAwesome.musicIcon(withSize: 80.0).image(with: CGSize(width: 80.0, height: 80.0))
    }
}

extension AudioListController: DZNEmptyDataSetSource {
}

extension AudioListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if (selectedIndeces.contains(indexPath.row)) {
            selectedIndeces.remove(indexPath.row)
        } else {
            selectedIndeces.insert(indexPath.row)
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension AudioListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AudioListCell.self, for: indexPath)
        let item = self.items[indexPath.row]
        cell.setUp(audioImage: item.artwork?.image(at: cell.audioImageView.bounds.size), songTitle: item.title, artist: item.artist, selected: selectedIndeces.contains(indexPath.row))
        return cell
    }
}
