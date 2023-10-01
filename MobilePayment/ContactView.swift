//
//  ContactView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/16.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var isFavContactClicked: Bool = false
    @State private var isContactClicked: Bool = false
    var body: some View {
        VStack {
            HStack {
                EditButton()
                    .font(.title)
                    .fontWeight(.heavy)
                Spacer()
                Button(action: {
                    appData.userInfo.addContact(name: "test", accountNumber: "test", memo: "test")
                    
                }){
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.heavy)
                }
            }.padding()
            
            List {
                if !(appData.userInfo.favBook.isEmpty) {
                    ForEach(appData.userInfo.favBook.indices, id: \.self) { index in
                        HStack {
                            NavigationLink(destination: TransferView(target: appData.userInfo.getFavBook[index])) {
                                HStack {
                                    Text(appData.userInfo.getFavBook[index].name)
                                        .font(.title)
                                    Spacer()
                                    Text(appData.userInfo.getFavBook[index].accountNumber)
                                        .font(.title)
                                    Spacer()
                                }
                            }
                            Button(action: {
                                appData.userInfo.contactBook.append(appData.userInfo.favBook[index])
                                appData.userInfo.favBook.remove(at: index)
                            }){
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(Color.yellow)
                            }.buttonStyle(BorderlessButtonStyle())
                        }.font(.title)
                        
                    }.background(Color.white)
                }
                
                ForEach(appData.userInfo.contactBook.indices, id: \.self) { index in
                    HStack {
                        NavigationLink(destination: TransferView(target: appData.userInfo.getContactBook[index])) {
                            HStack {
                                Text(appData.userInfo.getContactBook[index].name)
                                Spacer()
                                
                                Text(appData.userInfo.getContactBook[index].accountNumber)
                                
                                Spacer()
                            }
                        }

                        Button(action: {
                            appData.userInfo.favBook.append(appData.userInfo.getContactBook[index])
                            appData.userInfo.contactBook.remove(at: index)
                        }){
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.gray)
                        }.buttonStyle(BorderlessButtonStyle())
                    }.font(.title)
                    
                }.background(Color.white)
            }
            Spacer()
        }.padding()
            .customToolBar(currentState: "contact")
            .background(Color("MyColor").gradient)
    }
}

struct ContactView_previews: PreviewProvider {
    static var previews: some View {
        ContactView().environmentObject(ApplicationData())
    }
}
