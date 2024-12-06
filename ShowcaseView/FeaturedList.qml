import QtQuick 2.3
//import QtQuick.Layouts 1.11
//import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10
import "../Global"
import "../utils.js" as Utils

FocusScope {
id: root

	property var collection
	property int modelIndex: 0
    property bool ftue: collection.games.count == 0
    property real gameVideoRatio: 0.75
    property real gameVideoWidth: root.width * 0.75
    property real gameVideoHeight: gameVideoWidth * gameVideoRatio

    property alias featuredList: featuredList

    anchors.fill: parent
	//height: gameVideoHeight // parent.height //
	//signal activate

    Item {
    id: ftueContainer

        //width: parent.width
        //height: vpx(360)
		anchors.fill: parent
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
        Behavior on opacity { 
            PropertyAnimation { 
                duration: 1000; 
                easing.type: Easing.OutQuart; 
                easing.amplitude: 2.0; 
                easing.period: 1.5
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

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }

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
	
	property int currentButton: 0
	property bool insideFocus: false

	ListView {
	id: featuredList

		focus: root.focus
		anchors.fill: parent
		//width: parent.width
		//height: gameVideoHeight
		orientation: ListView.Horizontal
		preferredHighlightBegin: vpx(0)
		preferredHighlightEnd: parent.width
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 200
		snapMode: ListView.SnapOneItem
		keyNavigationWraps: true

		currentIndex: (storedHomePrimaryIndex == 0) ? storedHomeSecondaryIndex : 0
		Component.onCompleted: {
			positionViewAtIndex(currentIndex, ListView.Visible)
		}

		model: !ftue ? collection.games : null
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




				Image {
				id: gameLogo
					height: vpx(100)
					anchors { 
						top: parent.top; topMargin: root.height * 0.1
						left: parent.left; leftMargin: vpx(50) + (parent.width - vpx(100)) * 0.15 - width / 2
					}
					source: Utils.logo(game)
					fillMode: Image.PreserveAspectFit
					asynchronous: true
					opacity: featuredList.focus ? 1 : 0.3

					Component.onCompleted: {
						logoAnim.start()
					}

					onSourceChanged: {
						logoAnim.start()
					}

					PropertyAnimation { 
					id: logoAnim; 
						target: gameLogo; 
						property: "y"; 
						from: root.top - height; 
						to: root.height * 0.19;
						duration: 100
					}
				}

				Text {
				id: gameTitle

					text: game && game.title 
					anchors { 
						top: gameLogo.bottom; topMargin: vpx(20)
						horizontalCenter: gameLogo.horizontalCenter
					}                            
					font {
						pixelSize: vpx(24)
						family: subtitleFont.name
						bold: true
					}
					color: theme.text
					style: Text.Outline; 
					styleColor: theme.main
					elide: Text.ElideRight
					wrapMode: Text.WordWrap
					lineHeight: 0.8
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					opacity: featuredList.focus ? 1 : 0.3
				}

				Text {
				id: gameDescription
					text: (game && game.description) || "No description available"
					width: (parent.width - vpx(200)) * 0.4
					height: parent.height * 0.22

					anchors {
						top: gameTitle.bottom; topMargin: vpx(25)
						left: parent.left; leftMargin: vpx(100)
					}
					font {
						pixelSize: vpx(18)
						family: bodyFont.name
					}
					color: theme.text
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
					opacity: featuredList.focus ? 1 : 0.3
				}

				Item {

					focus: featuredList.focus && insideFocus
					anchors {
						top: gameDescription.bottom; topMargin: vpx(25)
						left: gameDescription.left;
					}

					Button { 
					id: buttonPlay
						text: "Play game"
						anchors {
							top: parent.top
							left: parent.left;
						}
						selected: featuredList.focus && insideFocus && currentButton == 0
					}

					Button { 
					id: buttonDetails
						icon: "../assets/images/icon_details.svg"
						anchors {
							top: parent.top
							left: parent.left; leftMargin: buttonPlay.width + vpx(10);
						}
						selected: featuredList.focus && insideFocus && currentButton == 1
					}

					Keys.onPressed: {
						// Accept
						//sfxNav.play();
						//sfxAccept.play();
						if (api.keys.isAccept(event) && !event.isAutoRepeat) {
							event.accepted = true;

							switch (currentButton) {
								case 0:
									sfxAccept.play();
									launchGame(game);
									break;
								case 1:
									currentButton = 0;
									storedHomeSecondaryIndex = featuredList.currentIndex;
									gameDetails(collection.currentGame(featuredList.currentIndex));            
									break;
							}
						}
					}

					Keys.onUpPressed: {
						sfxNav.play(); 
						headerMenu.focus = true;
					}

					Keys.onDownPressed: {
						sfxNav.play(); 
						insideFocus = false
					}

					Keys.onLeftPressed: {
						sfxNav.play();
						switch (currentButton) {
							case 0:
								currentButton = 1;
								break;
							case 1:
								currentButton = 0;
								break;
							default:
								currentButton = 0;
						}
					}

					Keys.onRightPressed: {
						sfxNav.play();
						switch (currentButton) {
							case 0:
								currentButton = 1;
								break;
							case 1:
								currentButton = 0;
								break;
							default:
								currentButton = 0;
						}
					}
				}



				// Mouse/touch functionality
				MouseArea {
					anchors.fill: parent
					hoverEnabled: settings.MouseHover == "Yes"
					//onEntered: { sfxNav.play(); mainList.currentIndex = 0; }
					// onClicked: {
					//     if (selected)
					//         gameDetails(modelData);  
					//     else
					//         mainList.currentIndex = 0;
					// }
				}

			}
			
		}

		Row {
		id: blips

			anchors.horizontalCenter: parent.horizontalCenter
			anchors { top: parent.top; topMargin: root.height - vpx(40) }
			spacing: vpx(10)
			Repeater {
				model: featuredList.count
				Rectangle {
					width: vpx(10)
					height: width
					color: (featuredList.currentIndex == index) && featuredList.focus && !insideFocus ? theme.accent : theme.text
					radius: width/2
					opacity: (featuredList.currentIndex == index) ? 1 : 0.5
				}
			}
		}

		// List specific input
		Keys.onUpPressed: { sfxNav.play(); insideFocus = true; }
		Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
		Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

		//Keys.onPressed: {
			//// Filters
			//if (api.keys.isFilters(event) && !event.isAutoRepeat) {
				//event.accepted = true;
				//sfxAccept.play();
				////game.favorite = !game.favorite;
			//}
		//}


		//Keys.onPressed: {
			// Accept
			//if (api.keys.isAccept(event) && !event.isAutoRepeat) {
				//event.accepted = true;
				//storedHomeSecondaryIndex = currentIndex;
				//if (!ftue)
					//gameDetails(collection.currentGame(currentIndex));            
			//}
		//}

	}


}
