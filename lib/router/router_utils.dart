enum Pages { home, upload, commonUpload, systemTools, fileList }

extension AppPageExtension on Pages {
  String get toPath {
    switch (this) {
      case Pages.home:
        return "/";
      case Pages.upload:
        return "/upload";
      case Pages.commonUpload:
        return "/commonUpload";
      case Pages.systemTools:
        return "/systemTools";
      case Pages.fileList:
        return "/fileList";
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
      case Pages.systemTools:
        return "SYSTEM TOOLS";
      case Pages.fileList:
        return "FILE LIST";
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
      case Pages.systemTools:
        return "system tools";
      case Pages.fileList:
        return "file list";
      default:
        return "home";
    }
  }
}
