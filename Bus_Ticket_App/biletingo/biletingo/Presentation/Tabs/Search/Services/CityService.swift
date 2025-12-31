//
//  CityService.swift
//  biletingo
//
//  Created by Gokhan on 9.09.2025.
//

import Foundation

final class CityService {
    static let shared = CityService()
    private init() {}
    
    private lazy var allCities: [City] = {
        let names = [
            "Adana","Adıyaman","Afyonkarahisar","Ağrı","Aksaray","Amasya","Ankara","Antalya",
            "Ardahan","Artvin","Aydın","Balıkesir","Bartın","Batman","Bayburt","Bilecik","Bingöl",
            "Bitlis","Bolu","Burdur","Bursa","Çanakkale","Çankırı","Çorum","Denizli","Diyarbakır",
            "Düzce","Edirne","Elazığ","Erzincan","Erzurum","Eskişehir","Gaziantep","Giresun",
            "Gümüşhane","Hakkari","Hatay","Iğdır","Isparta","İstanbul","İzmir","Kahramanmaraş",
            "Karabük","Karaman","Kars","Kastamonu","Kayseri","Kırıkkale","Kırklareli","Kırşehir",
            "Kilis","Kocaeli","Konya","Kütahya","Malatya","Manisa","Mardin","Mersin","Muğla","Muş",
            "Nevşehir","Niğde","Ordu","Osmaniye","Rize","Sakarya","Samsun","Siirt","Sinop","Sivas",
            "Şanlıurfa","Şırnak","Tekirdağ","Tokat","Trabzon","Tunceli","Uşak","Van","Yalova",
            "Yozgat","Zonguldak"
        ]
        return names.enumerated().map { .init(id: $0.offset, name: $0.element) }.sorted { $0.name < $1.name }
    }()
    
    func fetchCities(query: String?, page: Int, pageSize: Int, completion: @escaping ([City], Bool) -> Void) {
        let filtered = if let q = query, !q.isEmpty {
            allCities.filter { $0.name.localizedCaseInsensitiveContains(q) }
        } else { allCities }
        
        let start = page * pageSize
        let end = min(start + pageSize, filtered.count)
        let slice = start < end ? Array(filtered[start..<end]) : []
        let hasMore = end < filtered.count
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
            completion(slice, hasMore)
        }
    }
}

