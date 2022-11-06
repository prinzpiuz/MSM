enum Pages { home, upload, commonUpload }

extension AppPageExtension on Pages {
  String get toPath {
    switch (this) {
      case Pages.home:
        return "/";
      case Pages.upload:
        return "/upload";
      case Pages.commonUpload:
        return "/commonUpload";
      default:
        return "/";
    }
  }

  String get toName {
    switch (this) {
      case Pages.home:
        return "HOME";
      case Pages.upload:
        return "UPLOAD";
      case Pages.commonUpload:
        return "COMMON UPLOAD";
      default:
        return "HOME";
    }
  }

  String get toTitle {
    switch (this) {
      case Pages.home:
        return "home";
      case Pages.upload:
        return "upload";
      case Pages.commonUpload:
        return "common upload";
      default:
        return "home";
    }
  }
}
