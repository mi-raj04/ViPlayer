//
//  File.swift
//  VPlayerUiKit
//
//  Created by mind on 20/05/24.
//

import UIKit
import AVFoundation

public class CollectionViewCell: UICollectionViewCell {
    public var player: AVPlayer?
    public var playerLayer: AVPlayerLayer?
    public var observer: Any?
    public var progressBar: VideoProgressBar!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressBar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupProgressBar()
    }

    private func setupProgressBar() {
        progressBar = VideoProgressBar(frame: CGRect(x: 0, y: bounds.height - 4, width: bounds.width, height: 4))
        addSubview(progressBar)
    }

    public func setPlayer(player: AVPlayer) {
        if let playerLayer = self.playerLayer {
            playerLayer.removeFromSuperlayer()
        }
        self.player = player
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer?.frame = bounds
        playerLayer?.videoGravity = .resizeAspectFill
        contentView.layer.insertSublayer(playerLayer!, below: progressBar.layer)

        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }

        observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    public func pausePlayer() {
        player?.pause()
    }

    public func resumePlayer() {
        player?.play()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
}
