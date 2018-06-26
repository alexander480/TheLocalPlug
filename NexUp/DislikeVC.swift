//
//  DislikeVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/24/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class DislikeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    var songs = [[String: String]]()
    var timer = Timer()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if account.dislikes.isEmpty { account.fetchDislikedSongs() }
        
        if let image = audio.metadata?["Image"] as? UIImage { self.backgroundImage?.image = image; self.backgroundImage?.blur() }
        else { self.backgroundImage?.image = #imageLiteral(resourceName: "iTunesArtwork"); self.backgroundImage?.blur() }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 185 } else if indexPath.row == 1 { return 50 } else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs.isEmpty { return 1 } else { return songs.count + 2 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteHeader") as! AccountHeaderCell
                cell.cellTitle.text = "Disliked Songs"
                cell.cellDetail.text = "Check Out Your Disliked Songs"
            
            return cell
        }
        else if row == 1 {
            let req = GADRequest()
                req.testDevices = [ kGADSimulatorID ]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdCell") as! AdCell
                cell.banner.adUnitID = bannerID
                cell.banner.rootViewController = self
                cell.banner.adSize = kGADAdSizeSmartBannerPortrait
                cell.banner.load(req)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
            if let name = songs[row - 2]["Name"], let artist = songs[row - 2]["Artist"], let url = songs[row - 2]["Image"] {
                cell.cellTitle.text = name
                cell.cellDetail.text = artist
                cell.cellImage.imageFromServerURL(urlString: url, tableView: self.tableView, indexpath: indexPath)
            }
            else {
                cell.cellTitle.text = "Loading"
                cell.cellDetail.text = nil
                cell.cellImage.image = nil
            }
            
            return cell
        }
    }
    
    private func updateUserInterface() {
        if self.songs.count != account.dislikes.count {
            self.songs = account.dislikes
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage {
                self.circleButton.setImage(image, for: .normal)
            }
        }
        if let item = audio.player.currentItem {
            self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds)
        }
    }
}
