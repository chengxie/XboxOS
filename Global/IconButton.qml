import QtQuick 2.0

FocusScope {
id: root

    property alias icon: icon.source
    property alias color: button.color
	property real size: vpx(40)

    signal activate
    signal highlighted

	width: size
	height: size

	Rectangle { 
	id: button
		anchors.fill: parent
		radius: height / 2
		Image {
		id: icon
			//anchors.fill: parent
			anchors.centerIn: parent
			width: parent.width * 0.6
			height: parent.height * 0.6
			//anchors.margins: parent.width * 0.16
			smooth: true
			asynchronous: true
		}
	}

	Keys.onPressed: {
		if (api.keys.isAccept(event) && !event.isAutoRepeat) {
			// Accept
			event.accepted = true;
			activate();
		}
	}

    // Mouse/touch functionality
    MouseArea {
        anchors.fill: parent
        hoverEnabled: settings.MouseHover == "Yes"
        onEntered: { sfxNav.play(); highlighted(); }
        onExited: {}
        onClicked: activate();
    }
}

