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
    property string favIcon: game && game.favorite ? "../assets/images/icon_heart.svg" : "../assets/images/icon_unheart.svg"
    anchors.fill: parent

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
			opacity: 0.3
			Image {
				anchors.fill: parent
				source: "../assets/images/scanlines_v3.png"
				fillMode: Image.Tile
				opacity: 0.6
				visible: settings.ShowScanlines == "Yes"
			}
		}

        Item {
        id: details 

            anchors { 
                top: parent.top; topMargin: vpx(100)
                left: parent.left; leftMargin: vpx(70)
                right: parent.right; rightMargin: vpx(70)
				bottom: parent.bottom; bottomMargin: vpx(70)
            }
            //height: vpx(450) - header.height

            Image {
            id: boxart

                source: Utils.boxArt(game);
                width: vpx(260)
                height: width / 0.7 //parent.height
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }

			ListView {
			id: menu

				//property bool selected: parent.focus
				focus: true
				width: playButton.width + favoriteButton.width + spacing
				height: vpx(50)
				anchors {
					top: boxart.bottom; topMargin: vpx(25)
					left: boxart.left; leftMargin: (boxart.width - width) / 2
				}
				orientation: ListView.Horizontal
				spacing: vpx(10)
				keyNavigationWraps: true

				model: ObjectModel {

					Button { 
					id: playButton
						text: "Play game"
						height: parent.height
						selected: ListView.isCurrentItem && menu.focus
						onHighlighted: { menu.currentIndex = ObjectModel.index; }
						onActivated: 
							if (selected) {
								sfxAccept.play();
								launchGame(game);
							} else {
								sfxNav.play();
								menu.currentIndex = ObjectModel.index;
							}
					}

					Button { 
					id: favoriteButton
						property string buttonText: game && game.favorite ? "Unfavorite" : "Add favorite"
						icon: favIcon
						height: parent.height
						selected: ListView.isCurrentItem && menu.focus
						onHighlighted: { menu.currentIndex = ObjectModel.index; }
						onActivated: {
							if (selected) {
								sfxToggle.play();
								game.favorite = !game.favorite;
							} else {
								sfxNav.play();
								menu.currentIndex = ObjectModel.index;
							}
						}
					}
				}

				Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
				Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
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
        // Filters
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
			sfxToggle.play();
            game.favorite = !game.favorite;
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
            name: "Toggle favorite"
            button: "filters"
        }
        ListElement {
            name: "Launch"
            button: "accept"
        }
    }
    
    onFocusChanged: { 
        if (focus) { 
            currentHelpbarModel = gameviewHelpModel;
            menu.focus = true;
            menu.currentIndex = 0; 
        }
    }

}
