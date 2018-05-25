//
//  HomeViewModel.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxDataSources
import Moya
import RxNetwork

struct HomeNewsSection {
    var items: [HomeNewsModel]
}

extension HomeNewsSection: SectionModelType {
    init(original: HomeNewsSection, items: [HomeNewsModel]) {
        self = original
        self.items = items
    }
}

class HomeViewModel {
    
    struct Input {
        let refresh: Observable<Void>
        let loading: ControlEvent<Void>
    }
    
    struct Output {
        let bannerItems: Driver<[(image: String, title: String)]>
        let items: Driver<[HomeNewsSection]>
    }

    private var date: String = ""
    private var sections: [HomeNewsSection] = []
    
    var sectionTitles: [String] = []
    var bannerList: [HomeNewsModel] = []
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<HomeNewsSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<HomeNewsSection>(configureCell: { (ds, tv, ip, item) -> HomeNewsRowCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "HomeNewsRowCell", for: ip) as! HomeNewsRowCell
            cell.update(item)
            return cell
        })
        return dataSource
    }()
    
    func transform(_ input: Input) -> Output {
        
        let refresh = input.refresh.flatMap { _ in
            self.requestLatestNews()
            }.share(replay: 1)
        
        let bannerItems = refresh.map({
            $0.topStories
        }).do(onNext: { (banners) in
            self.bannerList = banners
        }).map({
            $0.compactMap({ (image: $0.image, title: $0.title) })
        }).asDriver(onErrorJustReturn: [])
        
        let source1 = refresh.map({ response -> [HomeNewsSection] in
            self.sections = [HomeNewsSection(items: response.stories)]
            return self.sections
        })
        
        let source2 = input.loading.flatMap { _ in
            self.requestBeforeNews()
        }.map({ response -> [HomeNewsSection] in
            self.sections.append(HomeNewsSection(items: response.stories))
            return self.sections
        })
        
        let items = Observable.merge(source1, source2).asDriver(onErrorJustReturn: [])
        
        return Output(bannerItems: bannerItems, items: items)
    }
    
    private func requestLatestNews() -> Observable<HomeNewsListModel> {
        return NewsAPI.latestNews.request(HomeNewsListModel.self).do(onSuccess: { [weak self] (model) in
            guard let `self` = self else { return }
            self.date = model.date
            self.sectionTitles.removeAll()
        }).asObservable().catchErrorJustReturn(HomeNewsListModel(date: "", stories: [], topStories: []))
    }
    
    private func requestBeforeNews() -> Observable<HomeNewsListModel> {
        return NewsAPI.beforeNews(date: self.date).request(HomeNewsListModel.self).do(onSuccess: { [weak self] (model) in
            guard let `self` = self else { return }
            self.date = model.date
            self.sectionTitles.append(self.date)
        }).asObservable().catchErrorJustReturn(HomeNewsListModel(date: "", stories: [], topStories: []))
    }
}

extension Reactive where Base == HomeViewController {
    
    var pushDetail: Binder<HomeNewsModel> {
        return Binder(base) { vc, model in
            vc.navigationController?.hero.isEnabled = true
            vc.navigationController?.hero.navigationAnimationType = .auto
            NewsDetailViewController().start {
                $0.newsID = model.id
                $0.heroID = model.id
            }
        }
    }
}
