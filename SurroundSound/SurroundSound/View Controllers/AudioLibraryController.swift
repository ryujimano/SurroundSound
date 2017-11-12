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
import MultipeerConnectivity

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

    var session: MPSession = MPSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
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

    func sendData(data: Data) {
        if session.mcSession.connectedPeers.count > 0 {
            do {
                try session.mcSession.send(data, toPeers: session.mcSession.connectedPeers, with: .reliable)
            } catch let error {
                print(error.localizedDescription)
                return
            }
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

extension AudioLibraryController: MPSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(state.rawValue)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {

    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session.mcSession)
    }


}
