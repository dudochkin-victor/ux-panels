/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Media 0.1

FrontPanelColumnView {

    id: fpMusicTrackListView
    width: parent.width
    delegate: trackComponent

    property variant contextMenu

    Component {
        id: trackComponent

        FrontPanelContentItem {
            id: trackItem
            width: parent.width
            contentHeight: panelSize.contentItemHeight
            mouseAreaActive: true

            Image{
                id: imgArt
                anchors.left: parent.left
                sourceSize.height: panelSize.contentItemHeight
                sourceSize.width: sourceSize.height
                source: thumburi

                Component.onCompleted: {
                    if ((imgArt.status == Image.Error) || (imgArt.status == Image.Null)) {
                        imgArt.source = "image://theme/media/music_thumb_med";
                    }
                }
            }

            Text {
                id: fpMainText
                text: title
                font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
                color: panelColors.textColor
                anchors.top: parent.top
                anchors.topMargin: font.pixelSize/2
                anchors.left: imgArt.right
                anchors.leftMargin: panelSize.contentSideMargin
                anchors.right: parent.right
                anchors.rightMargin: panelSize.contentSideMargin
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
            onClicked:{
                spinnerContainer.startSpinner();
                var playCommand = "playSong";
                if (itemtype == MediaItem.SongItem)
                    playCommand = "playSong";
                else if (itemtype == MediaItem.MusicArtistItem)
                    playCommand = "playArtist";
                  else if (itemtype == MediaItem.MusicAlbumItem)
                      playCommand = "playAlbum";
                  else if (itemtype == MediaItem.MusicPlaylistItem)
                      playCommand = "playPlaylist";

                  appsModel.launch("/usr/bin/meego-qml-launcher --opengl --fullscreen --cmd " + playCommand + " --app meego-app-music --cdata " + urn)
                  container.notifyModel();
              }
              //For the context Menu
              onPressAndHold:{
                  var pos = trackItem.mapToItem(scene, mouse.x, mouse.y);

                  contextMenu.currentUrn=urn;
                  contextMenu.currentUri=uri;

                  var playCommand = "playSong";
                  if (itemtype == MediaItem.SongItem)
                      playCommand = "playSong";
                  else if (itemtype == MediaItem.MusicArtistItem)
                      playCommand = "playArtist";
                  else if (itemtype == MediaItem.MusicAlbumItem)
                      playCommand = "playAlbum";
                  else if (itemtype == MediaItem.MusicPlaylistItem)
                      playCommand = "playPlaylist";

                  contextMenu.playCommand = playCommand
                  contextMenu.menuPos = pos;
                  contextMenu.setPosition(pos.x, pos.y);
                  contextMenu.show();
              }
        }
    }
}
