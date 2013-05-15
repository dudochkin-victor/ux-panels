/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs

import MeeGo.Panels 0.1
import MeeGo.Sharing 0.1
import MeeGo.Media 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    Labs.BackgroundModel {
        id: backgroundModel
    }

    Translator {
        catalog: "meego-ux-panels-photos"
    }

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append("/usr/share/meego-ux-appgrid/applications/meego-app-photos.desktop")        
    }

    ListModel{
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Recently viewed"
            custPropName: "RecentlyViewed"
            isVisible: true
        }
        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Albums"
            custPropName: "Albums"
            isVisible: true
        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Recently viewed"));
            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Albums"));
        }
    }

    onPanelObjChanged: {
        allPhotosListModel.hideItemsByURN(panelObj.HiddenItems)
        allAlbumsListModel.hideItemsByURN(panelObj.HiddenItems)
    }

    PhotoListModel {
        id: allPhotosListModel
        type: PhotoListModel.ListofRecentlyViewed
        limit: 16
        sort: PhotoListModel.SortByDefault
    }

    PhotoListModel {
        id: allAlbumsListModel
        type: PhotoListModel.ListofUserAlbums
        limit: 0
        sort: PhotoListModel.SortByDefault
    }

    front: SimplePanel {
        panelTitle: qsTr("Photos")
        panelComponent: {
            var count = 0;
            if (backSettingsModel.get(0).isVisible)
                count = count + allPhotosListModel.count;
            if (backSettingsModel.get(1).isVisible)
                count = count + allAlbumsListModel.count;
            if (count)
                return photoFront;
            else
                return photoOOBE;
//            (allPhotosListModel.count + allAlbumsListModel.count == 0 ? photoOOBE : photoFront)

        }
        leftIconSource: "image://theme/panels/pnl_icn_photos"
    }

    back: BackPanelStandard {
        panelTitle: qsTr("Photos settings")
        subheaderText: qsTr("Photos panel content")
        settingsListModel: backSettingsModel
        isBackPanel: true
        leftIconSource: "image://theme/panels/pnl_icn_photos"


        onClearHistClicked:{
           allPhotosListModel.clear()
        }

    }

    Component {
        id: photoOOBE
        Item {
            height: container.height
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
                text: qsTr("See your photos.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: panelColors.textColor
            }

            Button {
                id: btnOOBE
                anchors.top:  textOOBE.bottom
                anchors.topMargin: panelSize.contentTopMargin
                text: qsTr("Open Photos!")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    spinnerContainer.startSpinner();
                    qApp.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-photos.desktop")
                }
            }
        }
    }

    Component {
        id: photoFront

        Flickable{

            ContextMenu {
                id: ctxMenuPhoto
                property string currentUrn
                property string currentUri
                property variant menuPos
                content: ActionMenu {
                    model:[qsTr("Open"), qsTr("Share") ,qsTr("Hide"), qsTr("Set as background")]
                    onTriggered: {
                        if (model[index] == qsTr("Open")) {
                            spinnerContainer.startSpinner();
                            appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showPhoto --fullscreen --app meego-app-photos --cdata " + ctxMenuPhoto.currentUrn )
                            container.notifyModel()
                        } else if (model[index] == qsTr("Hide")){
                            panelObj.addHiddenItem(ctxMenuPhoto.currentUrn)
                            allPhotosListModel.hideItemByURN(ctxMenuPhoto.currentUrn)
                        }else if (model[index] == qsTr("Share"))
                        {
                            shareObj.clearItems();
                            shareObj.addItem(ctxMenuPhoto.currentUri);
                            shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                            ctxMenuPhoto.hide()
                            shareObj.showContextTypes(ctxMenuPhoto.menuPos.x, ctxMenuPhoto.menuPos.y);
                        }
                        else {
                            backgroundModel.activeWallpaper = ctxMenuPhoto.currentUri;
                        }
                        ctxMenuPhoto.hide();
                    }
                }
            }

            ContextMenu {
                id: ctxMenuAlbum
                property string currentUrn


                content: ActionMenu {
                    model:[qsTr("Open"),qsTr("Hide")]

                    onTriggered: {
                        if (model[index] == qsTr("Open")) {
                            spinnerContainer.startSpinner();
                            appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showAlbum --fullscreen --app meego-app-photos --cdata " + ctxMenuAlbum.currentUrn )
                            container.notifyModel()
                        } else if (model[index] == qsTr("Hide")){
                            panelObj.addHiddenItem(ctxMenuAlbum.currentUrn)
                            allAlbumsListModel.hideItemByURN(ctxMenuAlbum.currentUrn)
                        } else {
                            console.log("Unhandled context action in Photos: " + model[index]);
                        }
                        ctxMenuAlbum.hide();
                    }
                }
            }


            id: photoFrontItem
            clip: true
            anchors.fill: parent
            interactive: (contentHeight > height)
            onInteractiveChanged: {
                if (!interactive)
                    contentY = 0;
            }
            contentHeight: fpecPhotoGrid.height + fpecAlbumList.height
            FrontPanelExpandableContent {
                id: fpecPhotoGrid
                text: qsTr("Recently viewed")
                collapsible: false
                visible: backSettingsModel.get(0).isVisible && (count > 0)
                property int count: 0

                contents: FrontPanelGridView {
                    id: photoGrid
                    width: parent.width
                    anchors.top: parent.top
                    colCount: 4
                    model: allPhotosListModel
                    onCountChanged: fpecPhotoGrid.count = count
                    Component.onCompleted: fpecPhotoGrid.count = count
                    delegate: FrontPanelGridImageItem {
                        id:photoPreview
                        imageSource: thumburi
                        width: { return Math.floor(parent.width/photoGrid.colCount); }
                        imageFillMode: Image.PreserveAspectCrop
                        height: width
                        clip: true
                        padding: 0
                        onClicked: {
                            spinnerContainer.startSpinner();
                            appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showPhoto --fullscreen --app meego-app-photos --cdata " + urn )
                            container.notifyModel();
                        }

                        //For the context Menu
                        onPressAndHold:{
                            var pos = photoPreview.mapToItem(scene, mouse.x, mouse.y);

                            ctxMenuPhoto.currentUrn= urn
                            ctxMenuPhoto.currentUri=uri;
                            ctxMenuPhoto.menuPos = pos;
                            ctxMenuPhoto.setPosition(pos.x, pos.y);
                            ctxMenuPhoto.show();
                        }

                    }
                }
            }

            FrontPanelExpandableContent {
                id: fpecAlbumList
                anchors.top: fpecPhotoGrid.bottom
                visible: backSettingsModel.get(1).isVisible && (count > 0)
                text: qsTr("Albums")
                property int count: 0
                contents: ListView {
                    width: fpecAlbumList.width
                    interactive: false
                    model: allAlbumsListModel
                    height: count * (panelSize.contentItemHeight + 2)
                    onCountChanged: fpecAlbumList.count = count
                    Component.onCompleted: fpecAlbumList.count = count
                    delegate: FrontPanelPhotoIconItem {
                        id:albumPreview
                        imageSource: thumburi
                        text: title
                        onClicked: {
                            spinnerContainer.startSpinner();
                            appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showAlbum --fullscreen --app meego-app-photos --cdata " + urn)
                            container.notifyModel();
                        }

                        //For the context Menu
                        onPressAndHold:{
                            var pos = albumPreview.mapToItem(scene, mouse.x, mouse.y);

                            ctxMenuAlbum.currentUrn= urn
                            ctxMenuAlbum.setPosition(pos.x, pos.y);
                            ctxMenuAlbum.show();
                        }

                    }
                }
            }
        }

    }
    
}
