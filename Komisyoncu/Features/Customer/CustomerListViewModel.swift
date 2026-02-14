//
//  CustomerListViewModel.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 10.02.2026.
//

import Foundation

@MainActor
class CustomerListViewModel: ObservableObject {
    
    enum Segment: String, CaseIterable {
        case active = "Active"
        case archived = "Archived"
    }
    @Published var selectedSegment: Segment = .active
    @Published var activeCustomers: [Customer] = []
    @Published var archivedCustomers: [Customer] = []
    @Published var searchResults: [Customer] = []
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    
    private var activeOffset: Int = 0
    private var archivedOffset: Int = 0
    private var activeHasMore: Bool = true
    private var archivedHasMore: Bool = true
    
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var searchOffset: Int = 0
    private var searchHasMore: Bool = true
    private var lastSearchQuery = ""
    
    
    private let service: CustomerService
    
    
    var customers: [Customer] {
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return searchResults
        }
        
        switch selectedSegment {
        case .active:
            return activeCustomers
        case .archived:
            return archivedCustomers
        }
    }
    
    var hasMoreData : Bool {
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return searchHasMore
        }
        
        switch selectedSegment {
        case .active:
            return activeHasMore
        case .archived:
            return archivedHasMore
        }
    }
    
    
    //MARK: - Init
    
    init(service: CustomerService = CustomerService()) {
        self.service = service
    }
    
    
    //MARK: - Fetch
    
    func fetchCustomers() async {
        isLoading = true
        errorMessage = nil
        defer {isLoading = false}
        
        do {
            //Paralel
            async let active = service.fetchCustomers(isArchived: false)
            async let archived = service.fetchCustomers(isArchived: true)
            
            activeCustomers = try await active
            archivedCustomers = try await archived
            
            activeOffset = activeCustomers.count
            archivedOffset = archivedCustomers.count
            
            activeHasMore = activeCustomers.count == CustomerService.defaultPageSize
            archivedHasMore = archivedCustomers.count == CustomerService.defaultPageSize
            
        } catch {
            errorMessage = "Failed to load customers"
            print("CustomerListViewModel: \(error)")
        }
    }
    
    //MARK: - Pagination
    
    func loadMoreIfNeeded(currentItem: Customer) async {
        
        let items = customers
        guard let index = items.firstIndex(where: {$0.id == currentItem.id}),
              index >= items.count - 5,
              !isLoadingMore,
              hasMoreData else {return}
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await loadMoreSearchResults()
        }else {
            await loadMore()
        }
        
    }
    
    private func loadMore() async {
        isLoadingMore = true
        defer {isLoadingMore = false}
        
        do {
            switch selectedSegment {
            case .active:
                let newCustomers = try await service.fetchCustomers(offset: activeOffset)
                activeCustomers.append(contentsOf: newCustomers)
                activeOffset += newCustomers.count
                activeHasMore = newCustomers.count == CustomerService.defaultPageSize
                
            case .archived:
                let newCustomers = try await service.fetchCustomers(isArchived: true ,offset: archivedOffset)
                archivedCustomers.append(contentsOf: newCustomers)
                archivedOffset += newCustomers.count
                archivedHasMore = newCustomers.count == CustomerService.defaultPageSize
            }
        }catch {
            print("CustomerListViewModel loadMore error: \(error)")
        }
        
    }
    
    private func loadMoreSearchResults() async {
        loadMoreTask?.cancel()
        
        loadMoreTask = Task {
            isLoadingMore = true
            defer {isLoadingMore = false}
            
            do{
                let isArchived = selectedSegment == .archived
                let newResults = try await service.searchCustomers(query: lastSearchQuery, isArchived: isArchived, offset: searchOffset)
                searchResults.append(contentsOf: newResults)
                searchOffset += newResults.count
                searchHasMore = newResults.count == CustomerService.defaultPageSize
            } catch {
                print("CustomerListViewModel search loadMore error: \(error)")
            }
        }

    }
    
    
    //MARK: - Search
    
    func searchTextChanged(){
        searchTask?.cancel()
        loadMoreTask?.cancel()
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            guard !Task.isCancelled else {return}
            
            await performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) async {
        isSearching = true
        defer {isSearching = false}
        
        lastSearchQuery = query
        
        do{
            let isArchived = selectedSegment == .archived
            let results = try await service.searchCustomers(query: query, isArchived: isArchived)
            
            guard !Task.isCancelled else { return }
            
            searchResults = results
            searchOffset = results.count
            searchHasMore = results.count == CustomerService.defaultPageSize
            
        }catch {
            print("CustomerListViewModel search error: \(error)")
            searchResults = []
        }
    }
    
    //MARK: - Refresh
    
    func refresh() async {
        
        //Search aktifse
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.isEmpty else {
            await performSearch(query: query)
            return
        }
        
        //Normal
        await fetchCustomers()
    }
    
    
    //MARK: - Archive Actions
    
    func archiveCustomer(_ customer: Customer) async {
        do {
            try await service.archiveCustomer(id: customer.id)
            
            activeCustomers.removeAll{$0.id == customer.id}
            var archivedCustomer = customer
            archivedCustomer.isArchived = true
            archivedCustomers.append(archivedCustomer)
            archivedCustomers.sort {$0.companyName < $1.companyName}
            
        }catch {
            errorMessage = "Failed to archive customer"
            print("CustomerListViewModel: \(error)")
        }
    }
    
    func unarchiveCustomer(_ customer: Customer) async {
        do {
            try await service.unarchiveCustomer(id: customer.id)
            
            archivedCustomers.removeAll{$0.id == customer.id}
            var activeCustomer = customer
            activeCustomer.isArchived = false
            activeCustomers.append(activeCustomer)
            activeCustomers.sort {$0.companyName < $1.companyName}
        }catch {
            errorMessage = "Failed to unarchive customer"
            print("CustomerListViewModel: \(error)")
        }
    }
    
    
    //MARK: - CRUD Callbacks
    
    func addCustomer(_ customer: Customer) {
        activeCustomers.append(customer)
        activeCustomers.sort{$0.companyName < $1.companyName}
    }
    
    func updateCustomer(_ customer: Customer) {
        
        switch selectedSegment {
            case .active:
                if let index = activeCustomers.firstIndex(where: { $0.id == customer.id }) {
                    activeCustomers[index] = customer
                    activeCustomers.sort { $0.companyName < $1.companyName }
                }
            case .archived:
                if let index = archivedCustomers.firstIndex(where: { $0.id == customer.id }) {
                    archivedCustomers[index] = customer
                    archivedCustomers.sort { $0.companyName < $1.companyName }
                }
            }
    }
    
}
