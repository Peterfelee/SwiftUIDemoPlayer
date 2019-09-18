//
//  MapLandMarkView.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/9/18.
//  Copyright © 2019 Personal. All rights reserved.
//

import SwiftUI

struct MapLandMarkView: View {
    var body: some View {
        VStack{
            MapView().frame(width: UIScreen.main.bounds.size.width, height: 300, alignment: .center).edgesIgnoringSafeArea(.top)
            CircleImage().offset(x: 0, y: -130).padding(.bottom,-130)
        VStack(alignment: .leading, spacing: 0, content: {
            Text("Turtle Rock").font(.title).padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            HStack{
                Text("Joshua Tree National Park").font(.subheadline)
                Spacer()
                Text("California").font(.subheadline)
            }
            }).padding()
            
            Spacer()
        }
        
    }
        
}

struct MapLandMarkView_Previews: PreviewProvider {
    static var previews: some View {
        MapLandMarkView()
    }
}


struct CircleImage:View {
    var body: some View{
        Image("bg_tree").frame(width: 200, height: 200, alignment: .center).clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 3)).shadow(radius: 10)
    }
}

import MapKit

struct MapView:UIViewRepresentable {
  
    typealias UIViewType = MKMapView
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        return MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
          let coordinate = CLLocationCoordinate2D(
              latitude: 34.011286, longitude: -116.166868)
          let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
          let region = MKCoordinateRegion(center: coordinate, span: span)
          uiView.setRegion(region, animated: true)
      }

}
