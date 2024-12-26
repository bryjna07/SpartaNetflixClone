//
//  ViewController.swift
//  SpartaNetflixClone
//
//  Created by t2023-m0033 on 12/26/24.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    // RxCocoa 나 RxRelay 를 사용하면 이 변수조차 필요없지만, 이 강의에서는 변수를 두고 활용합시다.
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var popularTvShows = [Movie]()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "NETFLIX"
        label.textColor = UIColor(red: 229/255, green: 9/255, blue: 20/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        [
            label,
            collectionView
        ].forEach { view.addSubview($0) }
        
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20)
            // leading + trailing = horizontalEdges
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
           // 각 아이템은 각 그룹 내에서 전체 너비와 높이를 차지. (1.0 = 100%).
           let itemSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(1.0),
               heightDimension: .fractionalHeight(1.0)
           )
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
           
           // 각 그룹은 화면 너비의 25%를 차지하고, 높이는 너비의 40%.
           let groupSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(0.25),
               heightDimension: .fractionalWidth(0.4)
           )
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
           
           /*
            섹션은 연속적인 수평 스크롤이 가능.
            그룹 간 간격은 10포인트.
            섹션의 모든 면에 10포인트의 여백 존재. bottom 은 20.
            */
           let section = NSCollectionLayoutSection(group: group)
           section.orthogonalScrollingBehavior = .continuous
           section.interGroupSpacing = 10
           section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
           
           /*
            헤더는 섹션의 전체 너비를 차지하고, 높이는 예상값 44포인트.
            헤더는 섹션의 상단에 배치됩니다.
            */
           let headerSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(1.0),
               heightDimension: .estimated(44)
           )
           let header = NSCollectionLayoutBoundarySupplementaryItem(
               layoutSize: headerSize,
               elementKind: UICollectionView.elementKindSectionHeader,
               alignment: .top
           )
           section.boundarySupplementaryItems = [header]
           
           return UICollectionViewCompositionalLayout(section: section)
       }
    
}

// CollectionView 의 Section 을 나타낼 enum.
enum Section: Int, CaseIterable {
    case popularMovies
    case topRatedMovies
    case popularTVShows
    
    var title: String {
        switch self {
        case .popularMovies: return "이 시간 핫한 영화"
        case .topRatedMovies: return "가장 평점이 높은 영화"
        case .popularTVShows: return "곧 개봉되는 영화"
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    
}

extension MainViewController: UICollectionViewDataSource {
    
    // indexPath 별로 cell 을 구현한다.
    // tableView 의 cellForRowAt 과 비슷한 역할.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        
        switch Section(rawValue: indexPath.section) {
        case .popularMovies:
            cell.configure(with: popularMovies[indexPath.row])
        case .topRatedMovies:
            cell.configure(with: topRatedMovies[indexPath.row])
        case .popularTVShows:
            cell.configure(with: popularTvShows[indexPath.row])
        case .none:
            break
        }
        return cell
    }
    
    // indexPath 별로 supplemenatryView 를 구현한다.
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        // 헤더인 경우에만 구현.
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.id,
            for: indexPath
        ) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let sectionType = Section.allCases[indexPath.section]
        headerView.configure(with: sectionType.title)
        
        return headerView
    }
    
    // 섹션 별로 item 이 몇 개인지 지정하는 메서드.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .popularMovies: return popularMovies.count
        case .topRatedMovies: return topRatedMovies.count
        case .popularTVShows: return popularTvShows.count
        case .none: return 5
        }
    }
    
}
