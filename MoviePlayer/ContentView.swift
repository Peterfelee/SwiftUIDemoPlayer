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
                NavigationLink.init(destination: MapLandMarkView()) {
                    ImageView()
                }
            }.navigationBarTitle(Text("First Blood"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView()
        ImageView()
    }
}
