import QtQuick 2.0

Loader  {
	anchors.fill: parent
	active: opacity !== 0
	opacity: focus ? 1 : 0
	Behavior on opacity { PropertyAnimation { duration: 100 } }
	asynchronous: true
}
