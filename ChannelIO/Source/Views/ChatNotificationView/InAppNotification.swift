import Foundation
import RxSwift
import SnapKit

enum InAppNotificationType: String {
  case banner = "bottom_banner"
  case popup = "popup"
}

protocol InAppNotification: class {
  var notiType: InAppNotificationType { get }
  
  func configure(with viewModel: InAppNotificationViewModel)
  func insertView(on view: UIView)
  func signalForRedirect() -> Observable<String?>
  func signalForChat() -> Observable<Any?>
  func signalForClose() -> Observable<Any?>
  func removeView(animated: Bool)
}
