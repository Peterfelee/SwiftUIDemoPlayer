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
                NavigationLink.init(destination: PlayerViewContainer().edgesIgnoringSafeArea(.top)) {
                    ImageView()
                }
            }.navigationBarTitle(Text("First Blood"))
        }
    }
}


import AVKit

struct PlayerViewContainer:View {
    
    var body: some View{
        PlayerView().onDisappear {
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
        temp.backgroundColor = UIColor.black
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
        }

        func  setupView(view:UIView) -> Void {
            playerItem = AVPlayerItem(url: URL(string: "https://meiju4.whetyy.com/20190725/ix0Z695V/index.m3u8")!)
            avplayer = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: avplayer!)
            view.layer.addSublayer((playerLayer)!)
            playerLayer?.frame = UIScreen.main.bounds
            avplayer?.play()
            self.view = view
        }

        func stopPlay() -> Void {
            if avplayer != nil {
                avplayer?.pause()
                playerItem?.cancelPendingSeeks()
                playerLayer?.removeFromSuperlayer()
                avplayer = nil
                playerItem = nil
                playerLayer = nil
                self.view?.removeFromSuperview()
            }
        }

        func updateLayer() {
            let frame = UIScreen.main.bounds
            view?.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
            playerLayer?.frame = CGRect(x: 0, y: 0, width: max(frame.width, frame.height), height: min(frame.width, frame.height))
        }
    }
}
