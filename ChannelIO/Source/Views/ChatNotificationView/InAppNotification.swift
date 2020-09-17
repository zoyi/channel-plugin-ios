import Foundation
import RxSwift

enum InAppNotificationType: String {
  case fullScreen
  case banner
}

protocol InAppNotification: class {
  var notiType: InAppNotificationType { get }
  
  func configure(with viewModel: InAppNotificationViewModel)
  func insertView(on view: UIView?)
  func signalForChat() -> Observable<Any?>
  func signalForClose() -> Observable<Any?>
  func removeView(animated: Bool)
}
