/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Content 1.0
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: fpContainer

    Translator {
        catalog: "meego-ux-panels-friends"
    }

    property Component frontComponent: ((panelManager.servicesConfigured && !panelManager.isEmpty) ? fpcNormal : fpcOOBE)

    front: SimplePanel {
        id: frontPanel
        panelTitle: qsTr("Friends")
        panelComponent: frontPanelContent
        leftIconSource: "image://theme/panels/pnl_icn_friends"
    }

    back: BackPanelGeneric {
        id: backPanel
        panelTitle: qsTr("Friends settings")
        subheaderText: qsTr("Friends panel content")
        bpContent: backPanelContent
        isBackPanel: true
        leftIconSource: "image://theme/panels/pnl_icn_friends"
    }

    onFlipToFront: {
        panelManager.frozen = false;
        refreshTimer.stop();
    }

    TopItem {
        id: topItem
        parent: fpContainer
    }

    resources: [

        Timer {
            id: refreshTimer
            interval: 30000
            onTriggered: {
                panelManager.frozen = false;
            }
        }
    ]


    Component.onCompleted: {
        panelManager.initialize("friends");
    }

    McaPanelManager {
        id: panelManager
        categories: ["social", "im", "email", "messages"]
        servicesEnabledByDefault: true
    }


    Component {
        id: frontPanelContent
        Loader {
            id: frontPanelLoader
            sourceComponent: frontComponent
        }
    }

    Component {
        id: fpcOOBE
        Item {
            height: fpContainer.height
            width: fpContainer.width

            Text {
                id: textOOBE
                anchors.left: parent.left
                anchors.right:  parent.right
                anchors.top: parent.top
                anchors.topMargin: panelSize.contentTopMargin
                anchors.leftMargin: panelSize.contentSideMargin
                anchors.rightMargin: panelSize.contentSideMargin
                width: parent.width
                text: qsTr("You have no web accounts enabled - tap here to configure your web accounts.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: panelColors.textColor
            }

            Button {
                id: btnOOBE
                anchors.top:  textOOBE.bottom
                anchors.topMargin: panelSize.contentTopMargin
                text: qsTr("Tap here!")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    spinnerContainer.startSpinner();
                    appsModel.launch("/usr/bin/meego-qml-launcher --opengl --app meego-ux-settings --fullscreen --cmd showPage --cdata \"Web Accounts\"")
                }
            }
        }
    }

    Component {
        id: fpcNormal

        Item {
            id: fpcNormalContent
            anchors.fill: parent

            ListView {
                model: panelManager.feedModel
                delegate: recentUpdatesDelegate
                anchors.fill: parent
                interactive: (contentHeight > height)
                onInteractiveChanged: {
                    if (!interactive)
                        contentY = 0;
                }

                clip: true
                onMovementStarted:  {
                    panelManager.frozen = true;
                    refreshTimer.stop()
                }

                onMovementEnded: {
                    refreshTimer.restart()
                }
            }


            ContextMenu {
                id: ctxMenu
                property alias ctxModel: ctxActionMenu.model
                property alias ctxPayload: ctxActionMenu.payload

                content: ActionMenu {
                    id: ctxActionMenu

                    onTriggered: {
                        panelManager.frozen = false;
                        if (model[index] == qsTr("View")) {
                            spinnerContainer.startSpinner();
                            payload[0].performStandardAction("default", payload[1]);
                        } else if (model[index] == qsTr("Hide")) {
                            payload[0].performStandardAction("hide", payload[1]);
                        } else {
                            console.log("Unhandled context action in Friends: " + model[index]);
                        }
                        ctxMenu.hide();
                    }
                }
            }

            resources: [
	        FuzzyDateTime {
		    id: fuzzyDateTime
		},

                Component {
                    id: recentUpdatesDelegate
                    FriendsItem {
                        id: friendsItemDel
                        serviceName: servicename
                        serviceIcon: serviceicon
                        authorIcon: (avatar == undefined ? "" : avatar)
                        authorName: title
                        messageText: content
                        picImage: picture
                        timeStamp: fuzzyDateTime.getFuzzy(timestamp)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        itemID: id
                        itemType: type

                        onPressAndHold: {
                            //console.log("got to onPressAndHold! Yay!" + myID);
                            if (type == "request")
                                ctxMenu.ctxModel = [qsTr("Hide")];
                            else
                                ctxMenu.ctxModel = [qsTr("View"), qsTr("Hide")]
                            ctxMenu.ctxPayload = [actions, myID];

                            var mousePos = friendsItemDel.mapToItem(topItem.topItem, mouse.x, mouse.y);

                            ctxMenu.setPosition(mousePos.x, mousePos.y);
                            ctxMenu.show();
                        }
                        onClicked: {
                            //console.log("got to onClicked! Yay!" + myID);
                            spinnerContainer.startSpinner();
                            actions.performStandardAction("default", myID);
                        }
                        onAcceptClicked: {
                            //console.log("Accept clicked for ID " + myID);
                            actions.performStandardAction("accept", myID);
                        }
                        onRejectClicked: {
                            //console.log("Reject clicked for ID " + myID);
                            actions.performStandardAction("reject", myID);
                        }
                    }
                }
            ]
        }
    }


    Component {
        id: backPanelContent

        Item {
            width: parent.width
            height: lvServices.height
            Column {
                id: lvServices
                width: parent.width
                Repeater {
                    model: panelManager.serviceModel
                    delegate: servicesDelegate
                }
            }

            Connections {
                target:  back
                onClearHistClicked: {
                    mdlClearHist.show();
                }
            }

            ModalFog {
                id: mdlClearHist
                autoCenter: true
                modalSurface: BorderImage {
                    id: rectClearHist
                    source: "image://theme/notificationBox_bg"
                    border.top: 14
                    border.left: 20
                    border.right: 20
                    border.bottom: 20
                    width: panelSize.oneHalf
                    height: panelSize.baseSize
                    anchors.centerIn: parent

                    property variant svcsToClear: []

                    function setClearHist(svcUpid, enabled) {
                        console.log("setClearHist called for " + svcUpid + ", val " + enabled);
                        var x;
                        var foundIt;

                        for (x in svcsToClear) {
                            if (svcsToClear[x] == svcUpid) {
                                foundIt = true;
                                if (enabled) {
                                    break;
                                } else {
                                    //Remove the item
                                    svcsToClear = svcsToClear.splice(x, 1);
                                    break;
                                }
                            }
                        }
                        if (enabled && !foundIt) {
                            svcsToClear = svcsToClear.concat(svcUpid);
                        }
                    }

                    Item {
                        id: mdlClearHeader
                        height: (textClear.height + bpdTextClear.height + bpdTextClear.topMargin)
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: panelSize.contentTopMargin
                        Text {
                            id: textClear
                            anchors.left: parent.left
                            anchors.leftMargin: panelSize.contentSideMargin
                            anchors.right: parent.right
                            anchors.rightMargin: panelSize.contentSideMargin
                            text: qsTr("Clear history from:")
                            font.pixelSize: theme_fontPixelSizeLarge
                            wrapMode: Text.NoWrap
                            elide: Text.ElideNone
                            clip: true
                        }

                        BackPanelDivider {
                            id: bpdTextClear
                            width: parent.width
                            anchors.top: textClear.bottom
                            anchors.topMargin: panelSize.contentTopMargin
                        }
                    }

                    ListView {
                        id: lvClearSvcs
                        width: parent.width
                        anchors.top: mdlClearHeader.bottom
                        anchors.topMargin: panelSize.oneTenth
                        anchors.bottom: btnModalClear.top
                        anchors.bottomMargin: panelSize.oneTenth
                        interactive: (height < contentHeight)
                        model: panelManager.serviceModel
                        clip: true
                        delegate: Item {
                            width: parent.width
                            height: (textDName.height + bpdDel.height + bpdDel.anchors.topMargin + 10)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    ckBox.isChecked = !ckBox.isChecked
                                }
                            }

                            CheckBox {
                                id: ckBox
                                isChecked: false
                                anchors.left: parent.left
                                anchors.leftMargin: panelSize.contentSideMargin
                                anchors.verticalCenter: parent.verticalCenter
                                onIsCheckedChanged: {
                                    rectClearHist.setClearHist(upid, isChecked);
                                }
                            }

                            Text {
                                id: textDName
                                text: displayname
                                font.pixelSize: theme_fontPixelSizeLarge
                                anchors.left: ckBox.right
                                anchors.leftMargin: panelSize.contentSideMargin
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: panelSize.contentSideMargin
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                            }

                            BackPanelDivider {
                                id: bpdDel
                                anchors.top: textDName.bottom
                                anchors.topMargin: panelSize.contentTopMargin
                            }
                        }
                    }

                    Button {
                        id: btnModalClear
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: panelSize.contentTopMargin
                        text: qsTr("Clear")
                        onClicked: {
                            var x;
                            for (x in rectClearHist.svcsToClear) {
                                panelManager.clearHistory(rectClearHist.svcsToClear[x]);
                            }
                            mdlClearHist.hide();
                        }
                    }
                }
            }
        }
    }


    Component {
        id: servicesDelegate

        BackPanelContentItem {
            id: contentDel
            contentHeight: svcButtonLoader.height + svcButtonLoader.anchors.topMargin + svcButtonLoader.anchors.bottomMargin
            Text {
                id: nameText
                anchors.left: parent.left
                anchors.leftMargin: panelSize.contentSideMargin
                anchors.right: svcButtonLoader.left
                anchors.rightMargin: panelSize.contentSideMargin
                text: displayname
                color: panelColors.textColor
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: theme_fontPixelSizeLarge
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }

            Loader {
                id: svcButtonLoader
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: nameText.anchors.leftMargin
                anchors.topMargin: (anchors.rightMargin/2)  //THEME - VERIFY
                anchors.bottomMargin: anchors.topMargin
            }

            Component {
                id: serviceToggle

                ToggleButton {
                    id: tbEnable
                    anchors.right: parent.right
                    on: panelManager.isServiceEnabled(upid)
                    onToggled: {
                        console.log("Setting " + name + " to " + (isOn ? "enable" : "disable"));
                        panelManager.setServiceEnabled(upid, isOn);
                    }
                }
            }

            Component {
                id: serviceConfigBtn
                Button {
                    id: btnConfigure
                    anchors.right: parent.right
                    text: qsTr("Go to settings")
                    onClicked: {
                        actions.performStandardAction("configure", name);
                    }
                }
            }

            Component.onCompleted: {
                if (configerror) {
                    svcButtonLoader.sourceComponent = serviceConfigBtn;
                } else {
                    svcButtonLoader.sourceComponent = serviceToggle;
                }
            }
        }
    }
}
