//
//  HostsController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/12/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FontAwesomeKit
import MultipeerConnectivity

class HostsController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.emptyDataSetDelegate = self
            tableView.emptyDataSetSource = self
            tableView.delegate = self
            tableView.dataSource = self

            tableView.register(cellType: HostCell.self)
            tableView.tableFooterView = UIView()
        }
    }

    var hosts: [MCPeerID] = []

    var session: MPSession = MPSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.delegate = self
        if session.mcAdvertiser != nil {
            session.mcAdvertiser?.stopAdvertisingPeer()
            session.mcAdvertiser = nil
        }
        if session.mcBrowser != nil {
            session.mcBrowser?.stopBrowsingForPeers()
            session.mcBrowser = nil
        }
        session.findHosts()
    }

    @IBAction func hostTapped() {
        if session.mcBrowser != nil {
            session.mcBrowser?.stopBrowsingForPeers()
            session.mcBrowser = nil
        }
        session.startHosting()
        performSegue(withIdentifier: "musicSegue", sender: nil)
    }

}

extension HostsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        session.mcBrowser?.invitePeer(hosts[indexPath.row], to: session.mcSession, withContext: nil, timeout: 10)
    }
}

extension HostsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: HostCell.self, for: indexPath)
        cell.setUp(with: hosts[indexPath.row].displayName)
        return cell
    }
}

extension HostsController: DZNEmptyDataSetSource {

}

extension HostsController: DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "There are no hosts at the moment."
        let attributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return FAKFontAwesome.userOIcon(withSize: 80.0).image(with: CGSize(width: 80.0, height: 80.0))
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let title = "Host a Session"
        let attributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        hostTapped()
    }
}

extension HostsController: MPSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if self.session.mcBrowser != nil {
                self.session.mcBrowser?.stopBrowsingForPeers()
                self.session.mcBrowser = nil
            }
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        hosts.append(peerID)
        self.tableView.reloadData()
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = hosts.index(of: peerID) {
            hosts.remove(at: index)
            self.tableView.reloadData()
        }
    }
}
