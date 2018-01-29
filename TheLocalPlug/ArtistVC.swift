//
//  ArtistVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation

import UIKit
import GoogleMobileAds
import AVFoundation

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//  TODO
// ----------------------------------------------
//
// - Initialize As FavoritesVC If Clicked On Appropriate Button
// - Initialize As DislikesVC If Clicked On Appropriate Button
// - Initialize As RecentlyPlayedVC If Clicked On Appropriate Button
//

var artistSelected = [String: Any]()

class ArtistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var artistClass = Artists()
    var artists = [[String: Any]]()
    var timer = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        banner.adUnitID = bannerID
        banner.rootViewController = self
        self.banner.load(GADRequest())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
        
        if let image = audio.metadata?["Image"] as? UIImage {
            self.backgroundImage?.image = image
            self.backgroundImage?.blur()
        }
        else
        {
            self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit")
            self.backgroundImage?.blur()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private func updateUserInterface()
    {
        self.artists = artistClass.artists
        self.tableView.reloadData()
        
        if self.artists.isEmpty == false { self.timer.invalidate() }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 175 }
        else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if artists.isEmpty { return 1 }
        else { return artists.count + 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArtistHeaderCell") as! ArtistHeaderCell
            cell.cellTitle?.text = "Browse Artists"
            cell.cellDetail?.text = "Check Out Featured Artists"
            
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArtistCell") as! ArtistCell
            cell.artistName?.text = artists[indexPath.row - 1]["Name"] as? String
            cell.artistImage?.image = artists[indexPath.row - 1]["Image"] as? UIImage
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArtistInfoVC") as? ArtistInfoVC {
            artistSelected = self.artists[indexPath.row - 1]
            present(vc, animated: true, completion: nil)
        }
    }
}
