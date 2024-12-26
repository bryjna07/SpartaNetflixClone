//
//  ViewController.swift
//  SpartaNetflixClone
//
//  Created by t2023-m0033 on 12/26/24.
//

import UIKit
import SnapKit
import RxSwift
import AVKit

class MainViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()
    
    // RxCocoa 나 RxRelay 를 사용하면 이 변수조차 필요없지만, 이 강의에서는 변수를 두고 활용합시다.
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    
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
        bind()
        configureUI()
    }
    
    // View - ViewModel 데이터 바인딩 with RxSwift.
    private func bind() {
        viewModel.popularMovieSubject
        // UI 작업 -> 메인쓰레드에서 동작해라
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.popularMovies = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.topRatedMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.topRatedMovies = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.upcomingMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.upcomingMovies = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
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
    
    /// 해당 URL 의 비디오를 재생하는 함수. 임의의 url 을 넣어서 연습합니다.
    private func playVideoUrl() {
        
        // url 을 인자로 받지만, 유튜브 url 은 정책상 바로 재생할 수 없으므로
        // 임의의 url 을 넣어서 동영상 재생의 구현만 연습해봅니다.
        let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
        // URL 을 AVPlayer 객체에 담음.
        let player = AVPlayer(url: url)
        // AVPlayerViewController 선언.
        let playerViewController = AVPlayerViewController()
        // AVPlayerViewController 의 player 에 위에서 선언한 player 세팅.
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
}

// CollectionView 의 Section 을 나타낼 enum.
enum Section: Int, CaseIterable {
    case popularMovies
    case topRatedMovies
    case upcomingMovies
    
    var title: String {
        switch self {
        case .popularMovies: return "이 시간 핫한 영화"
        case .topRatedMovies: return "가장 평점이 높은 영화"
        case .upcomingMovies: return "곧 개봉되는 영화"
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    // 셀이 클릭 되었을 때 실행할 메서드
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            switch Section(rawValue: indexPath.section) {
            case .popularMovies:
                viewModel.fetchTrailerKey(movie: popularMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { [weak self] key in
                        // 만약 유효한 url 을 서버로부터 받았을 경우 이 url 을 그대로 사용했을 것입니다.
    //                     let url = URL(string: "https://www.youtube.com/watch?v=\(key)")!
                        self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                    }, onFailure: { error in
                        print("에러 발생: \(error)")
                    }).disposed(by: disposeBag)
                
            case .topRatedMovies:
                viewModel.fetchTrailerKey(movie: topRatedMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { [weak self] key in
                        self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                    }, onFailure: { error in
                        print("에러 발생: \(error)")
                    }).disposed(by: disposeBag)
                
            case .upcomingMovies:
                viewModel.fetchTrailerKey(movie: upcomingMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { [weak self] key in
                        self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                    }, onFailure: { error in
                        print("에러 발생: \(error)")
                    }).disposed(by: disposeBag)
                
            case .none:
                break
            }
            
        }
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
        case .upcomingMovies:
            cell.configure(with: upcomingMovies[indexPath.row])
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
        case .upcomingMovies: return upcomingMovies.count
        case .none: return 5
        }
    }
    
    // collectionView 의 섹션이 몇개인지 설정하는 메서드.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
}
