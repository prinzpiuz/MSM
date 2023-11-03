enum Pages {
  home,
  notifications,
  upload,
  commonUpload,
  systemTools,
  fileList,
  settings,
}

enum SettingsSubRoute {
  serverDetails,
  folderConfiguration,
  serverFunctions,
  appInfo,
}

enum SystemToolsSubRoute {
  liveTerminal,
  services,
}

extension AppPageExtension on Pages {
  String get toPath {
    switch (this) {
      case Pages.home:
        return "/";
      case Pages.notifications:
        return "/notifications";
      case Pages.upload:
        return "/upload";
      case Pages.commonUpload:
        return "/commonUpload";
      case Pages.systemTools:
        return "/systemTools";
      case Pages.fileList:
        return "/fileList";
      case Pages.settings:
        return "/settings";
      default:
        return "/";
    }
  }

  String get toName {
    switch (this) {
      case Pages.home:
        return "HOME";
      case Pages.notifications:
        return "NOTIFICATIONS";
      case Pages.upload:
        return "UPLOAD";
      case Pages.commonUpload:
        return "COMMON UPLOAD";
      case Pages.systemTools:
        return "SYSTEM TOOLS";
      case Pages.fileList:
        return "FILE LIST";
      case Pages.settings:
        return "SETTINGS";
      default:
        return "HOME";
    }
  }

  String get toTitle {
    switch (this) {
      case Pages.home:
        return "Home";
      case Pages.notifications:
        return "Notifications";
      case Pages.upload:
        return "Upload";
      case Pages.commonUpload:
        return "Common Upload";
      case Pages.systemTools:
        return "System Tools";
      case Pages.fileList:
        return "File List";
      case Pages.settings:
        return "Settings";
      default:
        return "Home";
    }
  }
}

extension SettingSubRouteExtension on SettingsSubRoute {
  String get toPath {
    switch (this) {
      case SettingsSubRoute.serverDetails:
        return "serverDetails";
      case SettingsSubRoute.folderConfiguration:
        return "folderConfiguration";
      case SettingsSubRoute.serverFunctions:
        return "serverFunctions";
      case SettingsSubRoute.appInfo:
        return "appInfo";
    }
  }

  String get toName {
    switch (this) {
      case SettingsSubRoute.serverDetails:
        return "SERVER DETAILS";
      case SettingsSubRoute.folderConfiguration:
        return "FOLDER CONFIGURATION";
      case SettingsSubRoute.serverFunctions:
        return "SERVER FUNCTIONS";
      case SettingsSubRoute.appInfo:
        return "APP INFO";
    }
  }

  String get toTitle {
    switch (this) {
      case SettingsSubRoute.serverDetails:
        return "Server Details";
      case SettingsSubRoute.folderConfiguration:
        return "Folder Configuration";
      case SettingsSubRoute.appInfo:
        return "App Info";
      case SettingsSubRoute.serverFunctions:
        return "Server Functions";
    }
  }
}

extension SystemToolsSubRouteExtension on SystemToolsSubRoute {
  String get toPath {
    switch (this) {
      case SystemToolsSubRoute.liveTerminal:
        return "liveTerminal";
      case SystemToolsSubRoute.services:
        return "services";
    }
  }

  String get toName {
    switch (this) {
      case SystemToolsSubRoute.liveTerminal:
        return "LIVE TERMINAL";
      case SystemToolsSubRoute.services:
        return "SERVICES";
    }
  }

  String get toTitle {
    switch (this) {
      case SystemToolsSubRoute.liveTerminal:
        return "Live Terminal";
      case SystemToolsSubRoute.services:
        return "Services";
    }
  }
}
