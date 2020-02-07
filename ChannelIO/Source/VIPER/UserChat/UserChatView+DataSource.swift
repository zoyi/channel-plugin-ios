//
//  UserChatView+DataSource.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift
import UIKit

// MARK: - UITableView
extension UserChatView : UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case Sections.loadingFile:
      return self.isLoadingFile ? 1 : 0
    case Sections.errorFiles:
      return self.errorFiles.count
    case Sections.typer:
      return 1
    case Sections.messages:
      return self.messages.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case Sections.loadingFile:
      return Constants.fileStatusCellHeight
    case Sections.errorFiles:
      return Constants.fileStatusCellHeight
    case Sections.typer:
      return Constants.typerCellHeight
    case Sections.messages:
      let message = self.messages[indexPath.row]
      let previousMessage: CHMessage? =
        indexPath.row == self.messages.count - 1 ?
          self.messages[indexPath.row] :
          self.messages[indexPath.row + 1]
      let viewModel = MessageCellModel(
        message: message,
        previous: previousMessage,
        row: indexPath.row
      )
      switch message.messageType {
      case .DateDivider:
        return DateCell.cellHeight()
      case .NewAlertMessage:
        return NewMessageDividerCell.cellHeight()
      case .Log:
        return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
      case .Media:
        return viewModel.shouldDisplayForm ?
          ActionMediaMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel) :
          MediaMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .WebPage:
        return viewModel.shouldDisplayForm ?
          ActionWebMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel) :
          WebPageMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .Profile:
        return ProfileCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      default:
        return viewModel.shouldDisplayForm ?
          ActionMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel) :
          MessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      }
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case Sections.loadingFile:
      let cell = self.cellForLoading(tableView, at: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.errorFiles:
      let cell = self.cellForErrorFiles(tableView, at: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.typer:
      let cell = self.cellForTyping(tableView, at: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.messages:
      let cell = self.cellForMessage(tableView, at: indexPath)
      cell.transform = tableView.transform
      return cell
    default:
      return UITableViewCell()
    }
  }

  private func cellForTyping(
    _ tableView: UITableView,
    at indexPath: IndexPath) -> UITableViewCell {
    let cell: TypingIndicatorCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(typingUsers: self.typers)
    return cell
  }
  
  private func cellForLoading(
    _ tableView: UITableView,
    at indexPath: IndexPath) -> UITableViewCell {
    let cell: FileStatusCell = tableView.dequeueReusableCell(for: indexPath)
    if let loadingFile = self.loadingFile {
      cell.configure(item: loadingFile, count: self.initialFileCount)
    }
    cell.signalForRemove()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.loadingFile else { return }
        self?.presenter?.didClickOnRemoveFile(with: item)
      }.disposed(by: self.disposeBag)
    return cell
  }
  
  private func cellForErrorFiles(
    _ tableView: UITableView,
    at indexPath: IndexPath) -> UITableViewCell {
    let cell: FileStatusCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(item: self.errorFiles[indexPath.row], count: 0)
    cell.signalForRemove()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.errorFiles[indexPath.row] else { return }
        self?.presenter?.didClickOnRemoveFile(with: item)
      }.disposed(by: self.disposeBag)
    
    cell.signalForRetry()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.errorFiles[indexPath.row] else { return }
        self?.presenter?.didClickOnRetryFile(with: item)
      }.disposed(by: self.disposeBag)
    
    return cell
  }

  private func cellForMessage(
    _ tableView: UITableView,
     at indexPath: IndexPath) -> UITableViewCell {
    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        self.messages[indexPath.row] :
        self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(
      message: message,
      previous: previousMessage,
      row: indexPath.row
    )
    
    switch message.messageType {
    case .NewAlertMessage:
      let cell: NewMessageDividerCell = tableView.dequeueReusableCell(for: indexPath)
      return cell
    case .DateDivider:
      let cell: DateCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(date: message.plainText ?? "")
      return cell
    case .Log:
      let cell: LogCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(message: message)
      return cell
    case .Profile :
      let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
      return cell
    case .UserMessage:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
      return cell
    case .WebPage:
      if viewModel.shouldDisplayForm {
        let cell: ActionWebMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
        cell.webView.signalForClick()
          .observeOn(MainScheduler.instance)
          .subscribe{ [weak self] _ in
            self?.presenter?.didClickOnWeb(with: message.webPage?.url, from: self)
          }.disposed(by: self.disposeBag)
        return cell
      }
      let cell: WebPageMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
      cell.webView.signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe{ [weak self] _ in
          self?.presenter?.didClickOnWeb(with: message.webPage?.url, from: self)
        }.disposed(by: self.disposeBag)
      return cell
    case .Media:
      if viewModel.shouldDisplayForm {
        let cell: ActionMediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
        cell.setDataSource(self, at: indexPath.row)
        return cell
      }
      let cell: MediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
      cell.setDataSource(self, at: indexPath.row)
      return cell
    default:
      if viewModel.shouldDisplayForm {
        let cell: ActionMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
        return cell
      }
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, dataSource: self, presenter: self.presenter, row: indexPath.row)
      return cell
    }
  }
  
  private func getMessageModel(at row: Int) -> MessageCellModel {
    let message = self.messages[row]
    let previous: CHMessage? = row == self.messages.count - 1 ?
        self.messages[row] :
        self.messages[row + 1]
    let viewModel = MessageCellModel(
      message: message,
      previous: previous,
      row: row
    )
    
    return viewModel
  }
}

