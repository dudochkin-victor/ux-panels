/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Panels 0.1

import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1


Labs.Window {
    id: scene
    anchors.centerIn: parent
    showtoolbar: false
    fullContent: true
    fullscreen: true

    // Since this window is inside the meego-ux-daemon process, which
    // managages multiple top level windows, we can't use the normal 
    // orientation locking mechanism.  The following is a hack till
    // a proper per-window orientation mechanism lands in MeeGo.Components
    orientationLocked: true
    Connections {
        target: mainWindow
        onOrientationChanged: scene.orientation = mainWindow.orientation
    }

    Translator {
        catalog: "meego-ux-panels"
    }


    //Temp to get a spinner in for UX review - BEGIN
    //Now we should be able to do "spinnerContainer.startSpinner();"

    Item {
        id: spinnerContainer
        parent: scene.content
        anchors.fill: scene.content
        property variant overlay: null

        TopItem {
            id: topItem
        }

        Component {
            id: spinnerOverlayComponent
            Item {
                id: spinnerOverlayInstance
                anchors.fill: parent

                Connections {
                    target: qApp
                    onWindowListUpdated: {
                        spinnerOverlayInstance.destroy();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                }
                Labs.Spinner {
                    anchors.centerIn: parent
                    spinning: true
                    onSpinningChanged: {
                        if (!spinning)
                        {
                            spinnerOverlayInstance.destroy()
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    // eat all mouse events
                }
            }
        }

        function startSpinner() {
            if (overlay == null)
            {
                overlay = spinnerOverlayComponent.createObject(spinnerContainer);
                overlay.parent = topItem.topItem;
            }
        }
    }

    //Temp to get a spinner in for UX review - END

    //onStatusBarTriggered: orientation = (orientation +1)%4;

    PanelProxyModel {
        id: panelsModel
        filterType: PanelProxyModel.FilterTypeHidden
        sortType: PanelProxyModel.SortTypeIndex
    }

    Labs.ApplicationsModel {
        id: appsModel
        directories: [ "/usr/share/meego-ux-appgrid/applications", "/usr/share/applications", "~/.local/share/applications" ]
    }

    Labs.WindowModel {
        id: windowModel
    }

    Loader {
        id: appSwitcherLoader
    }

    Image {
        opacity: 0
        source: "image://theme/panels/pnl_bg"
        width: sourceSize.width
        height: sourceSize.height
        asynchronous: false
        onStatusChanged: {
            if ((status == Image.Ready) && visible) {
                panelSize.baseSize = width;
                source = "";
                visible = false;
            }
        }
    }

    Item {
        id: panelSize
        property int baseSize: 0
        property int oneHalf: Math.round(baseSize/2)
        property int oneThird: Math.round(baseSize/3)
        property int oneFourth: Math.round(baseSize/4)
        property int oneSixth: Math.round(baseSize/6)
        property int oneEigth: Math.round(baseSize/8)
        property int oneTenth: Math.round(baseSize/10)
        property int oneTwentieth: Math.round(baseSize/20)
        property int oneTwentyFifth: Math.round(baseSize/25)
        property int oneThirtieth: Math.round(baseSize/30)
        property int oneSixtieth: Math.round(baseSize/60)
        property int oneEightieth: Math.round(baseSize/80)
        property int oneHundredth: Math.round(baseSize/100)

        property int panelOuterSpacing: oneTwentieth
        property int contentItemHeight: oneSixth
        property int contentSideMargin: oneThirtieth	//verify
        property int contentTopMargin: oneSixtieth	//verify
        property int contentIconSize: oneEigth		//verify
    }

    Item {
        id: panelColors
        property string textColor: theme_buttonFontColor
        property string separatorColor: theme_lockscreenDateFontDropshadowColor
    }

    Item {
        id: deviceScreen
        parent: scene.content
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        clip: true

        ShareObj {
            id: shareObj
        }

        Rectangle {
            id: background
            anchors.fill: parent
            color: "black"
            property variant backgroundImage: null
            Labs.BackgroundModel {
                id: backgroundModel
                Component.onCompleted: {
                    background.backgroundImage = backgroundImageComponent.createObject(background);
                }
                onActiveWallpaperChanged: {
                    background.backgroundImage.destroy();
                    background.backgroundImage = backgroundImageComponent.createObject(background);       
                }
            }
            Component {
                id: backgroundImageComponent
                Image {
                    //anchors.centerIn: parent
                    anchors.fill: parent
                    asynchronous: true
                    source: backgroundModel.activeWallpaper
                    sourceSize.height: background.height
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
        StatusBar {
            anchors.top: parent.top
            width: parent.width
            height: theme_statusBarHeight
            active: scene.foreground
            backgroundOpacity: theme_panelStatusBarOpacity
        }

        Item {
            id: panelsContainer
            anchors.fill: parent
            anchors.topMargin: theme_statusBarHeight

            Flickable{
                id: panelsContainerFlickable
                anchors.fill: parent

                anchors.topMargin : panelSize.panelOuterSpacing

                width: parent.width
                height: parent.height

                contentWidth: allPanels.width
                property int currentItemIndex: -1

                Behavior on contentWidth {
                    NumberAnimation { duration:500 }
                }

                ListView {                    
                    interactive: false
                    width: contentWidth
                    height: parent.height
                    orientation: ListView.Horizontal
                    spacing: panelSize.panelOuterSpacing
                    id: allPanels
                    //property int currentItemIndex: -1
                    property bool animationEnabled: true
                    model:panelsModel
                        delegate: Loader {
                            id: contentLoader
                            source: path

                            height: parent.height
                            //width: 640
                            property QtObject aPanelObj: panelObj
                            property string aDisplayName: displayName
                            property int aIndex: index

                            Component.onCompleted: {
                                console.log("displayName: " + displayName + ", index: " + index)
                            }


                            Behavior on opacity{
                                NumberAnimation { duration:250 }
                            }

                            Behavior on x {
				id:moveSlowly
				enabled: allPanels.animationEnabled 
                                NumberAnimation { duration: 250}
                            }

                            Behavior on width {
                                NumberAnimation { duration:250 }
                            }

                            onOpacityChanged :{
                                if ( opacity == 0 )
                                {
                                    panelsModel.remove(index)
                                    panelsContainerFlickable.contentWidth
                                    = panelsContainerFlickable.contentWidth -(item.width + panelView.spacing)
                                }

                            }

                            onLoaded:{
                                //contentLoader.item.panelObj = panelObj
                            }


                            Connections {
                                target: contentLoader.item
                                onVisibleOptionClicked:{
                                    if (allowHide) {
                                        panelObj.IsVisible = false;
                                    }
                                }

                                /*
                                onStartDrag: {
                                    allPanels.currentItemIndex = index
                                }*/

/*
                                onWidthDistanceDragged: {

                                    if (item.moveDirection )
                                    {
                                        panelView.children[allPanels.currentItemIndex].x=
                                                panelView.children[allPanels.currentItemIndex].x
                                        - ( panelView.children[allPanels.currentItemIndex].width
                                            + panelView.spacing )

                                        allPanels.currentItemIndex= allPanels.currentItemIndex+1
                                    }
                                    else{

                                        panelView.children[allPanels.currentItemIndex-1].x=
                                                panelView.children[allPanels.currentItemIndex-1].x +
                                                panelView.children[allPanels.currentItemIndex-1].width + panelView.spacing
                                        allPanels.currentItemIndex= allPanels.currentItemIndex-1
                                    }
                                }
*/
                                onDraggingFinished:{

                                    console.log("------------oldIdx: " + oldIndex + ", newIdx: " + newIndex)
                                    panelsModel.move(oldIndex, newIndex)
//                                    var x;
//                                    for (x in panelView.children) {
//                                        panelView.children[x].x = x * (panelView.spacing + panelView.children[x].width)
//                                    }

//                                    var moveIndex=allPanels.currentItemIndex
//                                    if (index == allPanels.currentItemIndex)
//                                    {
//                                    return;
//                                    }
//                                    else if (index < allPanels.currentItemIndex)
//                                    {
//                                     moveIndex=allPanels.currentItemIndex-1
//                                    }
//                                    else
//                                    {
//                                     moveIndex=allPanels.currentItemIndex
//                                    }

//                                    allPanels.animationEnabled=false
//                                     panelView.children[index].x=
//                                    allPanels.currentItemIndex * (panelView.spacing
//                                    +panelView.children[allPanels.currentItemIndex].width)
//                                    allPanels.animationEnabled=true

                                } //onDraggingFinished
                            }
                        }
                    } //ListView/Repeater
                //} //Row

            }
        }
    }
}

