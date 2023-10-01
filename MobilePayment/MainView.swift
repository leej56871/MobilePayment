//
//  ContentView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/12.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appData: ApplicationData

    var body: some View {
        NavigationStack {
            VStack {
                Home(appData: appData)
                    .foregroundColor(Color.black)
                    .background(Color.white)
                
            }.customToolBar(currentState: "home")

        }
    }
    
}

struct Home: View {
    let appData: ApplicationData
    var body: some View {
        ScrollView {
            Text("Welcome!")
                .font(.title2)
//            Divider()
//                .background(Color.blue)
            LazyHStack {
                Text(appData.userInfo.fullName)
                    .font(.title)
                    .fontWeight(.heavy)
                    .lineLimit(1)
                Spacer(minLength: 30)
                NavigationLink(destination: Text("Show notifications")) {
                    Image(systemName: "bell.circle")
                        .font(.title)
                        .foregroundColor(Color.orange)
                }
                NavigationLink(destination: Text("Move to Setting/User Info")) {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(Color.black)
                }
                NavigationLink(destination: Text("Show whole menu")) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                }
            }.padding()
//                .frame(maxWidth: .infinity)
                .cornerRadius(25)
                .background(Color("MyColor"))
            
//            Divider()
//                .background(Color.blue)
            Spacer(minLength: 150)
            
            LazyVStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: Text(appData.userInfo.getCurrentAmount + " HKD")){
                        Text(appData.userInfo.getCurrentAmount + " HKD")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    
                }
                
                QRCodeView()
                
                
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ApplicationData())
    }
}
