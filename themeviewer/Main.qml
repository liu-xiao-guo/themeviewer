import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "themeviewer.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    property var props: [theme]
    property var propnames : ["theme"]

    ListModel {
        id: mymodel
    }

    Settings {
        id: settings
        property bool selectedAmbiance: true
    }

    function goUp() {
        if ( propnames.length > 1) {
            // We only do it when there is more than one item
            propnames.pop();
            header.text = propnames.join(".");
            props.pop();
            getProperties(props[props.length -1])
            console.log("swipe left: " + propnames)
        }
    }

    function getProperties(obj) {
        mymodel.clear();

        var keys = Object.keys(obj);
        for(var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var type = typeof obj[key];
            console.log(key + ' : ' + obj[key] + " " + type);

            if ( type === 'object' && obj[key] ) {
                if ( propnames.length === 3 ) {
                    mymodel.append({"name": key, "value": ""+obj[key] })
                } else {
                    mymodel.append({"name": key, "value": "white" })
                }
            }
        }
    }

    Page {
        id: page
        header: PageHeader {
            id: pageHeader
            title: i18n.tr("Theme Viewer")
            trailingActionBar.actions: [
                Action {
                    iconSource: settings.selectedAmbiance ?
                                "images/ambiance.png" : "images/dark.png"
                    text: "Ambiance"
                    onTriggered: {
                        settings.selectedAmbiance = !settings.selectedAmbiance

                        theme.name = (settings.selectedAmbiance ?
                                          "Ubuntu.Components.Themes.Ambiance" :
                                          "Ubuntu.Components.Themes.SuruDark" )

                        // We need to do it from the very beginning
                        props = [theme]
                        propnames = ["theme"]
                        header.text = propnames.join(".")
                        getProperties(props[props.length -1])
                    }
                }
            ]

            StyleHints {
                foregroundColor: UbuntuColors.orange
                backgroundColor: UbuntuColors.porcelain
                dividerColor: UbuntuColors.slate
            }
        }

        SystemPalette { id: __palette }

        Component {
            id: delegate
            Rectangle {
                width: parent.width
                height: propname.height * 1.7
                color: "transparent"

                Rectangle {
                    height: parent.height
                    width: parent.width*.2
                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                    color: value
                    visible: propnames.length === 3
                }

                Label {
                    id: propname
                    text: name
                    fontSize: "x-large"
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    id: mouseRegion
                    anchors.fill: parent

                    onDoubleClicked: {
                        props.push(props[props.length -1][propname.text])
                        propnames.push(propname.text)
                        header.text = propnames.join(".")
                        getProperties(props[props.length -1])
                    }

                    onClicked: {
                        list.currentIndex = index;
                    }
                }

                SwipeArea {
                    id: swiperight
                    anchors.fill: parent
                    direction: SwipeArea.Rightwards

                    onDraggingChanged: {
                        if ( dragging ) {
                            console.log("swipe right: " + propname.text)
                            props.push(props[props.length -1][propname.text])
                            propnames.push(propname.text)
                            header.text = propnames.join(".")
                            getProperties(props[props.length -1])
                        }
                    }
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: page.header.bottom
            }

            Row {
                width: parent.width
                height: header.height

                Button {
                    id: upButton
                    height: parent.height
                    width: units.gu(5)
                    iconSource: "qrc:///images/up.png"
                    onClicked:  {
                        goUp()
                    }
                }

                Label {
                    id: header
                    text: { return propnames.join(".") }
                    fontSize: "large"
                }

            }

            UbuntuListView {
                id: list
                clip:true
                width: page.width
                height: page.height - header.height
                focus: true
                model: mymodel
                highlight: Rectangle {
                    color: __palette.midlight
                    border.color: Qt.darker(__palette.window, 1.3)
                }
                highlightMoveDuration: -1
                highlightMoveVelocity: -1
                highlightFollowsCurrentItem: true
                delegate: delegate
            }

            Component.onCompleted: {
                getProperties(props[props.length -1])
            }
        }
    }

    SwipeArea {
        id: swipeleft
        direction:  SwipeArea.Leftwards
        anchors.fill: parent

        onDraggingChanged: {
            if ( dragging ) {
                goUp()
            }
        }
    }
}

