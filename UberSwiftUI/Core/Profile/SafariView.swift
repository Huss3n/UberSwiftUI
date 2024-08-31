//
//  SafariView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI
import SafariServices

struct SafariViewWrapper: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    ) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }

//    func updateUIViewController(
//        _ uiViewController: SFSafariViewController,
//        context: UIViewControllerRepresentableContext<SafariView>
//    ) {}
}

struct SafariView: View {
    @Binding var showSafari: Bool
    var title: String
    var url: String
    
    var body: some View {
        Button(title) {
            showSafari = true
        }
        .popover(isPresented: $showSafari) {
            SafariViewWrapper(url: URL(string: url)!)
        }
    }
}
