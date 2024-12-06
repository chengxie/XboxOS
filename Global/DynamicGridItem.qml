// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.8
import QtGraphicalEffects 1.12

Item {
id: root
    
    // NOTE: This is technically duplicated from utils.js but importing that file into every delegate causes crashes
    function steamAppID (gameData) {
        var str = gameData.assets.boxFront.split("header");
        return str[0];
    }

    function steamLogo(gameData) {
        return steamAppID(gameData) + "/logo.png"
    }


    function logo(data) {
    if (data != null) {
        if (data.assets.boxFront.includes("header.jpg")) 
            return steamLogo(data);
        else {
            if (data.assets.logo != "")
                return data.assets.logo;
            }
        }
        return "";
    }

    signal activate
    signal highlighted

	property bool showHighlightTitle: true
	property bool showTitle: true
	property int verticalSpacing: 0
	property int horizontalSpacing: 0
    property bool selected
    property var gameData: modelData

    // In order to use the retropie icons here we need to do a little collection specific hack
    property bool playVideo: gameData ? gameData.assets.videoList.length && (settings.AllowThumbVideo == "Yes") : ""
    property bool hideLogoForPlayVideo: settings.HideLogo == "Yes"

    scale: selected ? 1.1 : 1
    Behavior on scale { NumberAnimation { duration: 100 } }
    z: selected ? 10 : 1

    Item {
    id: container

		anchors {
			fill: parent
			bottomMargin: verticalSpacing
			rightMargin: horizontalSpacing
		}

        opacity: (selected && hideLogoForPlayVideo) ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 700 } }

        Image {
        id: screenshot

            anchors.fill: parent
            anchors.margins: vpx(2)
            source: modelData ? modelData.assets.screenshots[0] || modelData.assets.background || "" : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize { width: 512; height: 512 }
            smooth: false
            asynchronous: true
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Image {
        id: favelogo

            property var logoImage: (gameData && gameData.collections.get(0).shortName === "retropie") ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? logo(gameData) : gameData.assets.logo
            source: modelData ? logoImage || "" : ""
            sourceSize { width: 200; height: 150 }
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            z: 10

            // 根据选中状态调整位置和大小            
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: (selected && !hideLogoForPlayVideo) ? parent.width * 0.3 : parent.width * 0.8
            anchors.horizontalCenterOffset: (selected && !hideLogoForPlayVideo) ? - (parent.width / 2 - width / 2 - 10) : 0
            anchors.verticalCenterOffset: (selected && !hideLogoForPlayVideo) ? (parent.height / 2 - height / 2 - 10) : 0
            // 添加动画过渡效果
            Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 200 } }
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 200 } }

        }

        Rectangle {
        id: overlay
        
            anchors.fill: parent
            color: screenshot.source == "" ? theme.secondary : "black"
            //opacity: screenshot.source == "" ? 1 : selected ? 0.1 : 0.2
            opacity: (selected && playVideo && !hideLogoForPlayVideo) ? 0 : (screenshot.source == "") ? 0.5 : 0.2
        }
        
        Rectangle {
        id: regborder

            anchors.fill: parent
            color: "transparent"
            border.width: vpx(1)
            border.color: "white"
            opacity: 0.1
        }
        
    }

    Loader {
    id: borderloader

        active: selected
        anchors.fill: container
        sourceComponent: border
        asynchronous: true     
    }

    Component {
    id: border

		ItemBorder { 
			showTitle: showHighlightTitle
		}
    }

    Text {
    id: title
        anchors {
            top: container.bottom; topMargin: vpx(5)
            left: parent.left; right: parent.right
        }
        visible: showTitle && !selected
        text: modelData ? modelData.title : ''
        color: theme.text
        font {
            family: subtitleFont.name
            pixelSize: vpx(16)
            bold: false
        }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
    id: platformname

        text: modelData.title
        anchors { fill: parent; margins: vpx(10) }
        color: "white"
        scale: selected ? 1.1 : 1
        Behavior on opacity { NumberAnimation { duration: 100 } }
        font.pixelSize: vpx(18)
        font.family: subtitleFont.name
        font.bold: true
        style: Text.Outline; styleColor: theme.main
        visible: favelogo.status === Image.Null || favelogo.status === Image.Error
        anchors.centerIn: parent
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 0.8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
    id: favicon

        anchors { 
            right: parent.right; rightMargin: vpx(10); 
            top: parent.top; topMargin: vpx(10) 
        }
        width: parent.width / 12
        height: width
        radius: width/2
        color: theme.accent
        visible: gameData.favorite
        Image {
            source: "../assets/images/favicon.svg"
            asynchronous: true
            anchors.fill: parent
            anchors.margins: parent.width / 6
        }
    }

    Loader {
    id: spinnerloader

        anchors.centerIn: parent
        active: screenshot.status === Image.Loading
        sourceComponent: loaderspinner
    }

    Component {
    id: loaderspinner
    
        Image {        
            source: "../assets/images/loading.png"
            width: vpx(50)
            height: vpx(50)
            asynchronous: true
            sourceSize { width: vpx(50); height: vpx(50) }
            RotationAnimator on rotation {
                loops: Animator.Infinite;
                from: 0;
                to: 360;
                duration: 500
            }
        }
    }
    
    // List specific input
    Keys.onPressed: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            activate();        
        }
    }

    // Mouse/touch functionality
    MouseArea {
        anchors.fill: parent
        hoverEnabled: settings.MouseHover == "Yes"
        onEntered: { sfxNav.play(); highlighted(); }
        onClicked: {
            sfxNav.play();
            activate();
        }
        
        
    }
}