extension UserChatView: UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout,
                       UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
    return self.messages[collectionView.tag].files.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
    let files = self.messages[collectionView.tag].sortedFiles
    let file = files[indexPath.row]
    let contentWidth = self.tableView.frame.width
      - Constants.MediaMessageCellLeading
      - Constants.MediaMessageCellTrailing
    let minApplyWidth = max(Constants.mediaMinWidth, file.thumbSize.width)
    let minApplyHeight = max(Constants.mediaMinHeight, file.thumbSize.height)
    if file.type == .video {
      return CGSize(width: minApplyWidth, height: minApplyHeight)
    } else if file.type == .image {
      let isMultipleImages = files.filter { $0.type == .image }.count > 1
      let side = (contentWidth - 8) / 2
      return CGSize(
        width: isMultipleImages ? side : minApplyWidth,
        height: isMultipleImages ? side : minApplyHeight
      )
    } else {
      return CGSize(
        width: contentWidth,
        height: 70
      )
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {
    if let cell = cell as? MediaCollectionViewCell {
      cell.videoView.pause()
      cell.videoView.didHide(from: self)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {
    if let cell = cell as? MediaCollectionViewCell {
      cell.videoView.willDisplay(in: self)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let files = self.messages[collectionView.tag].sortedFiles
    let file = files[indexPath.row]
    if file.type == .video || file.type == .image {
      let cell: MediaCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.imageView.contentMode = files.filter { $0.type == .image }.count > 1 ? .scaleAspectFill : .scaleAspectFit
      cell.signalForClick()
        .subscribe(onNext: { [weak self] (_) in
          self?.presenter?.didClickOnFile(
            with: file, on: cell.imageView, from: self
          )
        }).disposed(by: self.disposeBag)
      cell.videoView.signalForPlay()
        .subscribe(onNext: { [weak self] play, seconds in
          if !play {
            self?.videoRecords[file] = seconds
          }
        }).disposed(by: self.disposeBag)
      cell.configure(with: FileCellModel(file, seconds: self.videoRecords[file]))
      return cell
    } else {
      let cell: FileCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.signalForClick()
        .subscribe(onNext: { [weak self] _ in
          self?.presenter?.didClickOnFile(
            with: file, on: nil, from: self
          )
        }).disposed(by: self.disposeBag)
      cell.configure(with: file)
      return cell
    }
  }
}

