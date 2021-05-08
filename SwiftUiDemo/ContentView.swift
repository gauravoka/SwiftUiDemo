//
//  ContentView.swift
//  SwiftUiDemo
//
//  Created by Gaurav Oka on 03/05/21.
//

import SwiftUI

//Model

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    
}


//viewModels Group
import Combine

final class ViewModel : ObservableObject {
    @Published var time  = ""
    @Published var users = [User]()
    //to keep subscription alive make
//    private var anyCancellable:AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    
    
    let formatter : DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    init() {
        setupPublishers()
    }
    
    private func setupPublishers() {
       
        setupTimerPublisher()
        setUpNetworkPublisher()
    }
    
    private func setupTimerPublisher() {
        //publisher
        Timer.publish(every: 1, on: .main, in: .default)
            
            .autoconnect()
            //subscribe
            .receive(on: RunLoop.main)
            .sink { (value) in
                self.time = self.formatter.string(from: value)
            }
            .store(in: &cancellables)
    }
    
    private func setUpNetworkPublisher() {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        //publisher
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data,response) in
                guard let httpResponse = response as? HTTPURLResponse , httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
        
        //decode data into json
        //subscribed to publisher
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {_ in }) { (users) in
                self.users = users
            }
            .store(in: &cancellables)
        
    }
}


//views
struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.time)
                List(viewModel.users) { user in
                    Text(user.name)
                    
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
