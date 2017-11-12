//
//  AudioPlayerController.swift
//  SurroundSound
//
//  Created by Ryuji Mano on 11/11/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import FontAwesomeKit
import MediaPlayer

fileprivate let stockImages: [String] = ["pexels-photo-188031", "pexels-photo-190178", "pexels-photo-193633", "pexels-photo-243138", "pexels-photo-631989", "pexels-photo-634026"]

class AudioPlayerController: UIViewController {
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.setImage(FAKFontAwesome.playIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
            playButton.tintColor = .black
        }
    }
    @IBOutlet weak var previousButton: UIButton! {
        didSet {
            previousButton.setImage(FAKFontAwesome.stepBackwardIcon(withSize: 36.0).image(with: CGSize(width: 36.0, height: 36.0)), for: .normal)
            previousButton.tintColor = .black
        }
    }
    @IBOutlet weak var forwardButton: UIButton! {
        didSet {
            forwardButton.setImage(FAKFontAwesome.stepForwardIcon(withSize: 36.0).image(with: CGSize(width: 36.0, height: 36.0)), for: .normal)
            forwardButton.tintColor = .black
        }
    }
    @IBOutlet weak var audioImageView: UIImageView!

    @IBOutlet weak var leftSlidingView: UIView!
    @IBOutlet weak var rightSlidingView: UIView!
    @IBOutlet weak var slidingView: UIView! {
        didSet {
            let gestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
            gestureRecognizer.addTarget(self, action: #selector(AudioPlayerController.slidingViewDidPan(sender:)))
            slidingView.addGestureRecognizer(gestureRecognizer)
        }
    }

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    @IBOutlet weak var leftSlidingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSlidingViewWidthConstraint: NSLayoutConstraint!

    var previousPoint: CGPoint = CGPoint.zero
    var previousTranslation: CGFloat = 0.0

    var song: MPMediaItem?
    var songs: [MPMediaItem]?

    var musicController: MPMusicPlayerController = MPMusicPlayerController()
    var isPaused: Bool = true

    var timer: Timer = Timer()

    var imageIndex = Int(arc4random_uniform(UInt32(stockImages.count)))

    override func viewDidLoad() {
        super.viewDidLoad()
        if let song = self.song, let songs = self.songs {
            setUpAudio()
        } else {
            dismiss(animated: true, completion: nil)
        }
        setUpViews()

        initialAudio()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func setUpAudio() {
        guard let song = self.song else {
            dismiss(animated: true, completion: nil)
            return
        }
        if let artwork = song.artwork {
            audioImageView.image = artwork.image(at: audioImageView.bounds.size)
        } else {
            audioImageView.image = UIImage(named: stockImages[imageIndex])
        }
        songTitleLabel.text = song.title
        artistLabel.text = song.artist
    }

    func setUpViews() {
        leftSlidingViewWidthConstraint.constant = 0.0
        previousPoint.x = leftSlidingViewWidthConstraint.constant
    }

    func initialAudio() {
        guard let songs = self.songs else {
            dismiss(animated: true, completion: nil)
            return
        }
        musicController.setQueue(with: MPMediaItemCollection(items: songs))
        musicController.prepareToPlay()
        musicController.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayerController.updatePlaying(_:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)

        musicController.nowPlayingItem = song
        musicController.play()
        setUpTimer()
        isPaused = false

        playButton.setImage(FAKFontAwesome.pauseIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
    }

    func setUpTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AudioPlayerController.audioPlaying), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        timer.invalidate()
    }

    @objc func audioPlaying() {
        guard let item = musicController.nowPlayingItem else {
            dismiss(animated: true, completion: nil)
            return
        }
        let width = CGFloat(musicController.currentPlaybackTime / item.playbackDuration) * slidingView.bounds.size.width
        if width <= 0.0 {
            leftSlidingViewWidthConstraint.constant = 0.0
        } else if width >= slidingView.bounds.size.width {
            leftSlidingViewWidthConstraint.constant = slidingView.bounds.size.width
        } else {
            leftSlidingViewWidthConstraint.constant = width
        }
        previousPoint.x = leftSlidingViewWidthConstraint.constant
    }

    @objc func updatePlaying(_ notification: Notification) {
        if musicController.playbackState == .seekingBackward {
            if musicController.indexOfNowPlayingItem == 0 {
                musicController.nowPlayingItem = self.songs?.last
                musicController.play()
                playButton.setImage(FAKFontAwesome.pauseIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
            }
        } else if musicController.playbackState == .seekingForward {
            if let songs = self.songs, musicController.indexOfNowPlayingItem == songs.count - 1 {
                musicController.nowPlayingItem = self.songs?.first
                self.song = self.songs?.first
                musicController.play()
                playButton.setImage(FAKFontAwesome.pauseIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
            }
        } else if musicController.playbackState == .paused {
            playButton.setImage(FAKFontAwesome.playIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
        } else if musicController.playbackState == .stopped {
            playButton.setImage(FAKFontAwesome.playIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
        } else if musicController.playbackState == .playing {
            playButton.setImage(FAKFontAwesome.pauseIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
        }
        setUpAudio()
    }

    @objc func slidingViewDidPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: slidingView)

        if (sender.state == .began) {
            previousTranslation = 0.0
            musicController.pause()
            stopTimer()
        }

        previousPoint.x -= previousTranslation

        previousPoint.x += translation.x
        previousTranslation = translation.x

        if (previousPoint.x <= 0.0 && translation.x < 0.0) {
            leftSlidingViewWidthConstraint.constant = 0.0
            previousPoint.x = 0.0
        } else if (previousPoint.x >= slidingView.frame.size.width && translation.x > 0.0) {
            leftSlidingViewWidthConstraint.constant = slidingView.frame.size.width
            previousPoint.x = slidingView.frame.size.width
        } else {
            leftSlidingViewWidthConstraint.constant = previousPoint.x
        }

        if let item = musicController.nowPlayingItem {
            musicController.currentPlaybackTime = Double(leftSlidingViewWidthConstraint.constant / slidingView.bounds.size.width) * item.playbackDuration
        }
        if (sender.state == .ended) {
            musicController.play()
            setUpTimer()
        }
    }

    @IBAction func didTapPlayButton(_ sender: Any) {
        guard let song = self.song else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        musicController.nowPlayingItem = song
        if isPaused {
            setUpTimer()
            musicController.play()
            isPaused = false
            playButton.setImage(FAKFontAwesome.pauseIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)

        } else {
            stopTimer()
            musicController.pause()
            isPaused = true
            playButton.setImage(FAKFontAwesome.playIcon(withSize: 40.0).image(with: CGSize(width: 40.0, height: 40.0)), for: .normal)
        }
    }

    @IBAction func didTapPreviousButton(_ sender: Any) {
        if musicController.currentPlaybackTime > 5.0 {
            musicController.skipToBeginning()
        } else {
            if musicController.indexOfNowPlayingItem == 0 {
                musicController.nowPlayingItem = self.songs?.last
            } else {
                musicController.skipToPreviousItem()
            }
        }
        if let song = musicController.nowPlayingItem {
            self.song = song
            setUpAudio()
        } else {
            musicController.pause()
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func didTapForwardButton(_ sender: Any) {
        musicController.skipToNextItem()
        if let song = musicController.nowPlayingItem {
            self.song = song
            setUpAudio()
        } else {
            musicController.pause()
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
