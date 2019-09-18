//
//  ContentView.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/9/18.
//  Copyright © 2019 Personal. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World")
    }
    
}

struct ImageView: View {
    
    var body: some View{
        Image("bg_tree").frame(width: 100, height: 100, alignment: .center).border(Color.red, width: 2).clipped()
    }
}

struct ListView:View {
//    var image:ImageView
    var body: some View{
        NavigationView{
            List(0..<6){ item in
                NavigationLink.init(destination: PlayerViewContainer().padding()) {
                    ImageView()
                }
            }.navigationBarTitle(Text("First Blood"))
        }
    }
}


import AVKit

struct PlayerViewContainer:View {
    
    var body: some View{
        PlayerView().padding().onDisappear {
            PlayerView.Coordinator.share.stopPlay()
        }.onAppear {
            PlayerView.Coordinator.share.updateLayer()
        }
    }
}

struct PlayerView:UIViewRepresentable {
    func makeCoordinator() -> PlayerView.Coordinator {
        Coordinator.share
    }
    
    
    typealias UIViewType = UIView
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> UIView {
        let temp = UIView(frame: .zero)
        context.coordinator.setupView(view: temp)
        return temp
    }

    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        context.coordinator.updateLayer()
    }
    
   
    class Coordinator: NSObject {
        var avplayer:AVPlayer?
        var playerLayer:AVPlayerLayer?
        var playerItem:AVPlayerItem?
        var view:UIView?
        static let share = Coordinator()
        override init() {
            super.init()
            playerItem = AVPlayerItem(url: URL(string: "https://meiju4.whetyy.com/20190725/ix0Z695V/index.m3u8")!)
            avplayer = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: avplayer!)
        }
        
        func  setupView(view:UIView) -> Void {
            view.layer.addSublayer((playerLayer)!)
            playerLayer?.frame = UIScreen.main.bounds
            avplayer?.play()
            self.view = view
        }
        
        func stopPlay() -> Void {
            if avplayer != nil {
                avplayer?.pause()
                playerLayer?.removeFromSuperlayer()
            }
        }
        
        func updateLayer() {
//            playerLayer?.frame = self.view!.bounds
            playerLayer?.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, 0, 0)
        }
    }
}
