/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: fpec

    width: parent.width
    height: visible? (showHeader ? fpsubheader.height : 0 ) + fpContents.height : 0

    property alias text: fpsubheader.text
    property alias collapsible: fpsubheader.arrowVisible
    property alias contents: fpContents.sourceComponent
    property alias showHeader: fpsubheader.visible

    //If set, forces a set loader height, using maxLoaderHeight
    property bool useFixedLoaderHeight: false
    //If maxLoaderHeight is 0, and useFixedLoaderHeight is false
    //then the loader dynamically auto-resizes to the content height,
    //and can grow infinitely
    //If maxLoaderHeight is != 0, and useFixedLoaderHeight is false
    //then the loader dynamically auto-resizes up to a max of maxLoaderHeight
    property int maxLoaderHeight: 0

    signal collapsedChanged(bool collapsed)

    function calcLoaderHeight() {

        var newHeight;
        //If we're in fixed mode, just set it
        if (useFixedLoaderHeight) {
            newHeight = maxLoaderHeight;
        } else if (maxLoaderHeight == 0) {
            //If no max is set, grow to fit
            newHeight = fpContents.item.height;
        } else if (fpContents.item.height > maxLoaderHeight) {
            newHeight = maxLoaderHeight;
        } else {
            newHeight = fpContents.item.height;
        }
        //console.log("calcLoaderHeight, old: " + privateData.savedHeight + ", new: " + newHeight);

        privateData.savedHeight = newHeight;
    }

    function calcAndSet() {
        if (!privateData.inAni && !fpsubheader.collapsed) {
            calcLoaderHeight();
            fpContents.height = privateData.savedHeight;
        }
    }

    Component.onCompleted: {
        //console.log("C.onComp, calling calcAndSet");
        calcAndSet();
    }

    Connections {
        target: fpContents.item
        onHeightChanged: {
            //console.log("fpContents.item height changed, new height: " + fpContents.item.height)
            if (!fpsubheader.collapsed) {
                //console.log("fpContents.item height changed, doing calcAndSet")
                calcAndSet();
            }
        }
    }

    Item {
        id: privateData
        property int savedHeight
        property bool inAni: false
    }

    FrontPanelSubHeader{
        id:fpsubheader
        visible: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z:1

        property bool collapsing: false

        onCollapsedChanged: {
            collapsing = true;
            if (collapsed) {
                fpContents.height = 0;
            } else {
                fpContents.height = privateData.savedHeight;
            }
            fpec.collapsedChanged(collapsed);
        }
    }

    Loader{

        id:fpContents
        z:fpsubheader.z-1

        anchors.top: (showHeader ? fpsubheader.bottom : parent.top)
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        Behavior on height {
            id: collapseAnimation
            enabled: fpsubheader.collapsing
            SequentialAnimation {
                ScriptAction { script: { privateData.inAni = true; } }
                NumberAnimation { duration: 100 }
                ScriptAction { script: { privateData.inAni = false; calcAndSet(); fpsubheader.collapsing = false;} }
            }
        }

    }
}
