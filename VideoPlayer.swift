//
//  File.swift
//  VPlayerUiKit
//
//  Created by mind on 20/05/24.
//

import UIKit
import AVFoundation
import AVKit

public class VideoPlayer: UIViewController {

    public var collectionView: UICollectionView!
   
    public var currentPlayer: AVPlayer?
    public var currentPlayerIndexPath: IndexPath?

    public var videoURLs: [URL] = [

    ]
    
    public var videoPlayers: [URL: AVPlayer] = [:]
    
    
    public init(collectionView: UICollectionView!, currentPlayer: AVPlayer? = nil, currentPlayerIndexPath: IndexPath? = nil, videoURLs: [URL], videoPlayers: [URL : AVPlayer]) {
        self.collectionView = collectionView
        self.currentPlayer = currentPlayer
        self.currentPlayerIndexPath = currentPlayerIndexPath
        self.videoURLs = videoURLs
        self.videoPlayers = videoPlayers
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if let player = currentPlayer {
            if player.rate == 0 {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
    }
}

extension VideoPlayer: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.setPlayer(player: getOrCreatePlayer(for: videoURLs[indexPath.item]))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? CollectionViewCell {
            videoCell.pausePlayer()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? CollectionViewCell {
            videoCell.resumePlayer()
            currentPlayer = videoCell.player
            currentPlayerIndexPath = indexPath
            currentPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: .main) { [weak self] time in
                guard let duration = self?.currentPlayer?.currentItem?.duration.seconds, duration > 0 else {
                    return
                }
                videoCell.progressBar.progress = CGFloat(time.seconds / duration)
            }
        }
    }
    
    func getOrCreatePlayer(for videoURL: URL) -> AVPlayer {
        if let existingPlayer = videoPlayers[videoURL] {
            return existingPlayer
        } else {
            let player = AVPlayer(url: videoURL)
            videoPlayers[videoURL] = player
            return player
        }
    }
}

public class VideoProgressBar: UIView {
    public var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let barHeight: CGFloat = 4
        let barY = rect.height - barHeight
        let barWidth = rect.width * progress
        UIColor.blue.setFill()
        UIRectFill(CGRect(x: 0, y: barY, width: barWidth, height: barHeight))
    }
}
