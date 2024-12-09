//import QtQuick 2.3
//import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtGraphicalEffects 1.15

import QtMultimedia 5.9
import QtQml.Models 2.10
import "../Global"
import "../utils.js" as Utils

FocusScope {
id: root

	property var collection
	property var gameList: collection.search
    property alias currentIndex: featuredList.currentIndex
    property bool ftue: gameList.games.count == 0
    property real gameVideoRatio: 0.75
    property real gameVideoWidth: root.width * 0.75
    property real gameVideoHeight: gameVideoWidth * gameVideoRatio


	//height: gameVideoHeight // parent.height //
	//signal activate

    Item {
    id: ftueContainer

        width: parent.width
        height: parent.height + header.height
		anchors {
			left: parent.left
			bottom: parent.bottom; bottomMargin: -vpx(5)
		}
        visible: ftue
        opacity: {
            switch (mainList.currentIndex) {
                case 0:
                    return 1;
                case 1:
                    return 0.3;
                case 2:
                    return 0.1;
                case -1:
                    return 0.3;
                default:
                    return 0
            }
        }

        //Image {
            //anchors.fill: parent
            //source: "../assets/images/ftueBG01.jpeg"
            //sourceSize { width: root.width; height: root.height}
            //fillMode: Image.PreserveAspectCrop
            //smooth: true
            //asynchronous: true
        //}

        Video {
        id: videocomponent

            anchors.fill: parent
            source: "../assets/video/ftue.mp4"
            fillMode: VideoOutput.PreserveAspectCrop
            muted: true
            loops: MediaPlayer.Infinite
            autoPlay: true
            OpacityAnimator {
                target: videocomponent;
                from: 0;
                to: 1;
                duration: 1000;
                running: true;
            }
        }

        Image {
        id: ftueLogo

            width: vpx(350)
            source: "../assets/images/RetroArch_logo.png"
            sourceSize { width: 350; height: 250}
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
			anchors {
				verticalCenter: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}
        }

        Text {
            text: "Try adding some favorite games"
            
            horizontalAlignment: Text.AlignHCenter
            anchors { bottom: parent.bottom; bottomMargin: vpx(75) }
            width: parent.width
            height: contentHeight
            color: theme.text
            font.family: subtitleFont.name
            font.pixelSize: vpx(16)
            opacity: 0.5
            visible: false
        }
    }
	

	ListView {
	id: featuredList

		focus: root.focus
		anchors.fill: parent
		orientation: ListView.Horizontal
		preferredHighlightBegin: vpx(0)
		preferredHighlightEnd: parent.width
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 200
		snapMode: ListView.SnapOneItem
		keyNavigationWraps: true

        onFocusChanged: {
            if (focus) {
                currentIndex = collection.index;
			} else {
                collection.index = currentIndex;
            }
        }

		Component.onDestruction: {
			collection.index = currentIndex;
		}
		Component.onCompleted: {
			currentIndex = collection.index
			positionViewAtIndex(currentIndex, ListView.Visible)
		}

        model: !ftue ? gameList.games : null
		delegate: featuredDelegate

		Component {
		id: featuredDelegate

			Item {
			id: featuredItem
				property var game: modelData
				width: featuredList.width
				height: featuredList.height

				Video {
				id: vid
					property bool videoExists: game ? game.assets.videoList.length : false
					source: videoExists ? game.assets.videoList[0] : ""

					width: parent.width //gameVideoWidth
					height: gameVideoHeight
					//height: parent.width * 0.75
					anchors {
						//top: parent.top; topMargin: root.height * 0.1
						bottom: parent.bottom; bottomMargin: -vpx(5)
						right: parent.right 
					}

					fillMode: VideoOutput.PreserveAspectCrop
					muted: settings.AllowVideoPreviewAudio === "No"
					loops: MediaPlayer.Infinite
					autoLoad: true
					autoPlay: true
					opacity: featuredList.focus ? 1 : 0.3
					Image {
						anchors.fill: parent
						source: "../assets/images/scanlines_v3.png"
						fillMode: Image.Tile
						opacity: 0.2
						visible: settings.ShowScanlines == "Yes"
					}
				}

				LinearGradient {
					width: vid.width * 0.6
					height: vid.height
					anchors {
						top: vid.top
						left: vid.left;
					}
					start: Qt.point(0, 0)
					end: Qt.point(width, 0)
					gradient: Gradient {
						//GradientStop { position: -0.05; color: "#FF000000" }
						GradientStop { position: 0.0; color: "#FF000000" }
						GradientStop { position: 1.0; color: "#00000000" }
					}
				}

				LinearGradient {
					width: vid.width
					height: vid.height * 0.1
					anchors {
						left: vid.left;
						bottom: vid.bottom;
					}
					start: Qt.point(0, height)
					end: Qt.point(0, 0)
					gradient: Gradient {
						GradientStop { position: -0.1; color: "#FF000000" }
						GradientStop { position: 1.0; color: "#00000000" }
					}
				}


				Item {
				id: gameInfo
					anchors {
						top: parent.top; topMargin: root.height * 0.1
						bottom: parent.bottom;
						left: parent.left; leftMargin: vpx(100)
						right: parent.right; rightMargin: vpx(100)
					}
					//color: "transparent"
					opacity: featuredList.focus ? 1 : 0.3

					Image {
					id: gameLogo
						height: vpx(100)
						anchors { 
							top: parent.top; left: parent.left;
							leftMargin: {
								if (gameTitle.width > width) {
									return (gameTitle.width - width) / 2
								}
								return 0;
								//return Math.max(0, vpx(50) + (parent.width - vpx(100)) * 0.15 - width / 2)
							}
						}
						source: Utils.logo(game)
						fillMode: Image.PreserveAspectFit
						asynchronous: true
						smooth: true
					}

					Text {
					id: gameTitle

						text: game && game.title 
						anchors { 
							top: gameLogo.bottom; topMargin: vpx(20)
							horizontalCenter: gameLogo.horizontalCenter
						}                            
						font {
							pixelSize: vpx(28)
							family: subtitleFont.name
							bold: true
						}
						color: theme.text
						style: Text.Outline; 
						styleColor: theme.primary
						elide: Text.ElideRight
						wrapMode: Text.WordWrap
						//lineHeight: 0.8
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}

					Text {
					id: gameDescription
						text: (game && game.description) || "No description available"
						width: parent.width * 0.4
						height: parent.height * 0.3

						anchors {
							top: gameTitle.bottom; topMargin: vpx(25)
							left: parent.left
						}
						font {
							pixelSize: vpx(18)
							family: bodyFont.name
						}
						color: theme.text
						wrapMode: Text.WordWrap
						elide: Text.ElideRight
					}
				}

				DropShadow {
					source: gameInfo
					anchors.fill: gameInfo
					horizontalOffset: vpx(2)
					verticalOffset: horizontalOffset
					radius: 8.0
					samples: 12
					color: "#000000"
				}

				// Mouse/touch functionality
				MouseArea {
					anchors.fill: parent
					hoverEnabled: settings.MouseHover == "Yes"
					onEntered: { sfxNav.play(); mainList.currentIndex = 0; }
					onClicked: {
						if (selected)
							gameDetailsScreen(modelData);  
						else
							mainList.currentIndex = 0;
					}
				}

			}
			
		}

		Row {
		id: blips

			anchors.horizontalCenter: parent.horizontalCenter
			anchors { bottom: parent.bottom; bottomMargin: vpx(50) }
			spacing: vpx(10)
			Repeater {
				model: featuredList.count
				Rectangle {
					width: vpx(10)
					height: width
					color: (featuredList.currentIndex == index) && featuredList.focus ? theme.accent : theme.text
					radius: width/2
					opacity: (featuredList.currentIndex == index) ? 1 : 0.5
				}
			}
		}

		// List specific input
		Keys.onUpPressed: { sfxNav.play(); headerMenu.focus = true; }
		Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
		Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

		Keys.onPressed: {
			//Accept
			if (api.keys.isAccept(event) && !event.isAutoRepeat) {
				event.accepted = true;
				if (!ftue) {
					sfxAccept.play();
					gameDetailsScreen(gameList.currentGame(currentIndex));            
				}
			}
		}

	}


}
