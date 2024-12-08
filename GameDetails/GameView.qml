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
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2
import QtQml.Models 2.10
import QtMultimedia 5.9
import "../Global"
import "../GridView"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root

    property var game: api.allGames.get(0)
    anchors.fill: parent


	Video {
		id: vid
		property bool videoExists: game ? game.assets.videoList.length : false
		visible : settings.VideoPreview === "Yes"

		source: (visible && videoExists) ? game.assets.videoList[0] : ""
		width: parent.width
		height: parent.width * 0.75
		anchors {
			top: parent.top; topMargin: - parent.height * 0.3
			left: parent.left;
		}

		fillMode: VideoOutput.PreserveAspectCrop
		muted: settings.AllowVideoPreviewAudio === "No"
		loops: MediaPlayer.Infinite
		autoLoad: visible
		autoPlay: visible
		opacity: details.visible ? 0.3 : 1
		Image {
			anchors.fill: parent
			source: "../assets/images/scanlines_v3.png"
			fillMode: Image.Tile
			opacity: 0.2 / parent.opacity
			visible: settings.ShowScanlines == "Yes"
		}
		// Mouse/touch functionality
		MouseArea {
			anchors.fill: parent
			hoverEnabled: settings.MouseHover == "Yes"
			onClicked: {
				sfxToggle.play();
				details.visible = !details.visible;
			}
		}
	}

	LinearGradient {
		anchors {
			left: parent.left; top: parent.top
		}
		width: parent.width
		height: vpx(120)
		start: Qt.point(0, 0)
		end: Qt.point(0, height)
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#FF000000" }
			GradientStop { position: 1.0; color: "#00000000" }
		}
	} 

	LinearGradient {
		anchors {
			left: parent.left; bottom: parent.bottom
		}
		width: parent.width
		height: vpx(150)
		start: Qt.point(0, height)
		end: Qt.point(0, 0)
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#FF000000" }
			GradientStop { position: 1.0; color: "#00000000" }
		}
	} 

    // Header
    Item {
    id: header

        anchors {
            left: parent.left; 
            right: parent.right
        }
        height: vpx(75)

        Image {
        id: platformLogo

            anchors {
                top: parent.top; topMargin: vpx(20)
                bottom: parent.bottom; bottomMargin: vpx(20)
                left: parent.left; leftMargin: globalMargin
            }
            fillMode: Image.PreserveAspectFit
            //source: "../assets/images/logospng/" + Utils.processPlatformName(game.collections.get(0).shortName) + ".png"
			source: "../assets/icons/" + Utils.processPlatformName(game.collections.get(0).shortName) + ".png"
            sourceSize { width: 256; height: 256 }
            smooth: true
            visible: true
            asynchronous: true           
        }

        // Platform title
        Text {
            
            text: game.collections.get(0).name
            
            anchors {
                top:    parent.top;
                left:   parent.left;    leftMargin: globalMargin
                right:  parent.right
                bottom: parent.bottom
            }
            
            color: theme.text
            font.family: titleFont.name
            font.pixelSize: vpx(30)
            font.bold: true
            horizontalAlignment: Text.AlignHLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            visible: platformLogo.status == Image.Error

            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: settings.MouseHover == "Yes"
                onClicked: previousScreen();
            }
        }
        z: 10
    }


    // Details screen
    Item {
    id: detailsScreen
        
        anchors.fill: parent

		Image {
		id: gameLogo
			anchors {
                bottom: parent.bottom; bottomMargin: globalMargin
			}
            width: parent.width * 0.2
            source: Utils.logo(game);
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
			visible: vid.opacity == 1
			opacity: visible ? 1 : 0
			x: visible ? parent.x + globalMargin : parent.width
            Behavior on x { NumberAnimation { duration: 300 } }
            Behavior on opacity { NumberAnimation { duration: 300 } }
		}
		DropShadow {
			anchors.fill: gameLogo
			horizontalOffset: vpx(2)
			verticalOffset: horizontalOffset
			radius: 8.0
			samples: 12
			color: "#000000"
			source: gameLogo
		}

        Item {
        id: details 

            anchors { 
                top: parent.top; topMargin: vpx(100)
                left: parent.left; leftMargin: vpx(70)
                right: parent.right; rightMargin: vpx(70)
				bottom: parent.bottom; bottomMargin: vpx(70)
            }

            Image {
            id: boxart
                source: Utils.boxArt(game);
                width: vpx(260)
                height: width / 0.7 //parent.height
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }

			Button { 
			id: playButton
				anchors {
					top: boxart.bottom; topMargin: vpx(25)
					horizontalCenter: boxart.horizontalCenter
				}
				text: "Play game"
				selected: true

				// Mouse/touch functionality
				MouseArea {
					anchors.fill: parent
					hoverEnabled: settings.MouseHover == "Yes"
					onClicked: {
						sfxAccept.play();
						launchGame(game);
					}
				}
			}

            GameInfo {
            id: info
                anchors {
                    left: boxart.right; leftMargin: vpx(30)
                    top: parent.top; bottom: parent.bottom; right: parent.right
                }
            }
        }
    }

	// Game menu
    // Input handling
    Keys.onPressed: {
        // Back
        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            previousScreen();
        }
        // Details
        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
            event.accepted = true;
			sfxToggle.play();
			details.visible = !details.visible;
        }
        // Filters
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
			sfxToggle.play();
            game.favorite = !game.favorite;
        }
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
			sfxAccept.play();
			launchGame(game);
			console.log("Game launched !!!!!!");
        }
    }

    // Helpbar buttons
    ListModel {
        id: gameviewHelpModel

        ListElement {
            name: "Back"
            button: "cancel"
        }
        ListElement {
            name: "Toggle details"
            button: "details"
        }
        ListElement {
            name: "Toggle favorite"
            button: "filters"
        }
        ListElement {
            name: "Play"
            button: "accept"
        }
    }
    
    onFocusChanged: { 
        if (focus) { 
            currentHelpbarModel = gameviewHelpModel;
        }
    }

}
