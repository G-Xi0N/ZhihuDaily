//
//  HomeTarget.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/9.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya
import RxNetwork

enum NewsAPI {
    
    case latestNews
    case beforeNews(date: String)
    case newsDetail(newsID: String)
}

extension NewsAPI: TargetType, Cacheable {
    
    var path: String {
        switch self {
        case .latestNews:
            return "4/news/latest"
        case .beforeNews(let date):
            return "4/news/before/\(date)"
        case .newsDetail(let newsID):
            return "4/news/\(newsID)"
        }
    }
    
    var task: Task {
        return .requestPlain
    }
}
