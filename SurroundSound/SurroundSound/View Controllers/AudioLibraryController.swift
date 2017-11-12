//
//  AudioLibraryController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FontAwesomeKit
import MediaPlayer

class AudioLibraryController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.emptyDataSetDelegate = self
            tableView.emptyDataSetSource = self
            tableView.delegate = self
            tableView.dataSource = self

            tableView.register(cellType: AudioListCell.self)
            tableView.tableFooterView = UIView()
        }
    }

    var songs: [MPMediaItem] = []
    var songIndeces: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addSong(_ sender: Any) {
        performSegue(withIdentifier: "audioListSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AudioPlayerNavigationController {
            if let sender = sender as? Int {
                destination.song = songs[sender]
                destination.songs = songs
            }
        } else if let destination = segue.destination as? AudioListNavigationController {
            destination.navDelegate = self
            destination.songIndeces = self.songIndeces
        }
    }
}

extension AudioLibraryController: DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "There are no songs in your queue."
        let attributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return FAKFontAwesome.musicIcon(withSize: 80.0).image(with: CGSize(width: 80.0, height: 80.0))
    }
}

extension AudioLibraryController: DZNEmptyDataSetSource {
}

extension AudioLibraryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "audioPlayerSegue", sender: indexPath.row)
    }
}

extension AudioLibraryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AudioListCell.self, for: indexPath)
        let song = self.songs[indexPath.row]
        cell.setUp(audioImage: song.artwork?.image(at: cell.audioImageView.bounds.size), songTitle: song.title, artist: song.artist, selected: false)
        return cell
    }
}

extension AudioLibraryController: AudioListNavigationControllerDelegate {
    func sendSongs(songs: [MPMediaItem], songIndeces: Set<Int>) {
        self.songIndeces = songIndeces
        self.songs = songs
        self.tableView.reloadData()
    }
}
