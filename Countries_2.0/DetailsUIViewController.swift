//
//  DetailsUIViewController.swift
//  Countries_2.0
//
//  Created by Deniz Demirtas on 6/15/22.
//
import MapKit
import SDWebImage
import SDWebImageSwiftUI
import SwiftUI

struct DetailsUIViewController: View {
    @EnvironmentObject private var countryDetail:
        countryScreenData

    var body: some View {
        VStack(alignment: .center) {
            MapView(coordinate: CLLocationCoordinate2D(latitude: countryDetail.latitude, longitude: countryDetail.longitude))
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400, alignment: .center)

            WebImage(url: URL(string: "https://countryflagsapi.com/png/\(countryDetail.countryCode)"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150, alignment: .center)
                .background(.white)
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 5))
                .offset(y: -50)
                .padding(.bottom, -130)
                

            Spacer(minLength: 50)

            HStack(alignment: .center, spacing: 50) {
                Text("Currency Code: \(countryDetail.countryCurrency) ") 
                    .font(.subheadline)

                Text("Country Code: \(countryDetail.countryCode)")
                    .font(.subheadline)
            }
            .padding()
            .offset(y: 200)
            
            

            Text(countryDetail.countryName)
                .font(.title)
            Spacer(minLength: 20)
            
            Button("Press to Look Up Country Details ", action: {
                
                UIApplication.shared.open(URL(string: "https://www.wikidata.org/wiki/\(countryDetail.wikiID)")! as URL, options: [:], completionHandler: nil)
            })
            
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .padding(.horizontal, 20)
            .background(Color.blue.cornerRadius(10))
            
           
        }
        Spacer(minLength: 200)
            .padding()
    }
}

struct DetailsUIViewController_Previews: PreviewProvider {
    static var previews: some View {
        DetailsUIViewController()
    }
}

class countryScreenData: ObservableObject {
    @Published var countryName: String = ""
    @Published var countryCode: String = ""
    @Published var countryCurrency: String = ""
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var wikiID: String = ""
    var coordinates = [Double]()
}

class DetailsUIViewControllerVHC: UIHostingController<DetailsUIViewController> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DetailsUIViewController())
    }
}
