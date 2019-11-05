//
//  ContentView.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/9/18.
//  Copyright © 2019 Personal. All rights reserved.
//

import SwiftUI
import MBProgressHUDSwiftLGF

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
            VStack{
                NavigationLink.init(destination: PlayerViewContainer().edgesIgnoringSafeArea(.top)) {
                    ImageView()
                    
                }
                
                List(0..<6){ item in
                    HStack{
                        
                        NavigationLink.init(destination: PlayerViewContainer().edgesIgnoringSafeArea(.top)) {
                            ImageView()
                            
                        }
                        
                        
                        Button.init("test") {
                            print("look you")
                        }
                    }
                }.navigationBarTitle(Text("First Blood"))
                
            }
            
            
        }
    }
}


import AVKit

struct PlayerViewContainer:View {
    
    @State private var isSelect:Bool = false
    @State private var playerView:PlayerView = PlayerView()
    var body: some View{
        VStack{
            playerView.onDisappear {
                self.playerView.coor.stopPlay()
            }
            Button.init(isSelect ? "scale" : "full") {
                //全屏
                self.isSelect.toggle()
                self.playerView.coor.updateLayer(full: self.isSelect)
                
            }.frame(width: 300, height: 44, alignment: .center).buttonStyle(DefaultButtonStyle())
        }
        
        
    }
}



struct PlayerView:UIViewRepresentable {
    typealias UIViewType = UIView
    @State var coor:Coordinator = Coordinator()
    
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> UIView {
        let temp = UIView(frame: .zero)
        temp.backgroundColor = UIColor.black
        context.coordinator.setupView(view: temp)
        return temp
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        context.coordinator.updateLayer(full: false)
    }
    
    func makeCoordinator() -> PlayerView.Coordinator {
        coor
    }
    
    class Coordinator: NSObject {
        var avplayer:AVPlayer?
        var playerLayer:AVPlayerLayer?
        var playerItem:AVPlayerItem?
        var view:UIView?
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
        
        func updateLayer(full:Bool) {
            let frame = UIScreen.main.bounds
//            let hud = MBProgressHudSwift(frame: frame)
//            hud.backgroundColor = .red
//            hud.show(animated: true)
            
//            hud.hide(animated: true, afterDelay: 2)
           let hud = MBProgressHudSwift.showHud(addedToView: view!, withAnimated: true)
            hud.hide(animated: true, afterDelay: 2)
            
            if full {
                view?.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
                playerLayer?.frame = CGRect(x: 0, y: 0, width: max(frame.width, frame.height), height: min(frame.width, frame.height))
            }
            else
            {
                view?.transform = CGAffineTransform.identity
                playerLayer?.frame = CGRect(x: 0, y: 0, width: frame.width, height: 350)
            }

        }
    }
}

