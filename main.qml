import QtQuick 2.9
import QtQml 2.1
import QtLocation 5.5
import QtPositioning 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls 2.1
import QtMultimedia 5.5

Window {
    id: mainFrame
    width: 1200
    height: 600
    visible: true
    title: qsTr("ISS Tracker")
    //properties
    property variant _latitude
    property variant _longitude
    property variant _altitude
    property variant _velocity
    //Soundeffect
    SoundEffect{
        id:soundEffect
        source: "qrc:/SoundEffect/effectSatelliteMoving.wav"
        volume: volumnSlider.value //getting volumn values from Volumnslider
    }
    //SplitView
    SplitView{
        id: splitView
        anchors.fill: parent
        //Rectangle for toolbars element first element in SplitView
        Rectangle{
            id:toolBars
            //width: 300 //need to be 0 at the start of application to apply effects later on
            color: "black"
            //Column
            Column{
                anchors.centerIn: parent
                spacing: 3
                //info latitude
                Text {
                    id: textLatitude
                    text: qsTr("latitude: " + _latitude +" %1").arg("º")
                    color: "lightblue"
                    visible: false
                }
                //info longitude
                Text {
                    id: textLongitude
                    text: qsTr("longitude: " + _longitude + " %1").arg("º")
                    color: "lightblue"
                    visible: false
                }
                //info velocity
                Text {
                    id: textVelocity
                    text: qsTr("velocity: " + Math.floor(_velocity) + " %1").arg("km/h")
                    color: "lightblue"
                    visible: false
                }
                //info altitude
                Text {
                    id: textAltitude
                    text: qsTr("altitude: " + _altitude + " %1").arg("km")
                    color: "lightblue"
                    visible: false
                }
                //button
                Button{
                    id: startTrackBtn
                    text: "start tracking ..."
                    //clicked event
                    onClicked: { backEndRest.startTimer(); stopTrackBtn.enabled = true; startTrackBtn.enabled = false}
                }
                Button{
                    id:stopTrackBtn
                    text: "stop tracking !"
                    enabled: false
                    onClicked: { backEndRest.stopTimer(); stopTrackBtn.enabled = false; startTrackBtn.enabled = true}
                }
                //slider to controll volumn effect
                Slider{
                    id:volumnSlider
                    width: 100
                    from: 0.0
                    to: 1.0
                    value: 0.1
                    stepSize: 0.1
                    opacity: 0.4
                    //text for slider
                    Text {
                        id: textVolumnSlider
                        anchors.left: volumnSlider.right
                        text: qsTr("%1 Sound Lvl").arg(volumnSlider.value)
                        color: "white"
                        font.pixelSize: 20
                    }
                }
                //slider to controll backend timer intervals
                Slider{
                    id:intervalSlider
                    width: 100
                    from: 1
                    to: 10
                    value: 1
                    stepSize: 1        //whenever intervalSlider chanhge then set ew interval to backend
                    opacity: 0.4
                    onValueChanged: backEndRest.setIntervals(value)
                    //text for slider
                    Text {
                        id: textIntervalSlider
                        anchors.left: intervalSlider.right
                        text: qsTr("%1 Intervals").arg(intervalSlider.value)
                        color: "white"
                        font.pixelSize: 20
                    }
                }
                //slider for controlling satellite image size
                Slider{
                    id: satelliteImageSizeSlider
                    width: 100
                    from: 20
                    to: 200
                    stepSize: 1
                    value: 50
                    opacity: 0.4
                    Text {
                        id: satelliteImageSizeText
                        anchors.left: satelliteImageSizeSlider.right
                        text: qsTr("%1 Satellite Size").arg(satelliteImageSizeSlider.value)
                        color: "white"
                        font.pixelSize: 20
                    }
                }
            }//end of Column layout
        }//end of toolBars Rectangle
        //Plugin
        Plugin{
            id: pluginMap
            name: "esri"
        }
        //map
        Map{
            id: map
            plugin: pluginMap
            anchors.fill: mainFrame
            copyrightsVisible: false
            zoomLevel: 5
            center: QtPositioning.coordinate(_latitude, _longitude) //play sound everytime center is chenged
            onCenterChanged: soundEffect.play()
            //satellite image
            MapQuickItem{
                id:satelliteObj
                coordinate: QtPositioning.coordinate(_latitude, _longitude)
                sourceItem: Image {
                    id: satelliteImage
                    width: satelliteImageSizeSlider.value
                    height: satelliteImageSizeSlider.value
                    focus: true
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/satellite3.png"
                }//end of sourceItem
            }//end of MapQuickItem
        }//end of map
    }//end of SplitView
    //backend connections
    Connections{
        target: backEndRest //getting data from back end
        onLatitudeChanged:{ _latitude = backEndRest.latitude; textLatitude.visible = true }
        onLongitudeChanged:{ _longitude = backEndRest.longitude; textLongitude.visible = true }
        onVelocityChanged:{ _velocity = backEndRest.velocity; textVelocity.visible = true }
        onAltitudeChanged:{ _altitude = backEndRest.altitude; textAltitude.visible = true }
    }
    //image for menu
    Image {
        id: imageMenu
        x: 10
        y: 10
        width: 20
        height: 20
        source: "qrc:/images/menuIcon.png"
        fillMode: Image.PreserveAspectFit
        //mouse area to make appear side bar effect
        MouseArea{
            id: mouseAreaSideBar
            hoverEnabled: true
            anchors.fill: imageMenu
            onClicked: animationSideBarEffect.running = true
            onEntered: animationSideBarEffectTurn.running = true
            onPressed:  imageMenu.scale = 1.9;
            onReleased: imageMenu.scale = 1
        }//end of mouse area
    }//end of imageMenu
    //animation for side bar effect
    NumberAnimation{
        id: animationSideBarEffect
        target: toolBars
        properties: "width"
        to: toolBars.width == 0 ? 300 : 0
        duration: 600
        running: false
    }
    //animation for side bar effect
    RotationAnimation{
        id: animationSideBarEffectTurn
        target: imageMenu
        from: 0
        to: 360
        duration: 500
        running: false
    }
    //when the hole crap is loaded then want to set a default value to timer intervals
    Component.onCompleted: backEndRest.setIntervals(intervalSlider.value)
}
