/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Sharing 0.1
import MeeGo.Media 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    Translator {
        catalog: "meego-ux-panels-music"
    }

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append("/usr/share/meego-ux-appgrid/applications/meego-app-music.desktop")
    }


    ListModel{
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Recently played"
            custPropName: "RecentlyPlayed"
            isVisible: true
        }
        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Playlists"
            custPropName: "Playlists"
            isVisible: true
        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Recently played"));
            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Playlists"));
        }
    }



    MusicListModel {
        id: musicRecentsModel
        type:MusicListModel.ListofRecentlyPlayed
        limit: 2
        sort: MusicListModel.SortByDefault
    }

    onPanelObjChanged: {
        playlistsModel.hideItemsByURN(panelObj.HiddenItems);
        musicRecentsModel.hideItemsByURN(panelObj.HiddenItems);
    }



    MusicListModel {
        id: playlistsModel
        type:MusicListModel.ListofPlaylists
        limit: 0
        sort: MusicListModel.SortByDefault
    }



    front: Panel {
        panelTitle: qsTr("Music")
        panelContent: {
            var count = 0;
            if (musicIntf.state == "playing" || musicIntf.state == "paused")
                count = count+1;
            if (backSettingsModel.get(0).isVisible)
                count = count + musicRecentsModel.count;
            if (backSettingsModel.get(1).isVisible)
                count = count + playlistsModel.count;
            if (count)
                return itemModelOne;
            else
                return itemModelOOBE;
//            (((playlistsModel.count + musicRecentsModel.count == 0) && (musicIntf.state != "playing" && musicIntf.state != "paused")) ? itemModelOOBE : itemModelOne)
        }
        leftIconSource: "image://theme/panels/pnl_icn_music"
    }

    back: BackPanelStandard {
        panelTitle: qsTr("Music settings")
        subheaderText: qsTr("Music panel content")
        //panelContent: itemModelSizes
        settingsListModel: backSettingsModel
        isBackPanel: true
        leftIconSource: "image://theme/panels/pnl_icn_music"

        onClearHistClicked:{
            musicRecentsModel.clear()
        }

    }

    MusicInterface {
        id: musicIntf
        property bool ready: false;
        //Work around some weird delays in the dbus propogation of the currently playing/next tracks
        //Actually, I think the issue is in the MusicListModel - my theory
        //is that, if tracker hasn't populated the URNs we're requesting into the MusicDatabase yet,
        //then we won't get anything from the model...
        //So, we're really just giving tracker time to populate the DB on startup...
        Component.onCompleted: {
            if (state == "playing" || state == "paused") {
                refreshTimer.start();
            } else {
                ready = true;
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 3000
        onTriggered: {
            console.log("Refreshing music!");
            musicIntf.refresh()
            musicIntf.ready = true;
        }
    }

    resources: [
        VisualItemModel {
            id: itemModelOOBE
            Item {
                height: childrenRect.height
                width: container.width
                //anchors.left:  container.left
                //anchors.left: parent.left


                Text {
                    id: textOOBE
                    anchors.left: parent.left
                    anchors.right:  parent.right
                    anchors.top: parent.top
                    anchors.topMargin: panelSize.contentTopMargin
                    anchors.leftMargin: panelSize.contentSideMargin
                    anchors.rightMargin: panelSize.contentSideMargin
                    width: parent.width
                    text: qsTr("Enjoy your music.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: panelColors.textColor
                }

                Button {
                    id: btnOOBE
                    anchors.top:  textOOBE.bottom
                    anchors.topMargin: panelSize.contentTopMargin
                    text: qsTr("Open Music!")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        spinnerContainer.startSpinner();
                        qApp.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-music.desktop")
                    }
                }
            }
        },

        VisualItemModel {
            id: itemModelOne



            FrontPanelExpandableContent {

                visible: ((musicIntf.state == "playing" || musicIntf.state == "paused") && musicIntf.ready)
                text:qsTr("Currently playing")
                collapsible: false

                Component.onCompleted: {
                    if (musicIntf.state == "playing")
                        musicIntf.refresh();
                }

                contents: Item{

                    height: curPlayingListView.height
                    + playqueueItem.height

                    MusicListModel {
                        id: curPlaying
                        type: MusicListModel.Editor
                        urns: musicIntf.nowTrack
                    }

                    ListView {
                        id: curPlayingListView
                        model: curPlaying
                        width: parent.width
                        height: (width * .4)
                        interactive: false
                        delegate: FrontPanelMusicPreviewContentItem{
                            id: currentlyPlayingItem
                            isCurrentlyPlayingLayout: true
                            anchors.top: parent.top
                            imageSource: thumburi
                            imagePlayStatus: (musicIntf.state == "playing")
                            text: title
                            onBackButtonClicked: musicIntf.prev()
                            onForwardButtonClicked: musicIntf.next()
                            onPlayButtonClicked: (musicIntf.state == "playing" ? musicIntf.pause() : musicIntf.play())
                        }

                    }

                    FrontPanelExpandableContent {

                        id: playqueueItem
                        property int count: 0
                        anchors.top: curPlayingListView.bottom
                        visible: (musicIntf.nextTrackCount > 0)

                        text:qsTr("Play queue")
                        collapsible: false
                        ContextMenu {
                            id: ctxMenuQueue
                            property string currentUrn
                            property string currentUri
                            property variant menuPos
                            property string playCommand

                            content: ActionMenu {
                                model:[qsTr("Open"), qsTr("Play"), qsTr("Share")]
                                onTriggered: {
                                    if (model[index] == qsTr("Open")) {
                                        spinnerContainer.startSpinner();
                                        appsModel.launch( "/usr/bin/meego-qml-launcher --fullscreen --opengl --cmd " + ctxMenuQueue.playCommand + " --app meego-app-music --cdata " + ctxMenuQueue.currentUrn)
                                        container.notifyModel();
                                    } else if (model[index] == qsTr("Play")){
                                        appsModel.launch( "/usr/bin/meego-qml-launcher --fullscreen --opengl --cmd " + ctxMenuQueue.playCommand + " --app meego-app-music --noraise --cdata " + ctxMenuQueue.currentUrn )
                                        //container.notifyModel();
                                    }
                                    else if(model[index] == qsTr("Share"))
                                    {
                                        shareObj.clearItems();
                                        shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeAudio
                                        shareObj.addItem(ctxMenuQueue.currentUri);
                                        ctxMenuQueue.hide()
                                        shareObj.showContextTypes(ctxMenuQueue.menuPos.x, ctxMenuQueue.menuPos.y);
                                    }
                                    else {
                                        console.log("Unhandled context action in Photos: " + model[index]);
                                    }
                                    ctxMenuQueue.hide();
                                }
                            }

                        }
                        MusicListModel {
                            id: nextTwo
                            type: MusicListModel.Editor
                            urns: musicIntf.nextTracks
                        }
                        contents: FrontPanelMusicTrackListView{
                            model: nextTwo
                            contextMenu: ctxMenuQueue
                            onCountChanged: {
                                playqueueItem.count = count
                                //console.log("********nextTwo count changed: " + count)
                            }
                        }
                    }
                }


            }

            FrontPanelExpandableContent {
                id: fpRecentMusic

                visible: backSettingsModel.get(0).isVisible && (count > 0)
                text: qsTr("Recently played")

                property int count: 0;

                ContextMenu {
                    id: ctxMenuRecent
                    property string currentUrn
                    property string currentUri
                    property variant menuPos
                    property string playCommand

                    content: ActionMenu {
                        model:[qsTr("Open"), qsTr("Play"), qsTr("Share"), qsTr("Hide")]
                        onTriggered: {
                            if (model[index] == qsTr("Open")) {
                                spinnerContainer.startSpinner();
                                appsModel.launch( "/usr/bin/meego-qml-launcher --fullscreen --opengl --cmd " + ctxMenuRecent.playCommand + " --app meego-app-music --cdata " + ctxMenuRecent.currentUrn)
                                container.notifyModel();
                            } else if (model[index] == qsTr("Play")){
                                appsModel.launch( "/usr/bin/meego-qml-launcher --fullscreen --opengl --cmd " + ctxMenuRecent.playCommand + " --app meego-app-music --noraise --cdata " + ctxMenuRecent.currentUrn )
                                //container.notifyModel();
                            }
                            else if(model[index] == qsTr("Share"))
                            {
                                shareObj.clearItems();
                                shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeAudio
                                shareObj.addItem(ctxMenuRecent.currentUri);
                                ctxMenuRecent.hide()
                                shareObj.showContextTypes(ctxMenuRecent.menuPos.x, ctxMenuRecent.menuPos.y);
                            }
                            else if (model[index] == qsTr("Hide"))
                            {
                                panelObj.addHiddenItem(ctxMenuRecent.currentUrn)
                                musicRecentsModel.hideItemByURN(ctxMenuRecent.currentUrn)
                            }
                            else {
                                console.log("Unhandled context action in Photos: " + model[index]);
                            }
                            ctxMenuRecent.hide();
                        }
                    }

                }

                contents: FrontPanelListView{
                    model: musicRecentsModel
                    width: parent.width
                    height: { return count * (Math.round(width * 0.4) + 2); }

                    onCountChanged: fpRecentMusic.count = count
                    Component.onCompleted: fpRecentMusic.count = count

                    delegate:  FrontPanelMusicPreviewContentItem{
                        id: musicPreview
                        imageSource: thumburi
                        text: title
                        imagePlayStatus: false //playstatus == 2
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
                        onPlayButtonClicked: {
                            var playCommand = "playSong";
                            if (itemtype == MediaItem.SongItem)
                                playCommand = "playSong";
                            else if (itemtype == MediaItem.MusicArtistItem)
                                playCommand = "playArtist";
                            else if (itemtype == MediaItem.MusicAlbumItem)
                                playCommand = "playAlbum";
                            else if (itemtype == MediaItem.MusicPlaylistItem)
                                playCommand = "playPlaylist";

                            appsModel.launch( "/usr/bin/meego-qml-launcher --opengl --fullscreen --cmd " + playCommand + " --app meego-app-music --noraise --cdata " + urn)
                        }

                        //For the context Menu
                        onPressAndHold:{
                            var pos = musicPreview.mapToItem(scene, mouse.x, mouse.y);

                            ctxMenuRecent.currentUrn=urn;
                            ctxMenuRecent.currentUri=uri;

                            var playCommand = "playSong";
                            if (itemtype == MediaItem.SongItem)
                                playCommand = "playSong";
                            else if (itemtype == MediaItem.MusicArtistItem)
                                playCommand = "playArtist";
                            else if (itemtype == MediaItem.MusicAlbumItem)
                                playCommand = "playAlbum";
                            else if (itemtype == MediaItem.MusicPlaylistItem)
                                playCommand = "playPlaylist";

                            ctxMenuRecent.playCommand = playCommand
                            ctxMenuRecent.menuPos = pos;
                            ctxMenuRecent.setPosition(pos.x, pos.y);
                            ctxMenuRecent.show();
                        }

                    }
                }
            }

            FrontPanelExpandableContent {
                id: fpPlaylists
                visible: backSettingsModel.get(1).isVisible && (count > 0)
                anchors.top: fpRecentMusic.bottom
                text: qsTr("Playlists")
                property int count: 0

                ContextMenu {
                    id: ctxMenuAlbum
                    property string currentUrn
                    content: ActionMenu {
                        model:[ qsTr("Play"), qsTr("Hide")]

                        onTriggered: {
                            if (model[index] == qsTr("Play")) {
                                spinnerContainer.startSpinner();
                                appsModel.launch( "/usr/bin/meego-qml-launcher --opengl --fullscreen --cmd playPlaylist --app meego-app-music --cdata " + ctxMenuAlbum.currentUrn)
                                container.notifyModel();
                            } else if (model[index] == qsTr("Hide"))
                            {
                                panelObj.addHiddenItem(ctxMenuAlbum.currentUrn)
                                playlistsModel.hideItemByURN(ctxMenuAlbum.currentUrn)
                            }
                            else {
                                console.log("Unhandled context action in Photos: " + model[index]);
                            }
                            ctxMenuAlbum.hide();
                        }
                    }
                }

                contents: FrontPanelColumnView{
                    model: playlistsModel
                    width: parent.width
                    onCountChanged: fpPlaylists.count = count
                    Component.onCompleted: fpPlaylists.count = count
                    delegate: FrontPanelIconTextItem {
                        id:albumPreview
                        text: title
                        imageSource: thumburi
                        fallBackImage: "image://theme/media/music_thumb_med"
                        zoomImage: true

                        onClicked:{
                            spinnerContainer.startSpinner();
                            appsModel.launch( "/usr/bin/meego-qml-launcher --opengl --fullscreen --cmd playPlaylist --app meego-app-music --cdata " + urn)
                            container.notifyModel();
                        }

                        //For the context Menu                        
                        onPressAndHold:{
                            var pos = albumPreview.mapToItem(scene, mouse.x, mouse.y);

                            ctxMenuAlbum.currentUrn = urn
                            ctxMenuAlbum.setPosition(pos.x, pos.y);
                            ctxMenuAlbum.show();
                        }

                    }
                }
            }
        }
    ]
}
