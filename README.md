<p align="center"><a href="#"><img src="design/Icons_pngs/v0.4.0_launcher512px_bg_black.png" width="250"></a></p> 
<h2 align="center"><b>MSM</b></h2>
<h4 align="center">All in one manager for your media server</h4>
<!-- <p align="center"><a href="#"><img src="https://f-droid.org/wiki/images/0/06/F-Droid-button_get-it-on.png"></a></p> -->

<p align="center">
<a href="https://github.com/prinzpiuz/MSM_mobile/releases" alt="build"><img src="https://github.com/prinzpiuz/MSM_mobile/workflows/Build%20and%20Release%20apk/badge.svg?branch=v1.1.4"></a>
<a href="https://www.gnu.org/licenses/gpl-3.0" alt="License: GPLv3"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg"></a>
<a href="https://t.me/joinchat/FDVzK06Rt7vsNQLBLi2icw" alt="telegram: #msm"><img src="https://img.shields.io/badge/chat-Telegram-brightgreen"></a>

</p>
<hr>
<p align="center"><a href="#screenshots">Screenshots</a> &bull; <a href="#description">Description</a> &bull; <a href="#features">Features</a> &bull; <a href="#contribution">Contribution</a>&bull; <a href="https://github.com/prinzpiuz/MSM_mobile/releases">Releases</a> &bull;<a href="#setup">How to setup a media server</a></p>

<hr>

## Screenshots
[<img src="screenshots/main_page.jpg" width=160>](screenshots/main_page.jpg)
[<img src="screenshots/settings.jpg" width=160>](screenshots/settings.jpg)
[<img src="screenshots/upload_page.jpg" width=160>](screenshots/upload_page.jpg)
[<img src="screenshots/live_shell.jpg" width=160>](screenshots/live_shell.jpg)
[<img src="screenshots/manage_server1.jpg" width=160>](screenshots/manage_server1.jpg)
[<img src="screenshots/manage_server2.jpg" width=160>](screenshots/manage_server2.jpg)
[<img src="screenshots/movie_listing.jpg" width=160>](screenshots/movie_listing.jpg)
[<img src="screenshots/tv_listing.jpg" width=160>](screenshots/tv_listing.jpg)
[<img src="screenshots/tv_files.jpg" width=160>](screenshots/tv_files.jpg)
[<img src="screenshots/list_media.jpg" width=160>](screenshots/list_media.jpg)

## Description

MSM works as wrapper around your Media server(emby, jellyfin, kodi, plex) and helps you to manage your media files, like CRUD operations also helps to manage server services without touching server. all you need is android mobile phone and media server which are connected to same network

### Features

- works on top of ssh
- CRUD options on files
- TV series can be created inside new folders or can be uploaded into existing folders
- Uploads run as backgroud tasks
- Server manager(live shell, saving oneline commands)

### Coming Features

- WOL and shutdown/reboot
- Multiple profiles
- User management based on linux user,group,permissions
- … and many more

## Contribution

Whether you have ideas, translations, design changes, code cleaning, or real heavy code changes, help is always welcome.
The more is done the better it gets! please join [Telegram](https://t.me/joinchat/FDVzK06Rt7vsNQLBLi2icw) for further discussion

## Setup

#### Server

- You need to configure ssh in your server 
- then configure a media server like [Emby](https://emby.media/), [Jellyfin](https://jellyfin.org/)
- Note the paths for  saving movies and tv shows (full path), root password, username, port (22(default) in most cases), IP address

#### Mobile

- Give the permission for accesing storage when application startup for first time
- Go to settings page and fill required fields
