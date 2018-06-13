//
//  NowPlaying.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//


import Foundation
import Dispatch
import UIKit
import AVFoundation
import GoogleMobileAds
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let account = Account()
var audio = Audio(PlaylistName: "Hip Hop")

class NowPlayingVC: UIViewController, GADInterstitialDelegate {
    var timer = Timer()
    var interstitial: GADInterstitial!
    
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: ViewClass!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var revealSidebarButton: ButtonClass!
    @IBOutlet weak var sidebarButtonContraint: NSLayoutConstraint!
    @IBOutlet weak var sidebar: UIView!
    
    @IBAction func revealSidebarAction(_ sender: Any) { self.toggleSidebar() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBanner(BannerView: self.banner, BannerID: self.bannerID)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage, let background = self.backgroundImage {
                background.removeBlur()
                background.image = image
                background.isHidden = false
            }
            self.toggleLoading(isLoading: false)
        }
        else { self.toggleLoading(isLoading: true) }
        
        if audio.shouldDisplayAd { interstitial = self.createInterstitial(); audio.shouldDisplayAd = false }
    }
    
    // MARK: Toggle Loading
    
    func toggleLoading(isLoading: Bool) {
        if isLoading {
            self.loadingView?.isHidden = false
            self.revealSidebarButton?.isHidden = true
            self.loadingSpinner?.startAnimating()
            
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
        else {
            self.loadingView?.isHidden = true
            self.revealSidebarButton?.isHidden = false
            self.loadingSpinner?.stopAnimating()
            
            self.loadingConstraint?.constant = 750
            self.controlCircleConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
    }
    
    // MARK: Toggle Sidebar
    
    func toggleSidebar() {
        let sOrigin = self.sidebar.frame.origin
        let sSize = self.sidebar.frame.size
        
        let bOrigin = self.revealSidebarButton.frame.origin
        let bSize = self.revealSidebarButton.frame.size
        
        if sOrigin.x == CGFloat(0.0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.sidebar.frame = CGRect(x: sOrigin.x - sSize.width, y: sOrigin.y, width: sSize.width, height: sSize.height)
                self.revealSidebarButton.frame = CGRect(x: bOrigin.x - sSize.width, y: bOrigin.y, width: bSize.width, height: bSize.height)
                self.view.layoutIfNeeded()
            })
        }
        else if sOrigin.x == CGFloat(-175.0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.sidebar.frame = CGRect(x: sOrigin.x + sSize.width, y: sOrigin.y, width: sSize.width, height: sSize.height)
                self.revealSidebarButton.frame = CGRect(x: bOrigin.x + sSize.width, y: bOrigin.y, width: bSize.width, height: bSize.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //
    
    private func toggleCircle() {
        if self.controlCircleConstraint?.constant == 0 { self.controlCircleConstraint?.constant = 750 }
        else if self.controlCircleConstraint?.constant == 750 { self.controlCircleConstraint?.constant = 0 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: fullScreenID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) { ad.present(fromRootViewController: self) }

    deinit { self.timer.invalidate() }
}
