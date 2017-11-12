//
//  MPSession.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/12/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

protocol MPSessionDelegate: class {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) 
}

class MPSession: NSObject {
    static let shared = MPSession()

    weak var delegate: MPSessionDelegate?

    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!

    var mcBrowser: MCNearbyServiceBrowser?
    var mcAdvertiser: MCNearbyServiceAdvertiser?

    override init() {
        super.init()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
    }

    func startHosting() {
//        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
//        mcAdvertiserAssistant.start()

        if mcAdvertiser != nil {
            return
        }
        mcAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "surround")
        mcAdvertiser?.delegate = self
        mcAdvertiser?.startAdvertisingPeer()
    }

    func findHosts() {
        if mcBrowser != nil {
            return
        }
        mcBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "surround")
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }
}

extension MPSession: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        delegate?.browser(browser, foundPeer: peerID, withDiscoveryInfo: info)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.browser(browser, lostPeer: peerID)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        delegate?.advertiser(advertiser, didReceiveInvitationFromPeer: peerID, withContext: context, invitationHandler: invitationHandler)
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        delegate?.session(session, peer: peerID, didChange: state)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.session(session, didReceive: data, fromPeer: peerID)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}
