import Foundation
//import RxSwift

enum InAppNotificationType: String {
  case fullScreen
  case banner
}

protocol InAppNotification: class {
  var notiType: InAppNotificationType { get }
  
  func configure(with viewModel: InAppNotificationViewModel)
  func insertView(on view: UIView?)
  func signalForChat() -> _RXSwift_Observable<Any?>
  func signalForClose() -> _RXSwift_Observable<Any?>
  func removeView(animated: Bool)
}
