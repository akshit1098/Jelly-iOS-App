//
//  ContentView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        TabView {
//            NavigationView {
//                            JellyFeedView()
//                        }
//                        .tabItem {
//                            Label("Feed", systemImage: "rectangle.stack.fill")
//                        }
//                        .tag(0)
//                }
//    }
//
//
//}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}



import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: Jelly Feed
            NavigationView {
                JellyFeedView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Feed")
            }
            
            // Tab 2: Camera (placeholder)
            VStack {
                Spacer()
                Text("Camera Tab (coming soon)")
                    .font(.title2)
                    .foregroundColor(.gray)
                Spacer()
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Camera")
            }
            
            // Tab 3: Camera Roll (placeholder)
            VStack {
                Spacer()
                Text("Camera Roll Tab (coming soon)")
                    .font(.title2)
                    .foregroundColor(.gray)
                Spacer()
            }
            .tabItem {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Camera Roll")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
